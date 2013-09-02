###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>  
© Copyright 2006 Google Inc. <http://www.google.com>

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

{Constants:{
  CSS_display,
  CSS_position
}}                        = require '../Core/Constants'
{Node:{
  DOCUMENT_NODE #, DOCUMENT_FRAGMENT_NODE
}}                        = require './Node'

#!Traversal                 = require('./Traversal/GeckoElementTraversal').GeckoElementTraversal
Traversal                 = require('./Traversal/Level1NodeTypeMatcher').Level1NodeTypeMatcher
#!Traversal               = require('./Traversal/Level2NodeIterator').Level2NodeIterator
#!Traversal               = require('./Traversal/Level2TreeWalker').Level2TreeWalker
#!Traversal               = require('./Traversal/Level4ChildNodesIterator').Level4ChildNodesIterator
#!Traversal               = require('./Traversal/Level4ElementChildrenIterator').Level4ElementChildrenIterator

{Utility:{
  camelize,
  dashify
}}                        = require '../Core/Utility'

exports = module?.exports ? this

# Document (≠ DOMDocument)
# ================================

# --------------------------------
# This module provides shortcuts depending on generic- or browser-based
# DOM implementations.
#
# @public
# @module     Document
# @namespace  goatee.Core
# @author     Steffen Meschkat  <mesch@google.com>
# @author     Stephan Jorek     <stephan.jorek@gmail.com>
# @type       {Object}
exports.Document = Document =

  # --------------------------------
  # Global target document reference.  Defaults to `null` if `window.document`
  # is not available.
  #
  # @static
  # @public
  # @property document
  # @type     {Document}
  document: window?.document || null

  # --------------------------------
  # Get an element-node by its id
  #
  # @static
  # @public
  # @method   getElementById
  # @param    {DOMString}   id
  # @param    {Document}    [doc=Document.document]
  # @returns  {Node|null}
  getElementById: (id, doc) ->
    (doc || Document.document).getElementById(id)

  # --------------------------------
  # Creates a new node in the given document
  #
  # @static
  # @public
  # @method   createElement
  # @param    {DOMString} name                      The name of new element
  #                                                 (i.e. the tag name)
  # @param    {Document}  [doc=Document.document]   The target document
  # @return   {Element}                             A newly constructed element
  createElement: (name, doc) ->
    (doc || Document.document).createElement(name)

  # --------------------------------
  # Creates a new text node in the given document.
  #
  # @static
  # @public
  # @method createTextNode
  # @param  {DOMString} text                      Text composing new text node
  # @param  {Document}  [doc=Document.document]   The target document
  # @return {Text}                                A newly constructed text node
  createTextNode: (text, doc) ->
    (doc || Document.document).createTextNode text

  # --------------------------------
  # Traverses the element nodes in the DOM section underneath the given
  # node and invokes the given callback as a method on every element
  # node encountered.
  #
  # @static
  # @public
  # @method   traverseElements
  # @param    {Element}   node      Parent element of the subtree to traverse
  # @param    {Function}  callback  Called on each node in the traversal
  # @return   {goatee.Dom.Traversal}
  traverseElements: (node, callback) ->
    Traversal.create(callback).run node

  # --------------------------------
  # Test if an attribute exists.
  #
  # The implementation uses `Element.prototype.hasAttribute` if available,
  # otherwise it's a simple redirect to `Document.getAttribute`.
  #
  # @static
  # @public
  # @method hasAttribute
  # @param  {Element}         node  Element to interrogate
  # @param  {DOMString}       name  Name of parameter to extract
  # @return {DOMString|null}        Resulting attribute
  hasAttribute: if HTMLElement?::hasAttribute?
  then (node, name) -> node.hasAttribute name
  else (node, name) -> Document.getAttribute(node, name)?

  # --------------------------------
  # Get an attribute from the DOM.  Simple redirect to compress code.
  #
  # @static
  # @public
  # @method getAttribute
  # @param  {Element}         node  Element to interrogate
  # @param  {DOMString}       name  Name of parameter to extract
  # @return {DOMString|null}        Resulting attribute
  getAttribute: (node, name) ->
    # NOTE(mesch): Neither in IE nor in Firefox, HTML DOM attributes implement
    # namespaces.  All items in the attribute collection have `null` localName
    # and namespaceURI attribute values.  In IE, we even encounter DIV elements
    # that don't implement the method `getAttributeNS()`.
    node.getAttribute name

  # --------------------------------
  # Set an attribute in the DOM.  Simple redirect to compress code.
  #
  # @static
  # @public
  # @method setAttribute
  # @param  {Element}           node    Element to interrogate
  # @param  {DOMString}         name    Name of parameter to set
  # @param  {DOMString|Number}  value   Set attribute to this value
  setAttribute: (node, name, value) ->
    node.setAttribute name, value
    return

  # --------------------------------
  # Remove an attribute from the DOM.  Simple redirect to compress code.
  #
  # @static
  # @public
  # @method removeAttribute
  # @param  {Element}   node  Element to interrogate
  # @param  {DOMString} name  Name of parameter to remove
  removeAttribute: (node, name) ->
    node.removeAttribute(name)
    return

  # --------------------------------
  # Test if an data-attribute exists.
  #
  # This is the place to implement faster alternatives, i.e. by using
  # `hasAttribute` or the like.
  #
  # @static
  # @public
  # @method hasData
  # @param  {Element}   node  Element to interrogate
  # @param  {DOMString} name  Name of data-attribute to extract
  # @return {Boolean}         Flag indicating if the data-attribute exists
  hasData: if (_dataSetAvailable = HTMLElement?::dataset? and DOMStringMap?)
  then (node, name) ->
    node.dataset?[camelize name]?
  else (node, name) ->
    Document.hasAttribute node, "data-#{dashify name}"

  # --------------------------------
  # Get an data-attribute from the DOM.
  #
  # This is the place to implement faster alternatives, i.e. by using
  # `getAttribute` or the like.
  #
  # @static
  # @public
  # @method getData
  # @param  {Element}         node  Element to interrogate
  # @param  {DOMString}       name  Name of data-attribute to extract
  # @return {DOMString|null}        Resulting data-attribute
  getData: if _dataSetAvailable
  then (node, name) ->
    if node.dataset? then node.dataset[camelize name] else null
  else (node, name) ->
    Document.getAttribute node, "data-#{dashify name}"

  # --------------------------------
  # Set an data-attribute in the DOM.
  #
  # This is the place to implement faster alternatives, i.e. by using
  # `setAttribute` or the like.
  #
  # @static
  # @public
  # @method setData
  # @param  {Element}   node    Element to interrogate
  # @param  {DOMString} name    Name of data-attribute to set
  # @param  {DOMString} value   Set data-attribute to this value
  setData: if _dataSetAvailable
  then (node, name, value) ->
    node.dataset[camelize name] = value
    return
  else (node, name, value) ->
    Document.setAttribute node, "data-#{dashify name}", value
    return

  # --------------------------------
  # Remove an data-attribute from the DOM.
  #
  # This is the place to implement faster alternatives, i.e. by using
  # `removeAttribute` or the like.
  #
  # @static
  # @public
  # @method removeData
  # @param  {Element}   node  Element to interrogate
  # @param  {DOMString} name  Name of data-attribute to remove
  removeData: if _dataSetAvailable
  then (node, name) ->
    delete node.dataset[camelize name]
    return
  else (node, name) ->
    Document.removeAttribute node, "data-#{dashify name}"
    return

  # --------------------------------
  # Clone a node in the DOM.
  #
  # @static
  # @public
  # @method cloneNode
  # @param  {Node} node   Node to clone
  # @return {Node}        Cloned node
  cloneNode: (node) ->
    # NOTE(mesch): we never so far wanted to use `node.cloneNode(false);`,
    # hence we default to `true` (=deep clone).
    node.cloneNode true

  # --------------------------------
  # Clone a element in the DOM. Alias of `Document.cloneNode(node);` above.
  #
  # @static
  # @public
  # @method cloneElement
  # @param  {Element} element   Element to clone
  # @return {Element}           Cloned element
  cloneElement: (element) ->
    @cloneNode element

  # --------------------------------
  # Returns the document owner of the given element.  In particular, returns
  # `window.document` if node is null or the browser does not support the
  # `ownerDocument`-method.  Returns the node, if the node is a document itself.
  #
  # @static
  # @public
  # @method ownerDocument
  # @param  {Node}      [node]                    The node whose ownerDocument
  #                                               is requested
  # @param  {Document}  [doc=Document.document]   The optional fallback-value
  # @return {Document}                            The owner-document or if
  #                                               unsupported `window.document`
  ownerDocument: (node, doc) ->
    # TODO: What about document-fragment-nodes ?
    return doc || Document.document if not node? # …
    #!… or `node.nodeType == DOCUMENT_FRAGMENT_NODE`

    # We deliberately enforce equality instead of identity here.
    return node if `node.nodeType == DOCUMENT_NODE`

    return node.ownerDocument || doc || Document.document

  # --------------------------------
  # Appends a new child to the specified (parent) node.
  #
  # @static
  # @public
  # @method appendChild
  # @param  {Element} node    The parent element
  # @param  {Node}    child   The child-node to append
  # @return {Node}            The newly appended node
  appendChild: (node, child) ->
    node.appendChild child

  # --------------------------------
  # Sets display to default.
  #
  # @static
  # @public
  # @method displayDefault
  # @param  {Element} node  The DOM element to manipulate
  displayDefault: (node) ->
    node.style[CSS_display] = ''
    return

  # --------------------------------
  # Sets display to none.  Doing this as a function saves a few bytes for
  # the 'style.display' property and the 'none' literal.
  #
  # @static
  # @public
  # @method displayNone
  # @param  {Element} node  The DOM element to manipulate
  displayNone: (node) ->
    node.style[CSS_display] = 'none'
    return

  # --------------------------------
  # Sets position style attribute to default.
  #
  # @static
  # @public
  # @method positionDefault
  # @param  {Element} node  The DOM element to manipulate
  positionDefault: (node) ->
    node.style[CSS_position] = ''
    return

  # --------------------------------
  # Sets position style attribute to absolute.
  #
  # @static
  # @public
  # @method positionAbsolute
  # @param  {Element} node  The DOM element to manipulate
  positionAbsolute: (node) ->
    node.style[CSS_position] = 'absolute'
    return

  # --------------------------------
  # Inserts a new child before a given sibling.
  #
  # @static
  # @public
  # @method insertBefore
  # @param  {Node} newChild   The node to insert
  # @param  {Node} oldChild   The sibling node
  # @return {Node}            A reference to the new child
  insertBefore: (newChild, oldChild) ->
    oldChild.parentNode.insertBefore newChild, oldChild

  # --------------------------------
  # Replaces an old child node with a new child node.
  #
  # @static
  # @public
  # @method replaceChild
  # @param  {Node}  newChild  The new child to append
  # @param  {Node}  oldChild  The old child to remove
  # @return {Node}            The replaced node
  replaceChild: (newChild, oldChild) ->
    oldChild.parentNode.replaceChild newChild, oldChild

  # --------------------------------
  # Removes a node from the DOM.
  #
  # @static
  # @public
  # @method removeNode
  # @param  {Node}  node  The node to remove
  # @return {Node}        The removed node
  removeNode: (node) ->
    Document.removeChild node.parentNode, node

  # --------------------------------
  # Remove a child from the specified (parent) node.
  #
  # @static
  # @public
  # @method removeChild
  # @param  {Element} node    The parent element
  # @param  {Node}    child   The child-node to remove
  # @return {Node}            The removed node
  removeChild: (node, child) ->
    node.removeChild child
