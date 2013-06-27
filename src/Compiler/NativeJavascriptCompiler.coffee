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



###
NativeJavascriptCompiler

@memberOf goatee
###
NativeJavascriptCompiler =

  ##
  # Wrapper for the eval() builtin function to evaluate expressions and
  # obtain their value. It wraps the expression in parentheses such
  # that object literals are really evaluated to objects. Without the
  # wrapping, they are evaluated as block, and create syntax
  # errors. Also protects against other syntax errors in the eval()ed
  # code and returns null if the eval throws an exception.
  
  # @param {String} expression
  # @return {Object|null}
  # @memberOf goatee.NativeJavascriptExpression
  evaluate: (expression) ->
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
  _cache: {}

  ##
  # Evaluates the given expression as the body of a function that takes
  # vars and data as arguments. Since the resulting function depends
  # only on expr, we cache the result so we save some Function
  # invocations, and some object creations in IE6.
  #
  # @param  {String}   expression A javascript expression.
  # @return {Function}            A function that returns the expression's value
  #                               in the context of variables and data.
  evalaluateToFunction: (expression) ->
    if (!NativeJavascriptCompiler._cache[expression]) {
      try
        # NOTE(mesch): The Function constructor is faster than eval().
        NativeJavascriptCompiler._cache[expression] = \
          new Function Constants.STRING_a, Constants.STRING_b, \
                       Constants.STRING_with + expression
      catch e
        console.log "evalaluateToFunction(#{expression}) throws exception #{e}"
    return NativeJavascriptCompiler._cache[expression];

  ##
  # Evaluates the given expression to itself. This is meant to pass
  # through string attribute values.
  #
  # @param {string} expression
  #
  # @return {string}
  #/
  evalualteToSelf: (expression) ->
    return expression

  ##
  # Parses the value of the alter action in goatee-templates: splits
  # it up into a map of labels and expressions, and creates functions
  # from the expressions that are suitable for execution by
  # NativeJavascriptCompiler.evaluate(). All that is returned as a flattened array
  # of pairs of a String and a Function.
  #
  # @param {String} expressions
  # @return {Array}
  evaluateToValues(expressions) {
    # TODO(mesch): It is insufficient to split the values by simply finding
    # semicolons, as the semicolon may be part of a string constant or escaped.
    ret = []
    values = expression.split Constants.REGEXP_semicolon
    for (var i = 0, I = values.length; i < I; ++i) {
      var colon = values[i].indexOf(Constants.CHAR_colon);
      if (colon < 0) {
        continue;
      }
      var label = stringTrim(values[i].substr(0, colon));
      var value = jsEvalToFunction(values[i].substr(colon + 1));
      ret.push(label, value);
    }
    return ret;
  }
  
  
  ##
  # Parses the value of the jseval attribute of jstemplates: splits it
  # up into a list of expressions, and creates functions from the
  # expressions that are suitable for execution by
  # NativeJavascriptCompiler.evaluate(). All that is returned as an Array of
  # Function.
  #
  # @param {String} expressions
  # @return {Array.<Function>}
  evaluateExpressions: (expressions) ->
    ret = []
    values = expressions.split Constants.REGEXP_semicolon
    for (var i = 0, I = jsLength(values); i < I; ++i) {
      if (values[i]) {
        var value = jsEvalToFunction(values[i]);
        ret.push(value);
      }
    }
    return ret;
  }
