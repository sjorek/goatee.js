###
© Copyright 2013 [Stephan Jorek](stephan.jorek@gmail.com)

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

{Level1NodeTypeMatcher} = require 'goatee/Dom/Traversal/Level1NodeTypeMatcher'

exports = module?.exports ? this

## GeckoElementTraversal

# A class to hold state for a dom traversal.
#
# @class
# @namespace goatee
exports.GeckoElementTraversal = \
class GeckoElementTraversal extends Level1NodeTypeMatcher

  ##
  # Processes a single node.
  # @param {Node}    node  The current node of the traversal.
  collect: (node) ->
    result = []
    `for (var child = node.firstElementChild; child; child = child.nextElementSibling) {
        result.push(child);
      }`
    return result

GeckoElementTraversal.create = (callback) ->
  new GeckoElementTraversal callback
