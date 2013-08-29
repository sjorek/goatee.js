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

Coffee       = require 'coffee-script'
{Constants}  = require 'goatee/Core/Constants'
{Utility}    = require 'goatee/Core/Utility'
{Javascript} = require 'goatee/Action/Compiler/Javascript'

exports = module?.exports ? this

###
Coffeescript

@class
@namespace goatee.Action.Compiler
###
exports.Coffeescript = class Coffeescript extends Javascript

  ##
  # @param {Object} options
  # @constructor
  constructor: (options) ->
    @options = options ? {
      bare      : on
      inline    : on
      sourceMap : off
      shiftLine : off
    }

  ##
  # Cache for compiled expressions
  # @type {Object}
  _expressionCache = {}

  ##
  # Wrapper for the eval() builtin function to evaluate expressions and
  # obtain their value. It wraps the expression in parentheses such
  # that object literals are really evaluated to objects. Without the
  # wrapping, they are evaluated as block, and create syntax
  # errors. Also protects against other syntax errors in the eval()ed
  # code and returns null if the eval throws an exception.
  #
  # @param  {String} expression
  # @return {Object|null}
  evaluateExpression: (expression) ->
    (js = _expressionCache[expression])? or \
    (js = _expressionCache[expression] = Coffee.compile(expression, @options))
    super js

##
# Reference to singleton instance
# @type {goatee.Action.Compiler.Coffeescript}
_instance = Coffeescript.instance = null

##
# Singleton implementation
# @return {goatee.Action.Compiler.Coffeescript}
Coffeescript.get = () ->
  _instance ? (_instance = new Coffeescript)
