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

{Constants} = require 'goatee/Core/Constants'
{Node}      = require 'goatee/Core/Node'

#Traversal = require('goatee/Dom/Traversal/GeckoElementTraversal').GeckoElementTraversal
Traversal = require('goatee/Dom/Traversal/Level1NodeTypeMatcher').Level1NodeTypeMatcher
#Traversal = require('goatee/Dom/Traversal/Level2NodeIterator').Level2NodeIterator
#Traversal = require('goatee/Dom/Traversal/Level2TreeWalker').Level2TreeWalker
#Traversal = require('goatee/Dom/Traversal/Level4ChildNodesIterator').Level4ChildNodesIterator
#Traversal = require('goatee/Dom/Traversal/Level4ElementChildrenIterator').Level4ElementChildrenIterator

root = module?.exports ? this

## Document

# This implementation provides function shortcuts depending on a generic browser
# based DOM-Implementation
root.Document = Document =

  ##
  # @type {Document} Global target document reference.
  document: window?.document

  ##
  # @param  {String}    id
  # @param  {Document}  doc
  # @return {Node|null}
  getElementById: (id, doc) ->
    (doc || Document.document).getElementById(id)

  ##
  # Creates a new node in the given document
  #
  # @param {String} name  Name of new element (i.e. the tag name)..
  # @param {Document} doc  Target document.
  # @return {Element}  Newly constructed element.
  createElement: (name, doc) ->
    (doc || Document.document).createElement(name)

  ##
  # Traverses the element nodes in the DOM section underneath the given
  # node and invokes the given callback as a method on every element
  # node encountered.
  #
  # @param {Element} node  Parent element of the subtree to traverse.
  # @param {Function} callback  Called on each node in the traversal.
  traverseElements: (node, callback) ->
    Traversal.create(callback).run node
    return

  ##
  # Get an attribute from the DOM.  Simple redirect, exists to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to extract.
  # @return {String|null}  Resulting attribute.
  hasAttribute: if Element?::hasAttribute? \
    then (node, name) -> node.hasAttribute name \
    else (node, name) -> Document.getAttribute(name)?

  ##
  # Get an attribute from the DOM.  Simple redirect, exists to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to extract.
  # @return {String|null}  Resulting attribute.
  getAttribute: (node, name) ->
    node.getAttribute name
    # NOTE(mesch): Neither in IE nor in Firefox, HTML DOM attributes
    # implement namespaces. All items in the attribute collection have
    # null localName and namespaceURI attribute values. In IE, we even
    # encounter DIV elements that don't implement the method
    # getAttributeNS().

  ##
  # Set an attribute in the DOM.  Simple redirect to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to set.
  # @param {String|Number} value  Set attribute to this value.
  setAttribute: (node, name, value) ->
    node.setAttribute name, value
    return

  ##
  # Remove an attribute from the DOM.  Simple redirect to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to remove.
  removeAttribute: (node, name) ->
    node.removeAttribute(name)
    return

  ##
  # Get an data-attribute from the DOM.  Simple redirect, exists to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to extract.
  # @return {String|null}  Resulting data-attribute.
  hasData: (node, name) ->
    node.dataset[name]?

  ##
  # Get an data-attribute from the DOM.  Simple redirect, exists to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to extract.
  # @return {String|null}  Resulting data-attribute.
  getData: (node, name) ->
    node.dataset[name]

  ##
  # Set an data-attribute in the DOM.  Simple redirect to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to set.
  # @param {String|Number} value  Set data-attribute to this value.
  setData: (node, name, value) ->
    node.dataset[name] = value
    return

  ##
  # Remove an data-attribute from the DOM.  Simple redirect to compress code.
  #
  # @param {Element} node  Element to interrogate.
  # @param {String} name  Name of parameter to remove.
  removeData: (node, name) ->
    delete node.dataset[name]
    return

  ##
  # Clone a node in the DOM.
  #
  # @param {Node} node  Node to clone.
  # @return {Node}  Cloned node.
  cloneNode: (node) ->
    node.cloneNode true
    # NOTE(mesch): we never so far wanted to use cloneNode(false), hence we
    # default to true.

  ##
  # Clone a element in the DOM.
  #
  # @param {Element} element  Element to clone.
  # @return {Element}  Cloned element.
  cloneElement: (element) ->
    @cloneNode element

  ##
  # Returns the document owner of the given element. In particular,
  # returns window.document if node is null or the browser does not
  # support ownerDocument.  If the node is a document itself, returns
  # itself.
  #
  # @param {Node|null|undefined} node  The node whose ownerDocument is required.
  # @param {Document|null|undefined} node  The optional fallback value.
  # @returns {Document}  The owner document or window.document if unsupported.
  ownerDocument: (node, doc) ->
    return doc || Document.document if not node? # or \
      # we delibratly force equality instead of identity
      #`node.nodeType == Node.DOCUMENT_FRAGMENT_NODE`

    # we delibratly force equality instead of identity
    return node if `node.nodeType == Node.DOCUMENT_NODE`

    return node.ownerDocument || doc || Document.document

  ##
  # Creates a new text node in the given document.
  #
  # @param  {String}   text  Text composing new text node.
  # @param  {Document} doc  Target document.
  # @return {Text}     Newly constructed text node.
  createTextNode: (text, doc) ->
    (doc || Document.document).createTextNode text

  ##
  # Appends a new child to the specified (parent) node.
  #
  # @param  {Element} node   Parent element.
  # @param  {Node}    child  Child node to append.
  # @return {Node}    Newly appended node.
  appendChild: (node, child) ->
    node.appendChild child

  ##
  # Sets display to default.
  #
  # @param {Element} node  The dom element to manipulate.
  displayDefault: (node) ->
    node.style[Constants.CSS_display] = ''
    return

  ##
  # Sets display to none. Doing this as a function saves a few bytes for
  # the 'style.display' property and the 'none' literal.
  #
  # @param {Element} node  The dom element to manipulate.
  displayNone: (node) ->
    node.style[Constants.CSS_display] = 'none'
    return

  ##
  # Sets position style attribute to default.
  #
  # @param {Element} node  The dom element to manipulate.
  positionDefault: (node) ->
    node.style[Constants.CSS_position] = ''
    return

  ##
  # Sets position style attribute to absolute.
  #
  # @param {Element} node  The dom element to manipulate.
  positionAbsolute: (node) ->
    node.style[Constants.CSS_position] = 'absolute'
    return

  ##
  # Inserts a new child before a given sibling.
  #
  # @param  {Node} newChild  Node to insert.
  # @param  {Node} oldChild  Sibling node.
  # @return {Node} Reference to new child.
  insertBefore: (newChild, oldChild) ->
    oldChild.parentNode.insertBefore newChild, oldChild

  ##
  # Replaces an old child node with a new child node.
  #
  # @param  {Node}  newChild  New child to append.
  # @param  {Node}  oldChild  Old child to remove.
  # @return {Node}  Replaced node.
  replaceChild: (newChild, oldChild) ->
    oldChild.parentNode.replaceChild newChild, oldChild

  ##
  # Removes a node from the DOM.
  #
  # @param  {Node} node  The node to remove.
  # @return {Node} The removed node.
  removeNode: (node) ->
    Document.removeChild node.parentNode, node

  ##
  # Remove a child from the specified (parent) node.
  #
  # @param  {Element} node  Parent element.
  # @param  {Node}    child  Child node to remove.
  # @return {Node}    Removed node.
  removeChild: (node, child) ->
    node.removeChild child
