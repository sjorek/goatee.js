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
  DOCUMENT_FRAGMENT_NODE
}} = require 'goatee/Dom/Node'

exports = module?.exports ? this

# Traversal
# ================================

# --------------------------------
# An abstract class to hold state for a DOM traversal.
#
# @abstract
# @public
# @class Traversal
# @namespace goatee.Dom
exports.Traversal = class Traversal

  # --------------------------------
  #
  # @param  {Function}  callback  A function, called for each traversed node.
  # @constructor
  constructor: (@callback) ->

  # --------------------------------
  # Processes the DOM tree in breadth-first order.
  #
  # @public
  # @method run
  # @param  {Node}  root  The root node of the traversal.
  # @return {goatee.Dom.Traversal}
  run: (root) ->
    @queue = @prepare root
    @queue = @process @queue.shift() while @queue.length > 0
    return this

  # --------------------------------
  # Create processing queue for a single root node.
  #
  # @public
  # @method prepare
  # @param  {Node}  node  The root node of the traversal.
  # @return {Array.<Node>}
  prepare: (root) ->
    # We deliberately enforce equality instead of identity here.
    if `root.nodeType == DOCUMENT_FRAGMENT_NODE`
      return @collect root
    [ root ]

  # --------------------------------
  # Processes a single node.
  #
  # @public
  # @method process
  # @param  {Node}  node  The current node of the traversal.
  # @return {Array.<Node>}
  process: (node) ->
    @callback(node)
    @queue.concat @collect node

  # --------------------------------
  # Collect a single node's immediate child-nodes.
  #
  # @abstract
  # @public
  # @method collect
  # @param  {Node}  node    The current node of the traversal.
  # @return {Array.<Node>}
  # @throws {Exception}     If “collect”-method implementation is missing.
  collect: (node) ->
    throw new Exception('Missing “collect”-method implementation')
