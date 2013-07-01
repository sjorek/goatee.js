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

constant  = require 'goatee/Core/Constants'
doc       = require 'goatee/Dom/Document'

InMemory  = require 'goatee/Core/InstructionCache/InMemory'

root = exports ? this

## DomElementAttribute
# Internal class used by goatee-templates to cache actions.
# @class
# @constructor
root.DomElementAttribute = class DomElementAttribute extends InMemory

  add: (node, id, value) ->
    dom.setAttribute(node, constant.ATT_jstcache, id)
    super(id, value)
    return

  has: (node) ->
    dom.hasAttribute(node, constant.ATT_jstcache)

  get: (node) ->
    id = dom.getAttribute(node, constant.ATT_jstcache)
    super(id)

  set: (node, value) ->
    id = dom.getAttribute(node, constant.ATT_jstcache)
    super(id, value)
    return
