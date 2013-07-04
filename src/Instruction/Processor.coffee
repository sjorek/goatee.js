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

Goatee instruction attributes and event instructions within a single element are
evaluated in the following order:

Outer Processors
-------------------

Outer processors operate on the tag only. Not on its attributes, but on aspects
like automation, recursion or multiplicity.

• render        This instruction initiates the rendering automatically, after the
                dom is ready. The algorithm uses the given “render”-data as
                Context. Additionally if “jQuery” is available and the given
                data is a string, “render” may be either an global javascript
                variable reference, or if that fails an url to an external json-
                file. Changes to the render value, will stop any process 
                rendering the same tag and start re-rendering. The rendering-
                process will skip all nested tags which it-self contain a
                “render”-Attribute, hence any of those tags will be processed
                automatically in the order of their appearance.

• source        Formerly “transclude”. If a “source” instruction is present no
                further instructions are processed. Additionally if either “Sizzle”, 
                “cheerio” or “jQuery” is available, “source” may be an internal
                template-reference, like in
                   `(jQuery||cheerio||Sizzle)( 'source #id .selector', this )`
                or if “jQuery” is available also an external reference, like in
                   `jQuery(this).load( 'http://source.url #element-id'” );`.

• list          Formerly “jsselect”. If “list” is array-valued, remaining
                instructions will be copied to each new duplicate element created
                by the “list” and processed when the further dom-traversal
                visits the new elements. If “json:select” is available and
                “list” is a String, it is used as css3-like query onto the
                current context. Therefore the context must be suiteable as 2nd
                argument of “JSONSelect.match”. @see http://jsonselect.org

Inner Processors
-------------------

Inner processors operate on tag element-attributes, -properties and -methods as
well as the context-data, -variables and -values.

• display       Formerly “jsdisplay”.

• set           Formerly “jsvars”.

• alter         Formerly “jsvalues”.

• exec(ute)     Formerly “jseval”.

• skip          Formerly “jsskip”.

• markup        This instruction is present if `(cheerio|jQuery)(…).html()` is
                available.

• text          Formerly “jscontent”. Uses `(cheerio|jQuery)(…).text()` if
                available, otherwise Node.innerHTML will be assigned to given
                content.

• next          This instruction is present if `(cheerio|jQuery)(…).next()` is
                available.

###

constant  = require 'goatee/Core/Constants'
utility   = require 'goatee/Core/Utility'
doc       = require 'goatee/Dom/Document'
cache     = require 'goatee/Cache/Composite'

root = exports ? this

## Processor
# Internal class used by goatee-templates to maintain context.  This is
# necessary to process deep templates in Safari which has a
# relatively shallow maximum recursion depth of 100.
# @class
root.Processor = class Processor

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
  run: (f) ->
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
    calls = self.calls = []
  
    ##
    # The index into the queue for each depth. NOTE: Alternative would
    # be to maintain the queues in reverse order (popping off of the
    # end) but the repeated calls to .pop() consumed 90% of this
    # function's execution time.
    # @type Array.<number>
    indices = self.indices = []
  
    ##
    # A pool of empty arrays.  Minimizes object allocation for IE6's benefit.
    # @type Array.<Array>
    arrays = self.arrays = []
  
    f()
    while calls.length > 0
      queue = calls[calls.length - 1]
      index = indices[indices.length - 1]
      if index >= queue.length
        self.recycleArray calls.pop()
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
  push: (args) ->
    this.calls.push args
    this.indices.push 0
    return

  ##
  # Prepares the template: preprocesses all goatee-template instructions.
  #
  # @param {Element} template
  setup: (template) ->
    unless @getCacheProperty(template)?
      self = @
      doc.traverseElements(template, (node) -> self.prepare(node))
    return

  ##
  # A list of attributes we use to specify jst processing instructions,
  # and the functions used to parse their values.
  #
  # @type {Array.<Array>}
  instructions: [
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
  prepare: (node) ->

    # If the node already has a cache property, return it.
    cache = @getCacheProperty(node)
    return cache if cache?

    # If it is not found, we always set the PROP_jstcache property on the node.
    # Accessing the property is faster than executing getAttribute(). If we
    # don't find the property on a node that was cloned in jstSelect_(), we
    # will fall back to check for the attribute and set the property
    # from cache.
  
    # If the node has an attribute indexing a cache object, set it as a property
    # and return it.
    id = @getElementIdentifier(node)
    if id?
      cache = @getCache id
      if cache?
        return @setCacheProperty(node, cache)

    # If the node has an attribute indexing a cache object, set it as a property
    # and return it.
    [list, values] = @collect(node)

    # If none found, mark this node to prevent further inspection, and return
    # an empty cache object.
    return @setEmpty node if list.length == 0

    source = list.join constant.CHAR_ampersand

    # If we already have a cache object corresponding to these attributes,
    # annotate the node with it, and return it
    id = @getSourceIdentifier source
    if id?
      cache = @getCache id
      if cache?
        @setElementIdentifier node, id
        return @setCacheProperty node, cache

    # Otherwise, build a new cache object.
    [cache, id] = @build(node, values)

    @setCache(id, cache)
    @setElementIdentifier(node, id)
    @setSourceIdentifier(source, id)
    @setCacheProperty(node, cache)


  ##
  # A list for storing non-empty instructions found on a node in prepare().
  # The array is global since it can be reused - this way there is no need to
  # construct a new array object for each invocation. (IE6 perf)
  #
  # @type Array
  _list   = []

  ##
  # Map for storing temporary instruction values in prepare() so they don't have
  # to be retrieved twice. (IE6 perf)
  #
  # @type Object
  _values = {}

  ##
  # Collect instructions from node.
  #
  # @param  {Element}       node
  # @return {Array.<Array,Object>} Array of instruction-list and its value-map
  collect: (node) ->
    utility.clearArray _list
    for [name] in @instructions
      value = doc.getAttribute node, name
      _values[name] = value
      _list.push(name + "=" + value) if value?
    [_list, _values]

  ##
  # Counter to generate cache ids. These ids will be stored used to lookup the
  # preprocessed instructions from the cache.  The id is stored with the element
  # to survive cloneNode() and thus cloned template nodes can share the same
  # cache entry.
  #
  # @type number
  _id = 0

  ##
  # Build a new cache object.
  # @param  {Element}       node
  # @return {Array.<Array>} Array of node's instruction-list and its value-map
  build: (node, values) ->
    cache = {}
    for [name, parse] in @instructions
      value = values[name]
      continue unless value?
      cache[name] = parse value
      if constant.DEBUG
        instructions = cache.instructions ? {}
        instructions[name] = value
    [cache, constant.STRING_empty + ++_id]

  ##
  # Get cached instructions-property from given node.
  #
  # @param  {Element} node
  # @return {Object}
  getCacheProperty: (node) ->
    node[constant.PROP_jstcache]
    
  ##
  # Cache instructions in a node-property.
  #
  # @param  {Element} node
  # @param  {Object}  instructions
  # @return {Object}
  setCacheProperty: (node, instructions) ->
    node[constant.PROP_jstcache] = instructions

  ##
  # Map from cache id to processed instructions.
  #
  # @type Object
  _instructions = {
    ##
    # The neutral cache entry. Used for all nodes that lack any instructions.
    # We still set the id on those nodes so we can avoid looking again for all
    # the other instructions that aren't there.  Remember: not only the
    # processing of the instruction-values is expensive and we thus want to
    # cache it.  The access to the instructions on the Node in the first place
    # is very expensive too.
    0:{}
  }

  ##
  # Get cached instructions-property for given id.
  #
  # @param  {String} id
  # @return {Object}
  getCache: (id) ->
    _instructions[id]

  ##
  # Cache instructions under given id.
  #
  # @param  {String}  id
  # @param  {Object}  instructions
  # @return {Object}
  setCache: (id, instructions) ->
    _instructions[id] = instructions

  ##
  # Get cached identifier-attribute from given node.
  #
  # @param  {Element} node
  # @return {String}
  getElementIdentifier: (node) ->
    doc.getAttribute node, constant.ATT_jstcache

  ##
  # Cache identifier as node-attribute.
  #
  # @param  {Element} node
  # @param  {String}  id
  # @return {String}
  setElementIdentifier: (node, id) ->
    doc.setAttribute node, constant.ATT_jstcache, id
    id

  ##
  # Map from source, a concatenated instruction string, to cache id.  The key
  # is the concatenation of all instructions found on a node formatted as
  # "name1=value1&name2=value2&...", in the order defined by @instructions.
  # The value is the id of the cache-entry that can be used for this node.
  # This allows the reuse of cache entries in cases when a cached entry already
  # exists for a given combination of attribute values. (For example when two
  # template-nodes share the same instructions.)
  #
  # @type Object
  _sources = {}

  ##
  # Get cached identifier for given source.
  #
  # @param  {String} source
  # @return {String}
  getSourceIdentifier: (source) ->
    _sources[source]

  ##
  # Cache identifier for given source.
  #
  # @param  {String}  source
  # @param  {String}  id
  # @return {String}
  setSourceIdentifier: (source, id) ->
    _sources[source] = id

  ##
  # Mark all relevant caches as empty
  #
  # @param  {Element}  node
  # @return {Object}
  setEmpty: (node) ->
    doc.setAttribute node, constant.ATT_jstcache, constant.STRING_zero
    @setCacheProperty _instructions[0]
