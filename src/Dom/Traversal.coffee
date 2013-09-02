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

{Node} = require 'goatee/Dom/Node'

exports = module?.exports ? this

## Traversal

# An abstract class to hold state for a DOM traversal.
#
# @class
# @namespace goatee
exports.Traversal = class Traversal

  ##
  # @param {Function} callback A function, called on each node in the traversal.
  # @constructor
  constructor: (@callback) ->

  ##
  # Processes the dom tree in breadth-first order.
  # @param {Node} root  The root node of the traversal.
  # @return {goatee.Dom.Traversal}
  run: (root) ->
    @queue = [].concat(@prepare root)
    @process @queue.shift() while @queue.length > 0
    return this

  ##
  # Create processing queue for a single root node.
  #
  # @param  {Node}  node  The root node of the traversal.
  # @return {Array.<Node>}
  prepare: (root) ->
    if root.nodeType is Node.DOCUMENT_FRAGMENT_NODE
      return @collect root
    [ root ]

  ##
  # Processes a single node.
  # @param {Node}    node  The current node of the traversal.
  # @return {goatee.Dom.Traversal}
  process: (node) ->
    @callback(node)
    @queue = @queue.concat(@collect(node))
    return this

  ##
  # Processes a single node.
  # @param {Node}    node  The current node of the traversal.
  collect: (node) ->
    throw new Exception('Missing “collect”-method implementation')
