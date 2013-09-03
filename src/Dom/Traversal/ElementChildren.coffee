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
{Node:{
  ELEMENT_NODE
}}                      = require 'goatee/Dom/Node'

{Level1NodeTypeMatcher} = require 'goatee/Dom/Traversal'

#~ export
exports = module?.exports ? this

# ElementChildren
# ================================

# --------------------------------
# A class to hold state for a DOM traversal.
#
# This implementation depends on *DOM*'s native `Element.children`.
#
# @public
# @class      ElementChildren
# @extends    goatee.Dom.Traversal
# @namespace  goatee.Dom.Traversal
# @see        [`children` Attribute-Specification](http://dom.spec.whatwg.org/#dom-parentnode-children)
exports.ElementChildren = \
class ElementChildren extends Traversal

  # --------------------------------
  # Collect a single node's immediate child-nodes.
  #
  # @public
  # @method collect
  # @param  {Node}          node  The current node of the traversal.
  # @return {Array.<Node>}        An array of child-nodes.
  # @see    [`children` Attribute-Documentation](https://developer.mozilla.org/en-US/docs/Web/API/ParentNode.children)
  collect: (node) ->
    # Internet Explorer 6-8 supported it, but erroneously include Comment nodes.
    # We deliberately enforce equality instead of identity here.
    child for child in node.children when `child.nodeType == ELEMENT_NODE`

  # --------------------------------
  # Creates the `Traversal`-instance.
  #
  # @static
  # @public
  # @method create
  # @param  {Function}  callback  A function, called for each traversed node
  # @return {goatee.Dom.Traversal}
  @create: (callback) ->
    new ElementChildren callback
