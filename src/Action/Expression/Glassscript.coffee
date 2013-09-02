###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>  

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

Glass        = require 'glass-script'
{Constants}  = require 'goatee/Core/Constants'
{Utility}    = require 'goatee/Core/Utility'
{Javascript} = require 'goatee/Action/Expression/Javascript'

exports = module?.exports ? this

###
Glassscript

@class
@namespace goatee.Action.Expression
###
exports.Glassscript = class Glassscript extends Javascript

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
    (js = _expressionCache[expression] = Glass.parse(expression))
    super js

##
# Reference to singleton instance
# @type {goatee.Action.Expression.Glassscript}
_instance = Glassscript.instance = null

##
# Singleton implementation
# @return {goatee.Action.Expression.Glassscript}
Glassscript.get = () ->
  _instance ? (_instance = new Glassscript)
