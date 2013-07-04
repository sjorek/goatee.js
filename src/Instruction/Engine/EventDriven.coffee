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

Emitter = 'goatee/Instruction/Emitter/DomEvents'
#Emitter = 'goatee/Instruction/Emitter/JqueryEvents'
#Emitter = 'goatee/Instruction/Emitter/NodejsEvents'

root = exports ? this

## EventDriven
# @class
# @namespace goatee.Instruction.Processor
root.EventDriven = class EventDriven

  _emitter       = null

  ##
  # @param {Node} The current node to process
  # @return {Array.<goatee.Instruction.Outer|goatee.Instruction.Inner>}
  collect: (node) ->
    (_emitter ? _emitter = Emitter.create this).collect(node)
