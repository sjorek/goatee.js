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

{Node}                  = require 'goatee/Core/Node'
{Level1NodeTypeMatcher} = require 'goatee/Dom/Traversal/Level1NodeTypeMatcher'

root = exports ? this

#### Level4ElementChildNodesList

# A class to hold state for a dom traversal.
#
# @class
# @namespace goatee
root.Level4ChildNodesIterator = \
class Level4ChildNodesIterator extends Level1NodeTypeMatcher

  ##
  # Collect children of the current node of the traversal
  # @param {Node}    node  The current node of the traversal.
  collect: (node) ->
    child for child in node.childNodes when `child.nodeType == Node.ELEMENT_NODE`

Level4ChildNodesIterator.create = (callback) ->
  new Level4ChildNodesIterator callback
