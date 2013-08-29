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

{Processor} = require 'goatee/Action/Processor'

Emitter     = require('goatee/Action/Emitter/DomEvents').DomEvents
#Emitter     = require('goatee/Action/Emitter/JqueryEvents').JqueryEvents
#Emitter     = require('goatee/Action/Emitter/NodejsEvents').NodejsEvents

exports = module?.exports ? this

## SelectorMap
# @class
# @namespace goatee.Action.Engine
exports.SelectorMap = class SelectorMap extends Processor

  _emitter       = null

  ##
  # @param {Node} The current node to process
  # @return {Array.<goatee.Action.Outer|goatee.Action.Inner>}
  collect: (node) ->
    (_emitter ? _emitter = Emitter.create this).collect(node)
