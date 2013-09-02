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
  STRING_variables
  STRING_data
  STRING_with
}}                  = require '../../Core/Constants'

{UnorderedRules:{
  parse
}}                  = require '../../Map/UnorderedRules'

{Utility:{
  trim
}}                  = require '../../Core/Utility'

exports = module?.exports ? this

###
Javascript

@class
@namespace goatee.Action.Expression
###
exports.Javascript = class Javascript

  ##
  # Wrapper for @evaluateExpression() catching and logging any Exceptions
  # raised during expression evaluation to console.
  #
  # @param {String} expression
  # @return {Object|null}
  evaluate: (expression) ->
    try
      @evaluateExpression(expression)
    catch e
      console.log "Failed to evaluate “#{expression}”: #{e}"
    return null

  ##
  # Wrapper for the eval() builtin function to evaluate expressions and
  # obtain their value. It wraps the expression in parentheses such
  # that object literals are really evaluated to objects. Without the
  # wrapping, they are evaluated as block, and create syntax
  # errors. Also protects against other syntax errors in the eval()ed
  # code and returns null if the eval throws an exception.

  # @param {String} expression
  # @return {Object|null}
  evaluateExpression: (expression) ->
    ###
    NOTE(mesch): An alternative idiom would be:

      eval('(' + expr + ')');

    Note that using the square brackets as below, "" evals to undefined.
    The alternative of using parentheses does not work when evaluating
    function literals in IE.
    e.g. eval("(function() {})") returns undefined, and not a function
    object, in IE.

    NOTE(sjorek): Due to the underlying coffescript-specific language
    agnostics we deliberatly fall back to vanilla javascript here.
    ###
    return `eval('[' + expression + '][0]')`

  ##
  # Cache for jsEvalToFunction results.
  # @type {Object}
  _evaluateToFunctionCache = {}

  ##
  # Evaluates the given expression as the body of a function that takes
  # variables and data as arguments. Since the resulting function depends
  # only on expression, we cache the result so we save some Function
  # invocations, and some object creations in IE6.
  #
  # @param  {String}   expression A javascript expression.
  # @return {Function}            A function that returns the expression's value
  #                               in the context of variables and data.
  evaluateToFunction: (expression) ->
    return _evaluateToFunctionCache[expression] \
      unless _evaluateToFunctionCache[expression]?

    try
      # NOTE(mesch): The Function constructor is faster than eval().
      return _evaluateToFunctionCache[expression] = \
        Function STRING_variables, STRING_data, STRING_with + expression
    catch e
      console.log "Failed to evalaluate “#{expression}” to function: #{e}"
    return null

  ##
  # Evaluates the given expression to itself. This is meant to pass through
  # string action values.
  #
  # @param  {String} expression
  # @return {String}
  evaluateToSelf = (expression) ->
    return expression

  ##
  # Parses the value of the alter action in goatee-templates: splits it up into
  # a map of keys and expressions, and creates functions from the expressions
  # that are suitable for execution by @evaluateExpression(). All that is
  # returned as a flattened array of pairs of a String and a Function.
  #
  # @param  {String} expressions
  # @return {Array}
  evaluateToFunctions: (expressions) ->
    # TODO(mesch): It is insufficient to split the values by simply finding
    # semicolons, as the semicolon may be part of a string Constants or escaped.
    # TODO(sjorek): This does not look like coffescript … Das ist Doof :-)
    result = []
    for expression in expressions.split Constants.REGEXP_semicolon
      colon = expression.indexOf(Constants.CHAR_colon)
      continue if colon < 0
      key   = trim expression.substr(0, colon)
      value = @evaluateToFunction expression.substr(colon + 1)
      result.push(key, value)
    return result

  ##
  # Parses the value of the alter action in goatee-templates: splits it up into
  # a map of keys and expressions, and creates functions from the expressions
  # that are suitable for execution by @evaluateExpression(). All that is
  # returned as a flattened array of pairs of a String and a Function.
  #
  # Fixes the insufficient implementation of @evaluateToFunctions(expressions)
  #
  # @param  {String}         expressions
  # @param  {UnorderedRules} Optional instance populated with rules from
  #                          expressions. For internal use only.
  # @return {Array}
  evaluateToRules: (expressions, _rules) ->
    self    = @
    _rules  = parse expressions, _rules
    result  = []
    collect = (key, value, priority) ->
      result.push(key, self.evaluateToFunction value)
    _rules.each collect
    return result

  ##
  # Parses the value of the execute actions in goatee-templates: splits it up
  # into a list of expressions, and creates anonymous functions from the
  # expressions, hence closures, that are suitable for execution by
  # @evaluateExpression().
  #
  # All that is returned as an Array of Functions.
  #
  # @param {String} expressions
  # @return {Array.<Function>}
  evaluateToClosures: (expressions) ->
    @evaluateToFunction expression \
      for expression in expressions.split Constants.REGEXP_semicolon \
        when expression

##
# Reference to singleton instance
# @type {goatee.Action.Expression.Javascript}
_instance = Javascript.instance = null

##
# Singleton implementation
# @return {goatee.Action.Expression.Javascript}
Javascript.get = () ->
  _instance ? (_instance = new Javascript)
