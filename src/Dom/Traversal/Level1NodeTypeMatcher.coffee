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
  ELEMENT_NODE
}}              = require '../Node'
{Traversal}     = require '../Traversal'

exports = module?.exports ? this

## Level1NodeTypeMatcher

# A class to hold state for a dom traversal.
#
# @class
# @namespace goatee
exports.Level1NodeTypeMatcher = \
class Level1NodeTypeMatcher extends Traversal

  ##
  # Processes a single node.
  # @param  {Node}          node  The current node of the traversal.
  # @return {Array.<Node>}        An array of child-nodes.
  collect: (node) ->
    result = []
    `for (var child = node.firstChild; child; child = child.nextSibling) {
        if (child.nodeType == ELEMENT_NODE) {
          result.push(child);
        }
      }`
    return result

Level1NodeTypeMatcher.create = (callback) ->
  new Level1NodeTypeMatcher callback
