
#### Visitor

# A class providing a callback-method used during dom traversal.
# 
# @class
# @namespace goatee
exports.Visitor = class Visitor

  ##
  # @param {ProcessorManager}
  # @constructor
  constructor: (@manager) ->

  ##
  # Called for each element to process
  # @param {Node} node  The node to visit
  process: (node) ->
    # intentionally left blank
    # TODO implement node-visitor process
