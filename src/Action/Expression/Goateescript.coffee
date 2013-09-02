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

Script       = require('goatee-script').GoateeScript
Rules        = require('goatee-rules').GoateeRules
{Constants}  = require 'goatee/Core/Constants'
{Utility}    = require 'goatee/Core/Utility'
{Javascript} = require 'goatee/Action/Expression/Javascript'

exports = module?.exports ? this

###
Goateescript

@class
@namespace goatee.Action.Expression
###
exports.Goateescript = class Goateescript extends Javascript

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
    super Script.compile(expression)

##
# Reference to singleton instance
# @type {goatee.Action.Expression.Goateescript}
_instance = Goateescript.instance = null

##
# Singleton implementation
# @return {goatee.Action.Expression.Goateescript}
Goateescript.get = () ->
  _instance ? (_instance = new Goateescript)
