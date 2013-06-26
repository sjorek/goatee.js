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


#### Action

# A abstract class implementing a basic action 
# 
# @class
# @namespace goatee
exports.Action = class Action

  ##
  # Derivates must implement this method to perform the action.
  #
  # @param {Processor}  processor   The calling processor
  # @param {Context}    context     The current evaluation context
  # @param {Node}       template    The currently processed node of the template
  # @param {Function}   attribute   Processed value of the content attribute
  # @return Boolean
  process: (processor, context, template, attribute) ->
    throw new Exception 'Missing “process”-method implementation'
    return
