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
}}              = require '../Node'

{Traversal}     = require '../Traversal'

# ~export
exports = module?.exports ? this

# Level1NodeTypeMatcher
# ================================

# --------------------------------
# A class to hold state for a DOM traversal.
#
# This implementation depends on *DOM Level ≥ 1 Core* providing
# `node.firstChild` and `node.nextChild`.
#
# @public
# @class      Level1NodeTypeMatcher
# @extends    goatee.Dom.Traversal
# @namespace  goatee.Dom.Traversal
exports.Level1NodeTypeMatcher = \
class Level1NodeTypeMatcher extends Traversal

  # --------------------------------
  # Collect a single node's immediate child-nodes.
  #
  # @public
  # @method collect
  # @param  {Node}  node    The current node of the traversal
  # @return {Array.<Node>}
  # @see    [`firstChild` Attribute-Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Node.firstChild)
  # @see    [`nextSibling` Attribute-Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Node.nextSibling)
  collect: (node) ->
    result = []
    # We deliberately enforce equality instead of identity here.
    `for (var child = node.firstChild; child; child = child.nextSibling) {
        if (child.nodeType == ELEMENT_NODE) {
          result.push(child);
        }
      }`
    return result

  # --------------------------------
  # Creates the `Traversal`-instance.
  #
  # @static
  # @public
  # @method create
  # @param  {Function}  callback  A function, called for each traversed node
  # @return {goatee.Dom.Traversal}
  @create: (callback) ->
    new Level1NodeTypeMatcher callback
