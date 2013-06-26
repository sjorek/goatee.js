
DomNode = Node || require 'goatee/Dom/Node'

#### DomTraversal

# A class to hold state for a dom traversal.
# 
# @class
# @namespace goatee
exports.DomTraversal = class DomTraversal

  ##
  # @param {DomVisitor} A object, called on each node in the traversal.
  # @constructor
  constructor: (@visitor) ->

  ##
  # Processes the dom tree in breadth-first order.
  # @param {Node} root  The root node of the traversal.
  run: (root) ->
    @queue = [ root ]
    while (@queue.length > 0)
      @process(@queue.shift())

  ##
  # Processes a single node.
  # @param {Node} node  The current node of the traversal.
  process: (node) ->
    @visitor.process(node)

    child = node.firstChild
    while child
      @queue.push(child) if child.nodeType == DomNode.ELEMENT_NODE
      child = child.nextSibling
