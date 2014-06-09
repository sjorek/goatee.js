###
© Copyright 2013-2014 Stephan Jorek <stephan.jorek@gmail.com>  

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
{Level1NodeTypeMatcher} = require '../Traversal'

#~ export
exports = module?.exports ? this

# ElementTraversal
# ================================

# --------------------------------
# A class to hold state for a DOM traversal.
#
# This implementation depends on the `ElementTraversal`-interface providing
# `node.firstElementChild` and `node.nextElementSibling`.
#
# @public
# @class      ElementTraversal
# @extends    goatee.Dom.Traversal
# @namespace  goatee.Dom.Traversal
# @see        [`firstElementChild` Interface-Specification](http://dom.spec.whatwg.org/#dom-parentnode-firstelementchild)
# @see        [`firstElementChild` Attribute-Specification](http://www.w3.org/TR/ElementTraversal/#attribute-firstElementChild)
# @see        [`nextElementSibling` Interface-Specification](http://dom.spec.whatwg.org/#dom-childnode-nextelementsibling)
# @see        [`nextElementSibling` Attribute-Specification](http://www.w3.org/TR/ElementTraversal/#attribute-nextElementSibling)
exports.ElementTraversal = \
class ElementTraversal extends Traversal

  # --------------------------------
  # Collect a single node's immediate child-nodes.
  #
  # @public
  # @method collect
  # @param  {Node}  node    The current node of the traversal
  # @return {Array.<Node>}
  # @see    [`firstElementChild` Documentation](https://developer.mozilla.org/en-US/docs/Web/API/ElementTraversal.firstElementChild)
  # @see    [`nextElementSibling` Documentation](https://developer.mozilla.org/en-US/docs/Web/API/ElementTraversal.nextElementSibling)
  collect: (node) ->
    result = []
    # Internet Explorer 6-8 supported it, but erroneously include Comment nodes.
    `for (var child = node.firstElementChild; child; child = child.nextElementSibling) {
        result.push(child);
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
    new GeckoElementTraversal callback
