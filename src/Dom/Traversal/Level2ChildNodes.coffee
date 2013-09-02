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
  ELEMENT_NODE
}}                      = require '../Node'

{Level1NodeTypeMatcher} = require '../Traversal'

# ~export
exports = module?.exports ? this

# Level2ChildNodes
# ================================

# --------------------------------
# A class to hold state for a DOM traversal.
#
# This implementation depends on *DOM Level ≥ 2*'s `Node.childNodes`.
#
# @public
# @class      Level2ChildNodes
# @extends    goatee.Dom.Traversal
# @namespace  goatee.Dom.Traversal
# @see        [DOM Level 2 `Node` Interface-Specification](http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/core.html#ID-1451460987)
# @see        [DOM Level 3 `Node` Interface-Specification](http://www.w3.org/TR/2004/REC-DOM-Level-3-Core-20040407/core.html#ID-1451460987)
# @see        [DOM Level 3 `NodeList` Interface-Specification](http://www.w3.org/TR/2004/REC-DOM-Level-3-Core-20040407/core.html#ID-536297177)
exports.Level2ChildNodes = \
class Level2ChildNodes extends Traversal

  # --------------------------------
  # Collect a single node's immediate child-nodes.
  #
  # @public
  # @method collect
  # @param  {Node}          node  The current node of the traversal.
  # @return {Array.<Node>}        An array of child-nodes.
  # @see    [`childNodes` Attribute-Documentation](https://developer.mozilla.org/de/docs/DOM/Node.childNodes)
  collect: (node) ->
    # We deliberately enforce equality instead of identity here.
    child for child in node.childNodes when `child.nodeType == Node.ELEMENT_NODE`

  # --------------------------------
  # Creates the `Traversal`-instance.
  #
  # @static
  # @public
  # @method create
  # @param  {Function}  callback  A function, called for each traversed node
  # @return {goatee.Dom.Traversal}
  @create: (callback) ->
    new Level2ChildNodes callback
