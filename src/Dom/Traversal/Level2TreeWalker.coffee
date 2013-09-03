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

#~ require
{Level2NodeIterator} = require './Level2NodeIterator'

#~ export
exports = module?.exports ? this

# Level2TreeWalker
# ================================

# --------------------------------
# A class to hold state for a DOM traversal.
#
# This implementation depends on *DOM Level ≥ 2*'s `TreeWalker`.
#
# @public
# @class      Level2TreeWalker
# @extends    goatee.Dom.Traversal
# @namespace  goatee.Dom.Traversal
# @see        [`TreeWalker` Documentation](https://developer.mozilla.org/en-US/docs/Web/API/TreeWalker)
exports.Level2TreeWalker = \
class Level2TreeWalker extends Level2NodeIterator

  # --------------------------------
  # Create `TreeWalker` node iterator for a single root node.
  #
  # Create an iterator collecting a single node's immediate child-nodes.
  #
  # @public
  # @method collect
  # @param  {Node}      root  The root node of the traversal.
  # @param  {Document}  doc   Root's owner-document.
  # @return {TreeWalker}
  # @see    [`createTreeWalker` Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Document.createTreeWalker)
  collect: (root, doc) ->
    doc.createTreeWalker(
      # Node to use as root
      root,

      # > Is an optional unsigned long representing a bitmask created by
      #   combining the constant properties of NodeFilter.  It is a convenient
      #   way of filtering for certain types of node.  It defaults to
      #   `0xFFFFFFFF` (-1) representing the SHOW_ALL constant.
      @filter,

      # > Is an optional NodeFilter, that is an object with a method acceptNode,
      #   which is called by the TreeWalker to determine whether or not to
      #   accept a node that has passed the whatToShow check.
      @options,

      # > A boolean flag indicating if when discarding an EntityReference its
      #   whole sub-tree must be discarded at the same time.
      # @deprecated
      false
    )

  # --------------------------------
  # Creates the `Traversal`-instance.
  #
  # @static
  # @public
  # @method create
  # @param  {Function}  callback  A function, called for each traversed node
  # @return {goatee.Dom.Traversal}
  @create: (callback) ->
    new Level2TreeWalker callback
