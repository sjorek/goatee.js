###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2006 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

###

Order of Evaluation
===================

Goatee instruction attributes and event actions within a single element are
evaluated in the following order:

Outer Processors
-------------------

• render        This action initiates the rendering automatically, after the
                dom is ready. The algorithm uses the given “render”-Data as
                Context. Additionally if “jQuery” is available and the given
                data is a string, “render” may be either an global javascript
                variable reference, or if that fails an url to an external json-
                file. Changes to the render value, will stop any process 
                rendering the same tag and start re-rendering. The rendering-
                process will skip all nested tags which it-self contain a
                “render”-Attribute, since any of those tags will be processed
                automatically in the order of their appearance.

• source        Formerly “transclude”. If a “source” action is present no
                further actions are processed. Additionally if either “Sizzle”, 
                “cheerio” or “jQuery” is available, “source” may be an internal
                template-reference, like in
                   `(jQuery||cheerio||Sizzle)( 'source #id .selector', this )`
                or if “jQuery” is available also an external reference, like in
                   `jQuery(this).load( 'http://source.url #element-id'” );`.

• select        Formerly “jsselect”. If “select” is array-valued, remaining
                actions will be copied to each new duplicate element created
                by the “select” and processed when the further dom-traversal
                visits the new elements. If “json:select” is available and
                “select” is a string, it is used as css3-like query onto the
                current context. Therefore the context must be suiteable as 2nd
                argument of “JSONSelect.match”. @see http://jsonselect.org

Inner Processors
-------------------

• show          Formerly “jsdisplay”.

• set           Formerly “jsvars”.

• alter         Formerly “jsvalues”.

• exec(ute)     Formerly “jseval”.

• stop          Formerly “jsskip”.

• markup        This action is present if `(cheerio|jQuery)(…).html()` is
                available.

• content       Formerly “jscontent”. Uses `(cheerio|jQuery)(…).text()` if
                available, otherwise Node.innerHTML will be assigned to given
                content.

• next          This action is present if `(cheerio|jQuery)(…).next()` is
                available.

###

constant  = require 'goatee/Core/Constants'
utility   = require 'goatee/Core/Utility'
doc       = require 'goatee/Dom/Document'
cache     = require 'goatee/Cache/Composite'

root = exports ? this

##
# Internal class used by jstemplates to maintain context.  This is
# necessary to process deep templates in Safari which has a
# relatively shallow maximum recursion depth of 100.
# @class
# @constructor
root.Processor = class Processor
  ##
  # @type goatee.DomCache
  cache: null
  compiler: null
  env: null
  engine: null

  constructor: (options) ->
    {@cache, @compiler, @env, @engine} = options

  ##
  # Runs the given function in our state machine.
  #
  # It's informative to view the set of all function calls as a tree:
  # - nodes are states
  # - edges are state transitions, implemented as calls to the pending
  #   functions in the stack.
  #   - pre-order function calls are downward edges (recursion into call).
  #   - post-order function calls are upward edges (return from call).
  # - leaves are nodes which do not recurse.
  # We represent the call tree as an array of array of calls, indexed as
  # stack[depth][index].  Here [depth] indexes into the call stack, and
  # [index] indexes into the call queue at that depth.  We require a call
  # queue so that a node may branch to more than one child
  # (which will be called serially), typically due to a loop structure.
  #
  # @param {Function} f The first function to run.
  run_: (f) ->
    self = this
  
    ##
    # A stack of queues of pre-order calls.
    # The inner arrays (constituent queues) are structured as
    # [ arg2, arg1, method, arg2, arg1, method, ...]
    # ie. a flattened array of methods with 2 arguments, in reverse order
    # for efficient push/pop.
    #
    # The outer array is a stack of such queues.
    #
    # @type Array.<Array>
    calls = self.calls_ = []
  
    ##
    # The index into the queue for each depth. NOTE: Alternative would
    # be to maintain the queues in reverse order (popping off of the
    # end) but the repeated calls to .pop() consumed 90% of this
    # function's execution time.
    # @type Array.<number>
    indices = self.indices_ = []
  
    ##
    # A pool of empty arrays.  Minimizes object allocation for IE6's benefit.
    # @type Array.<Array>
    arrayPool = self.arrayPool_ = []
  
    f()
    while calls.length > 0
      queue = calls[calls.length - 1]
      index = indices[indices.length - 1]
      if (index >= queue.length)
        self.recycleArray_(calls.pop())
        indices.pop()
        continue
  
      # Run the first function in the queue.
      method = queue[index++]
      arg1 = queue[index++]
      arg2 = queue[index++]
      indices[indices.length - 1] = index
      method.call(self, arg1, arg2)
    return

  ##
  # Pushes one or more functions onto the stack.  These will be run in sequence,
  # interspersed with any recursive calls that they make.
  #
  # This method takes ownership of the given array!
  #
  # @param {Array} args Array of method calls structured as
  #     [ method, arg1, arg2, method, arg1, arg2, ... ]
  push_: (args) ->
    this.calls_.push args
    this.indices_.push 0
    return

##
# Counter to generate node ids. These ids will be stored in
# ATT_jstcache and be used to lookup the preprocessed js attributes
# from the jstcache_. The id is stored in an attribute so it
# suvives cloneNode() and thus cloned template nodes can share the
# same cache entry.
# @type number
Processor.jstid_ = 0


##
# Map from jstid to processed js attributes.
# @type Object
Processor.jstcache_ = {}

##
# The neutral cache entry. Used for all nodes that don't have any
# jst attributes. We still set the jsid attribute on those nodes so
# we can avoid to look again for all the other jst attributes that
# aren't there. Remember: not only the processing of the js
# attribute values is expensive and we thus want to cache it. The
# access to the attributes on the Node in the first place is
# expensive too.
Processor.jstcache_[0] = {}


##
# Map from concatenated attribute string to jstid.
# The key is the concatenation of all jst atributes found on a node
# formatted as "name1=value1&name2=value2&...", in the order defined by
# JST_ATTRIBUTES. The value is the id of the jstcache_ entry that can
# be used for this node. This allows the reuse of cache entries in cases
# when a cached entry already exists for a given combination of attribute
# values. (For example when two different nodes in a template share the same
# JST attributes.)
# @type Object
Processor.jstcacheattributes_ = {}


##
# Map for storing temporary attribute values in prepareNode_() so they don't
# have to be retrieved twice. (IE6 perf)
# @type Object
Processor.values_ = {}


##
# A list for storing non-empty attributes found on a node in prepareNode_().
# The array is global since it can be reused - this way there is no need to
# construct a new array object for each invocation. (IE6 perf)
# @type Array
Processor.list_ = []


##
# Prepares the template: preprocesses all jstemplate attributes.
#
# @param {Element} template
Processor.prepareTemplate_ = (template) ->
  doc.traverseElements template, ((node) -> Processor.prepareNode_(node)) \
    if template[constant.PROP_jstcache]

##
# A list of attributes we use to specify jst processing instructions,
# and the functions used to parse their values.
#
# @type {Array.<Array>}
JST_ATTRIBUTES = [
#    [ constant.ATT_select, jsEvalToFunction ],
#    [ constant.ATT_display, jsEvalToFunction ],
#    [ constant.ATT_values, jsEvalToValues ],
#    [ constant.ATT_vars, jsEvalToValues ],
#    [ constant.ATT_eval, jsEvalToExpressions ],
#    [ constant.ATT_transclude, jsEvalToSelf ],
#    [ constant.ATT_content, jsEvalToFunction ],
#    [ constant.ATT_skip, jsEvalToFunction ]
]


##
# Prepares a single node: preprocesses all template attributes of the
# node, and if there are any, assigns a jsid attribute and stores the
# preprocessed attributes under the jsid in the jstcache.
#
# @param {Element} node
#
# @return {Object} The jstcache entry. The processed jst attributes
# are properties of this object. If the node has no jst attributes,
# returns an object with no properties (the jscache_[0] entry).
Processor.prepareNode_ = (node) ->
  # If the node already has a cache property, return it.
  return node[constant.PROP_jstcache] if node[constant.PROP_jstcache]?

  # If it is not found, we always set the PROP_jstcache property on the node.
  # Accessing the property is faster than executing getAttribute(). If we
  # don't find the property on a node that was cloned in jstSelect_(), we
  # will fall back to check for the attribute and set the property
  # from cache.

  # If the node has an attribute indexing a cache object, set it as a property
  # and return it.
  jstid = doc.getAttribute(node, constant.ATT_jstcache)
  return node[constant.PROP_jstcache] = Processor.jstcache_[jstid] \
    if jstid?

  values = Processor.values_
  list = Processor.list_
  utility.clearArray(list)

  # Look for interesting attributes.
  for [name] in JST_ATTRIBUTES
    value = doc.getAttribute(node, attr[0])
    values[name] = value
    list.push(name + "=" + value) if value?

  # If none found, mark this node to prevent further inspection, and return
  # an empty cache object.
  if list.length == 0
    doc.setAttribute node, constant.ATT_jstcache, constant.STRING_zero
    return node[constant.PROP_jstcache] = Processor.jstcache_[0]

  # If we already have a cache object corresponding to these attributes,
  # annotate the node with it, and return it.
  attstring = list.join constant.CHAR_ampersand
  if jstid = Processor.jstcacheattributes_[attstring]
    doc.setAttribute node, constant.ATT_jstcache, jstid
    return node[constant.PROP_jstcache] = Processor.jstcache_[jstid]

  # Otherwise, build a new cache object.
  jstcache = {}
  for [name, parse] in JST_ATTRIBUTES
    value = values[name]
    continue unless value?
    jstcache[name] = parse value
    if constant.DEBUG
      jstcache.jstAttributeValues = jstcache.jstAttributeValues || {}
      jstcache.jstAttributeValues[name] = value

  jstid = constant.STRING_empty + ++Processor.jstid_
  doc.setAttribute node, constant.ATT_jstcache, jstid
  Processor.jstcache_[jstid] = jstcache
  Processor.jstcacheattributes_[attstring] = jstid

  return node[constant.PROP_jstcache] = jstcache
