###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>  

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

# ~require
{Node:{
  DOCUMENT_NODE
}}              = require '../Node'

{Document:{
  ownerDocument
}}              = require '../Document'

{Traversal}     = require '../Traversal'

# ~export
exports = module?.exports ? this

# Level2NodeIterator
# ================================

# --------------------------------
# A class to hold state for a DOM traversal.
#
# This implementation depends on *DOM Level ≥ 2*'s `NodeIterator`.
#
# @public
# @class      Level2NodeIterator
# @extends    goatee.Dom.Traversal
# @namespace  goatee.Dom.Traversal
# @see        [DOM Level 2 `NodeIterator` Interface-Specification](http://www.w3.org/TR/DOM-Level-2-Traversal-Range/traversal.html#Traversal-NodeIterator)
exports.Level2NodeIterator = \
class Level2NodeIterator extends Traversal

  # --------------------------------
  # > Bitwise OR'd list of Filter specification constants from the NodeFilter
  #   DOM interface, indicating which nodes to iterate over.
  #
  # @public
  # @property filter
  # @type     {Number}
  # @see      [DOM Level 2 `NodeFilter` Interface-Specification](http://www.w3.org/TR/DOM-Level-2-Traversal-Range/traversal.html#Traversal-NodeFilter)
  # @see      [`NodeFilter` Constants](https://developer.mozilla.org/en/DOM/NodeFilter#Filter_specification_constants)
  filter: NodeFilter.SHOW_ELEMENT

  # --------------------------------
  # > An object implementing the NodeFilter interface; its `acceptNode()` method
  #   will be called for each node in the subtree based at root which is accepted
  #   as included by the `filter` flag (above) to determine whether or not to
  #   include it in the list of iterable nodes (a simple callback function may
  #   also be used instead).  The method should return one of
  #   `NodeFilter.[FILTER_ACCEPT|FILTER_REJECT|FILTER_SKIP]`, ie.:
  # >
  # >     {
  # >       acceptNode: function (node) {
  # >         return NodeFilter.FILTER_ACCEPT;
  # >       }
  # >     }
  # 
  # @public
  # @property options
  # @type     {Object}
  # @see      [DOM Level 2 `NodeFilter` Interface-Specification](http://www.w3.org/TR/DOM-Level-2-Traversal-Range/traversal.html#Traversal-NodeFilter)
  # @see      [`NodeFilter` Documentation](https://developer.mozilla.org/en-US/docs/DOM/NodeFilter)
  options: null

  # --------------------------------
  # Processes the DOM tree in breadth-first order.
  #
  # @public
  # @method run
  # @param  {Node}  root  The root node of the traversal
  # @return {goatee.Dom.Traversal}
  run: (root) ->
    @process root, @prepare root

  # --------------------------------
  # Prepare the node iterator for a single root node.
  #
  # @public
  # @method prepare
  # @param  {Node}  root  The root node of the traversal
  # @return {NodeIterator}
  prepare: (root) ->
    @collect root, ownerDocument(root)

  # --------------------------------
  # Create an iterator collecting a single node's immediate child-nodes.
  #
  # @public
  # @method collect
  # @param  {Node}      root  The root node of the traversal.
  # @param  {Document}  doc   Root's owner-document.
  # @return {NodeIterator}
  # @see    [`createNodeIterator` Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Document.createNodeIterator)
  collect: (root, doc) ->
    doc.createNodeIterator(

      # Node to use as root
      root,

      # Only consider nodes that match this filter
      @filter,

      # Object containing the function to use as method of the NodeFilter
      @options,

      # > Note: Prior to Gecko 12.0 (Firefox 12.0 / Thunderbird 12.0 /
      #   SeaMonkey 2.9), this method accepted an optional fourth parameter
      #   (entityReferenceExpansion) that is not part of the DOM4 specification,
      #   and has therefore been removed.  This parameter indicated whether or
      #   not the children of entity reference nodes were visible to the
      #   iterator.  Since such nodes were never created in browsers, this
      #   parameter had no effect.
      # @deprecated
      false
    )

  # --------------------------------
  # Processes the root node and all of its children.
  #
  # @public
  # @method process
  # @param  {Node}          root  The root node of the traversal.
  # @param  {NodeIterator}  node  The current node of the traversal.
  # @return {goatee.Dom.Traversal}
  process: (root, iterator) ->
    # We deliberately enforce equality instead of identity here.
    @callback root if `root.nodeType == DOCUMENT_NODE`
    @callback node while node = iterator.nextNode()
    return this

  # --------------------------------
  # Creates the `Traversal`-instance.
  #
  # @static
  # @public
  # @method create
  # @param  {Function}  callback  A function, called for each traversed node
  # @return {goatee.Dom.Traversal}
  @create: (callback) ->
    new Level2NodeIterator callback
