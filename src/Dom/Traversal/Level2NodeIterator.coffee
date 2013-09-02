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

{Node:{
  DOCUMENT_NODE
}}              = require '../Node'
{Document:{
  ownerDocument
}}              = require '../Document'
{Traversal}     = require '../Traversal'

exports = module?.exports ? this

## Level2NodeIterator

# A class to hold state for a dom traversal.
#
# @class
# @namespace goatee
exports.Level2NodeIterator = \
class Level2NodeIterator extends Traversal

  ##
  # @see http://www.w3.org/TR/DOM-Level-2-Traversal-Range/traversal.html#Traversal-NodeFilter
  # @type {Number}
  filter: NodeFilter.SHOW_ELEMENT

  ##
  # Object containing the function to use as method of the NodeFilter. It
  # contains logic to determine whether to accept, reject or skip node, eg.:
  #   {
  #     ##
  #     # @param  {Node}  node  The root node of the traversal.
  #     # @return {NodeFilter.[FILTER_ACCEPT|FILTER_REJECT|FILTER_SKIP]}
  #     acceptNode: (node) ->
  #       NodeFilter.FILTER_ACCEPT
  #   }
  # @see http://www.w3.org/TR/DOM-Level-2-Traversal-Range/traversal.html#Traversal-NodeFilter
  # @type {Object}
  options: null

  ##
  # Processes the dom tree in breadth-first order.
  # @param {Node} root  The root node of the traversal.
  # @see http://www.w3.org/TR/DOM-Level-2-Traversal-Range/traversal.html#Traversal-NodeIterator
  run: (root) ->
    @process root, @prepare root
    return this

  ##
  # Prepare the node iterator for a single root node.
  #
  # @param {Node} root  The root node of the traversal.
  # @return {NodeIterator}
  prepare: (root) ->
    @collect root, ownerDocument(root)

  ##
  # Create node iterator for a single root node.
  #
  # @param  {Node}      root  The root node of the traversal.
  # @param  {Document}  doc   Root's owner-document.
  # @return {NodeIterator}
  collect: (root, doc) ->
    doc.createNodeIterator(
      # Node to use as root
      root,

      # Only consider nodes that match this filter
      @filter,

      # Object containing the function to use as method of the NodeFilter
      @options,

      false
    )


  ##
  # Processes a single node.
  # @param {NodeIterator}    node  The current node of the traversal.
  process: (iterator) ->
    @callback root if `root.nodeType == DOCUMENT_NODE`
    @callback node while node = iterator.nextNode()
    return

Level2NodeIterator.create = (callback) ->
  new Level2NodeIterator callback
