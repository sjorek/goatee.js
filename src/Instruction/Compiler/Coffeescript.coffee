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

constants = require 'goatee/Core/Constants'
utility   = require 'goatee/Core/Utility'

root = exports ? this

###
Javascript

@memberOf goatee.Instruction.Compiler
###
root.Javascript = class Javascript

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
    try
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
    catch e
      console.log "Failed to evaluate “#{expression}”: #{e}"
    return null

  ##
  # Cache for jsEvalToFunction results.
  # @type Object
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
        new Function constants.STRING_variables, constants.STRING_data, \
                     constants.STRING_with + expression
    catch e
      console.log "Failed to evalaluate “#{expression}” to function: #{e}"
    return null

  ##
  # Evaluates the given expression to itself. This is meant to pass through
  # string instruction values.
  #
  # @param  {String} expression
  # @return {String}
  evaluateToSelf = (expression) ->
    return expression

  ##
  # Parses the value of the alter instruction in goatee-templates: splits it up into
  # a map of keys and expressions, and creates functions from the expressions
  # that are suitable for execution by @evaluateExpression(). All that is
  # returned as a flattened array of pairs of a String and a Function.
  #
  # @param {String} expressions
  # @return {Array}
  evaluateToFunctions: (expressions) ->
    # TODO(mesch): It is insufficient to split the values by simply finding
    # semicolons, as the semicolon may be part of a string constant or escaped.
    # TODO(sjorek): This does not look like coffescript … Das ist Doof :-)
    result = []
    for expression in expressions.split constants.REGEXP_semicolon
      colon = expression.indexOf(constants.CHAR_colon)
      continue if colon < 0
      key   = utility.stringTrim expression.substr(0, colon)
      value = @evaluateToFunction expression.substr(colon + 1)
      result.push(key, value)
    return result

  ##
  # Parses the value of the execute instructions in goatee-templates: splits it up
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
      for expression in expressions.split constants.REGEXP_semicolon \
        when expression

##
# Reference to singleton instance
# @type {goatee.Instruction.Compiler.Javascript}
Javascript.instance = instance = null

##
# Singleton implementation
# @return {goatee.Instruction.Compiler.Javascript}
Javascript.get = () ->
  instance ? (instance = new Javascript)
