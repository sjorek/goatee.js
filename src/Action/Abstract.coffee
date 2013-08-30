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

exports = module?.exports ? this

## Abstract
#
# Abstract action class implementing a basic action
#
# @class Abstract
# @namespace goatee.Action
exports.Abstract = class Abstract

  ##
  # Derivates must override this method and perform the action.
  #
  # @abstract
  # @public
  # @method process
  # @param  {Processor} action      The calling action
  # @param  {Context}   context     The current evaluation context
  # @param  {Node}      template    The currently processed node of the template
  # @param  {Function}  attribute   Processed value of the content attribute
  # @return {Boolean}
  # @throws {Exception}
  process: (action, context, template, attribute) ->
    throw new Exception 'Derivates must override this method'
    return
