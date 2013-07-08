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

Gaotee Evaluation
===================

Goatee action attributes and event action names have been choosen
carefully in order to avoid naming collision with existing dom attributes,
events and properties.

Within a single element they are evaluated in the following order:

Outer Actions
-------------------

Outer actions operate with and on tag and context, without touching any tag-
attributes. They implement aspects like automation, recursion or multiplicity.

• render        This action initiates the rendering automatically, after
                the dom is ready. The algorithm uses the given “render”-data as
                Context. Additionally if “jQuery” is available and the given
                data is a string, “render” may be either an global javascript
                variable reference, or if that fails an url to an external json-
                file. Changes to the render value, will stop any process
                rendering the same tag and start re-rendering. The rendering-
                process will skip all nested tags which it-self contain a
                “render”-Attribute, hence any of those tags will be processed
                automatically in the order of their appearance.

• match         If “json:select” is available and “match” value is used as
                css3-like query onto the current context. Therefore the context
                must be suiteable as 2nd argument of “JSONSelect.match”.
                @see http://jsonselect.org

• source        Formerly “transclude”. If a “source” action is present no
                further actions are processed. Additionally if either
                “Sizzle”, “cheerio” or “jQuery” is available, “source” may be
                an internal template-reference, like in
                   `(jQuery||cheerio||Sizzle)( 'source #id .selector', this )`
                or in the case of “jQuery” an external reference, like in
                   `jQuery(this).load( 'http://source.url #element-id'” );`.

• repeat        Formerly “jsselect”.  If “repeat” is array-valued, remaining
                actions will be copied to each new duplicate element
                created by the “repeat” and processed when the further dom
                traversal visits the new elements.

Inner Actions
-------------------

Inner actions operate on tag element-attributes, -properties and -methods as
well as the context-data, -variables and -values.

• appear        Formerly “jsdisplay”.

• set           Formerly “jsvars”.

• alter         Formerly “jsvalues”.

• do            Formerly “jseval”.

• skip          Formerly “jsskip”.

• markup        This action is present if `(cheerio|jQuery)(…).html()` is
                available.

• text          Formerly “jscontent”. Uses `(cheerio|jQuery)(…).text()` if
                available, otherwise Node.innerHTML will be assigned to given
                content.

• next          This action is present if `(cheerio|jQuery)(…).next()` is
                available.

###

{Constants} = require 'goatee/Core/Constants'
{Utility}   = require 'goatee/Core/Utility'
{Document}  = require 'goatee/Dom/Document'

root = exports ? this

## Processor
# Internal class used by goatee-templates to maintain context.  This is
# necessary to process deep templates in Safari which has a
# relatively shallow maximum recursion depth of 100.
# @class
root.Processor = class Processor

  ##
  # @type {Document}
  document: null

  ##
  # @type {Object}
  options: null

  ##
  # @param  {Object}  options
  # @constuctor
  constructor: (@options) ->

    ##
    # Caches the document of the template node, so we don't have to
    # access it through ownerDocument.
    # @type {Document}
    @document = @options.document \
      if not @document? and @options? and @options.document?


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
    # @type {Array.<Number>}
    indices = self.indices = []

    ##
    # A pool of empty arrays.  Minimizes object allocation for IE6's benefit.
    # @type {Array.<Array>}
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
  #                     [ method, arg1, arg2, method, arg1, arg2, ... ]
  push: (args) ->
    this.calls.push args
    this.indices.push 0
    return

  ##
  # Prepares the template: preprocesses all goatee-template actions.
  #
  # @param {Element} template
  setup: (template) ->
    unless @getCacheProperty(template)?
      self = @
      doc.traverseElements(template, (node) -> self.prepare(node))
    return

  ##
  # A list of attributes we use to specify jst processing actions,
  # and the functions used to parse their values.
  #
  # @type {Array.<Array>}
  actions: [
  #    [ Constants.ATT_select, jsEvalToFunction ],
  #    [ Constants.ATT_display, jsEvalToFunction ],
  #    [ Constants.ATT_values, jsEvalToValues ],
  #    [ Constants.ATT_vars, jsEvalToValues ],
  #    [ Constants.ATT_eval, jsEvalToExpressions ],
  #    [ Constants.ATT_transclude, jsEvalToSelf ],
  #    [ Constants.ATT_content, jsEvalToFunction ],
  #    [ Constants.ATT_skip, jsEvalToFunction ]
  ]

  ##
  # A list for storing non-empty actions found on a node in prepare().
  # The array is global since it can be reused - this way there is no need to
  # construct a new array object for each invocation. (IE6 perf)
  #
  # @type Array
  _list   = []

  ##
  # Map for storing temporary action values in prepare() so they don't have
  # to be retrieved twice. (IE6 perf)
  #
  # @type Object
  _values = {}

  ##
  # Counter to generate cache ids. These ids will be stored used to lookup the
  # preprocessed actions from the cache.  The id is stored with the element
  # to survive cloneNode() and thus cloned template nodes can share the same
  # cache entry.
  #
  # @type {Number}
  _id = 0

  ##
  # Map from cache id to processed actions.
  #
  # @type Object
  _actions = {}

  ##
  # The neutral cache entry. Used for all nodes that lack any actions.
  # We still set the id on those nodes so we can avoid looking again for all
  # the other actions that aren't there.  Remember: not only the
  # processing of the action-values is expensive and we thus want to
  # cache it.  The access to the actions on the Node in the first place
  # is very expensive too.
  _empty = _actions[Constants.STRING_zero] = {}

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
    @collect(node, _list, _values)

    # If none found, mark this node to prevent further inspection, and return
    # an empty cache object.
    return @setEmpty node if _list.length == 0

    source = @combine _list

    # If we already have a cache object corresponding to these attributes,
    # annotate the node with it, and return it
    id = @getSourceIdentifier source
    if id?
      cache = @getCache id
      if cache?
        @setElementIdentifier node, id
        return @setCacheProperty node, cache

    # Otherwise, build a new cache object.
    cache = @build(node, _values)
    id    = Constants.STRING_empty + ++_id

    @setCache(id, cache)
    @setElementIdentifier(node, id)
    @setSourceIdentifier(source, id)
    @setCacheProperty(node, cache)

  ##
  # Collect actions from node.
  #
  # @param  {Element}       node
  # @param  {Array}         Array to append collected intructions to
  # @param  {Element}       node
  # @return {Array.<Array,Object>} Array of action-list and its value-map
  collect: (node, list, values) ->
    for [name] in @actions
      value = doc.getAttribute node, name
      values[name] = value
      list.push @translate(name, value) if value?
    return

  translate: (name, value) ->
    # raw rule (uses “|=|” as assignment)
    return Constants.STRING_empty + name + \
      Constants.STRING_assigment + value

    # url encoded rule
    # uses “=” as assignment, encodes the value
    return Constants.STRING_empty + name + \
      Constants.CHAR_equals + encodeUriComponent(value)

    # css-like formatted rule
    # uses “:” as assignment, escapes and double-quotes the value
    return Constants.STRING_empty + name + \
      Constants.CHAR_colon + \
      Constants.CHAR_doublequote + \
      (Constants.STRING_empty + value).replace('"','\\"') + \
      Constants.CHAR_doublequote

  combine: (list) ->

    # raw rule (uses “|||” as seperator)
    return list.join Constants.STRING_seperator

    # url encoded rule (uses “&” as seperator)
    return list.join Constants.CHAR_ampersand

    # css-like formatted rule (uses “;” as seperator)
    return list.join Constants.CHAR_semicolon

  ##
  # Build a new cache object.
  # @param  {Element}       node
  # @return {Array.<Array>} Array of node's action-list and its value-map
  build: (node, values) ->
    cache = {}
    for [name, parse] in @actions
      value = values[name]
      continue unless value?
      cache[name] = parse value
      if Constants.DEBUG
        goatee = cache.goatee ? cache.goatee = {}
        goatee[name] = value
    cache

  ##
  # Get cached actions-property from given node.
  #
  # @param  {Element} node
  # @return {Object}
  getCacheProperty: (node) ->
    node[Constants.PROP_jstcache]

  ##
  # Cache actions in a node-property.
  #
  # @param  {Element} node
  # @param  {Object}  actions
  # @return {Object}
  setCacheProperty: (node, actions) ->
    node[Constants.PROP_jstcache] = actions

  ##
  # Get cached actions-property for given id.
  #
  # @param  {String} id
  # @return {Object}
  getCache: (id) ->
    _actions[id]

  ##
  # Cache actions under given id.
  #
  # @param  {String}  id
  # @param  {Object}  actions
  # @return {Object}
  setCache: (id, actions) ->
    _actions[id] = actions

  ##
  # Get cached identifier-attribute from given node.
  #
  # @param  {Element} node
  # @return {String}
  getElementIdentifier: (node) ->
    doc.getAttribute node, Constants.ATT_jstcache

  ##
  # Cache identifier as node-attribute.
  #
  # @param  {Element} node
  # @param  {String}  id
  # @return {String}
  setElementIdentifier: (node, id) ->
    doc.setAttribute node, Constants.ATT_jstcache, id
    id

  ##
  # Map from source, a concatenated action string, to cache id.  The key
  # is the concatenation of all actions found on a node formatted as
  # "name1=value1&name2=value2&...", in the order defined by @actions.
  # The value is the id of the cache-entry that can be used for this node.
  # This allows the reuse of cache entries in cases when a cached entry already
  # exists for a given combination of attribute values. (For example when two
  # template-nodes share the same actions.)
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
    @setElementIdentifier node, Constants.STRING_zero
    @setCacheProperty _empty

##
# @param  {Object}  options  Options passed to `new Processor()`.
# @return {Processor}
Processor.create = (options) ->
  return new Processor options

##
# HTML template processor. Data values are bound to HTML templates
# using the attributes transclude, jsselect, jsdisplay, jscontent,
# jsvalues. The template is modifed in place. The values of those
# attributes are JavaScript expressions that are evaluated in the
# context of the data object fragment.
#
# @param  {Context} context  Context created from the input data object.
# @param  {Element} template DOM node of the template. This will be processed
#                            in place. After processing, it will still be a
#                            valid template that, if processed again with the
#                            same data, it will remain unchanged.
# @param  {Object}  options  Options passed to `Processor.create()`.
# @return void
Processor.process = (context, template, options) ->

  processor = Processor.create options

    # Cache the owner document
  processor.document = doc.ownerDocument(template)

    # Traverse the template, emit actions and cache them
  processor.setup template

    # Execute all actions
  processor.run(Utility.bind(processor, processor.outer, context, template))
  return