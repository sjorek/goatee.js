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

Constants = require 'goatee/Core/Constants'

root = exports ? this

## Context

# Context for processing a goatee-template. The context contains a context
# object, whose properties can be referred to in goatee-template expressions,
# and it holds the locally defined variables.
#
root.Context = class Context

  # Holds all global context variables
  _globals   = {}

  # Holds this context's local variables
  _variables : {}
  
  # Holds this context's data
  _data      : Constants.STRING_empty

  ##
  # @param {Object|null} data   The context object. Null if no context.
  # @param {Object|null} parent The parent context, from which local variables
  #                             are inherited. Normally the context object of
  #                             the parent context is the object whose property
  #                             the parent object is. Null for the root-context.
  # @constructor
  constructor: (data, parent) ->

    # If there is a parent node, inherit local variables from the parent. If a
    # root node, inherit global symbols. Since every parent chain has a root
    # with no parent, global variables will be present in the case above too.
    # This means that globals can be overridden by locals, as it should be.
    variables = parent?._variables ? _globals
    for own property, value of variables
      @_variables[property] = value

    # The current context object is assigned to the special variable
    # $this so it is possible to use it in expressions.
    @_variables[Constants.VAR_this] = data

    # The entire context structure is exposed as a variable so it can be
    # passed to javascript invocations through the execute action.
    @_variables[Constants.VAR_context] = this

    # The local context of the input data in which the goatee-template
    # expressions are evaluated. Notice that this is usually an Object,
    # but it can also be a scalar value (and then still the expression
    # $this can be used to refer to it). Notice this can even be value,
    # undefined or null. Hence, we have to protect jsexec() from using
    # undefined or null, yet we want $this to reflect the true value of
    # the current context. Thus we assign the original value to $this,
    # above, but for the expression context we replace null and
    # undefined by the empty string.
    #
    # (Note sjorek: “undefined” isn't checked here on purpose,
    # @see https://github.com/jashkenas/coffee-script/issues/993 )
    @_data = data if data?
