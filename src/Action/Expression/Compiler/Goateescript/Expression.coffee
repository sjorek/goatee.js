###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>

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

global = do -> this
_ = global._ ? require 'underscore'

{Stack} = require './Stack'

root = module?.exports ? this

##
# @class
# @namespace goatee.Action.Expression.Compiler.Goateescript
root.Expression = (global.goatee ?= {}).Expression = class Expression

  _stack              = undefined
  _scope              = null
  _errors             = null
  _global             = null
  _variables          = null
  _operations         = null
  _isExpression       = (obj) -> _.isFunction obj?.evaluate
  _isRightReference   = ->
    p = _stack.parent()
    p? and p.operator.name is '.' and p.parameters[1] is _stack.current()

  Expression.evaluate = _evaluate = (context={}, expression) ->
    return expression unless _isExpression expression

    isGlobalScope = _stack is undefined
    if isGlobalScope
      _stack     = new Stack(context)
      _scope     = _stack.scope
      _errors    = null
      _global    = _stack.global
      _variables = _stack.variables

    _stack.push context, expression

    try
      result = _process context, expression
    catch e
      (_errors ?= []).push e
    finally
      _stack.pop()
      if isGlobalScope
        _stack.destructor()
        _stack     = undefined
        _scope     = null
        _global    = null
        _variables = null
    console.log '_errors', _errors if _errors?
    result

  _process = (context, expression) ->
    op = expression.operator
    params = expression.parameters
    if op.chain
      throw new Error 'chain only supports 2 parameters' unless params.length is 2
      left = params[0]
      right = params[1]
      context = _evaluate context, left

      if left.vector
        values = []
        for leftValue in context
          rightValue = _evaluate leftValue, right
          value = op.evaluate.call leftValue, leftValue, rightValue
          #  see if the right part of the operation is vector or not
          if right.vector
            if not Array.isArray value
              throw new Error 'vector operation did not return an array as expected: ' + JSON.stringify op
            values.push.apply values, value
          else if value?
            values.push value
        return values
      else
        return op.evaluate.call context, context, _evaluate(context, right)

    if op.evaluateParameters != false
      values = (_evaluate context, p for p in params)
    else
      values = params
    op.evaluate.apply context, values

  Expression.booleanize = _booleanize = (value) ->
    if Array.isArray value
      for item in value
        if _booleanize item
          return true
      return false
    return Boolean value

  Expression.stringify = _stringify = (value) ->
    if not _isExpression value
      return JSON.stringify value

    {operator,parameters} = value
    {format}              = operator

    if format?
      return format.apply @, parameters
    else if parameters.length == 2
      return "(#{_stringify(parameters[0])}#{operator}#{_stringify(parameters[1])})"
    else
      return parameters.map(_stringify).join ' '

  # TODO Move to Scope !
  Expression.operations = _operations =
    '=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = b
    '-=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) - b
    '+=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) + b
    '*=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) * b
    '/=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) / b
    '%=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) % b
    '^=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) ^ b
    '>>>=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) >>> b
    '>>=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) >> b
    '<<=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) << b
    '&=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) & b
    '|=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = _operations.reference.evaluate(a) | b
    '.':
      chain: true
      #  functions must be bound to their container now or else they would have the global as their context.
      evaluate: (a,b) ->
        if a isnt _global and _.isFunction b then b.bind a else b
    '+':
      constant: true
      evaluate: (a,b) -> a + b
    '-':
      constant: true
      evaluate: (a,b) -> a - b
    '*':
      constant: true
      evaluate: (a,b) -> a * b
    '!':
      constant: true
      evaluate: (a) -> !a
    '~':
      constant: true
      evaluate: (a) -> ~a
    '/':
      constant: true
      evaluate: (a,b) -> a / b
    '%':
      constant: true
      evaluate: (a,b) -> a % b
    '^':
      constant: true
      evaluate: (a,b) -> a ^ b
    '>>>':
      constant: true
      evaluate: (a,b) -> a >>> b
    '>>':
      constant: true
      evaluate: (a,b) -> a >> b
    '<<':
      constant: true
      evaluate: (a,b) -> a << b
    '&':
      constant: true
      evaluate: (a,b) -> a & b
    '|':
      constant: true
      evaluate: (a,b) -> a | b
    '&&':
      evaluateParameters: false
      constant: true
      evaluate: (a,b) ->
        a = _evaluate @, a
        if not a
          return a
        b = _evaluate @, b
        return b
    '||':
      evaluateParameters: false
      constant: true
      evaluate: (a,b) ->
        a = _evaluate @, a
        if a
          return a
        b = _evaluate @, b
        return b
    '<':
      constant: true
      vector: false
      evaluate: (a,b) -> a < b
    '>':
      constant: true
      vector: false
      evaluate: (a,b) -> a > b
    '<=':
      constant: true
      vector: false
      evaluate: (a,b) -> a <= b
    '>=':
      constant: true
      vector: false
      evaluate: (a,b) -> a >= b
    '==':
      constant: true
      vector: false
      expandParameters: false
      evaluate: (a,b) ->
        return a.contains b if Array.isArray a
        return b.contains a if Array.isArray b
        return `a == b`
    '!=':
      constant: true
      vector: false
      expandParameters: false
      evaluate: (a,b) ->
        return not a.contains b if Array.isArray a
        return not b.contains a if Array.isArray b
        return `a != b`
    '===':
      constant: true
      vector: false
      evaluate: (a,b) -> `a === b`
    '!==':
      constant: true
      vector: false
      evaluate: (a,b) -> `a !== b`
    '?:':
      constant: true
      evaluateParameters: false
      vector: false
      format: (a, b, c) ->
        "(#{_stringify(a)}?#{_stringify(b)}:#{_stringify(c)})"
      evaluate: (a, b, c) ->
        a = _evaluate @, a
        if _booleanize a then _evaluate @, b else _evaluate @, c
    #'$':
    #  format: -> '$'
    #  vector: false
    #  evaluate: -> _global
    #'@':
    #  format: -> '@'
    #  vector: false
    #  evaluate: -> @
    '()':
      vector: false
      format: (func) ->
        func + '(' + Array.prototype.slice.call(arguments, 1).join(',') + ')'
      evaluate: (func) ->
        throw new Error "Missing reference to call." if not func?
        throw new Error "Reference is not callable." if not func.apply?
        func.apply @, Array.prototype.slice.call(arguments, 1)
    '[]':
      chain: false
      vector: false
      format: (a,b) -> "#{a}[#{b}]"
      evaluate: (a, b) ->
        #  support negative indexers, if you literally want "-1" then use a string literal
        if _.isNumber(b) and b < 0
          b = (a.length ? 0) + b
        a[b]
    '{}':
      chain: true
      vector: false
      format: (a,b) -> "#{a}{#{b}}"
      evaluate: (a, b) -> if _booleanize b then a else undefined
    context:
      format: (a) -> a
      vector: false
      evaluate: (a) ->
        { '$':_global, '@':_variables }[a]
    reference:
      format: (a) -> a
      vector: false
      evaluate: (a) ->
        ref = _isRightReference()
        if ref
          if @.hasOwnProperty a
            value = @[a]
        else
          if _variables.hasOwnProperty a
            value = _variables[a]
          else
            value = @[a]
            #  walk the context stack from top to bottom looking for value
            index = _scope.length - 1
            while index >= 0
              context = _scope[index]
              if context.hasOwnProperty a
                value = context[a]
                break
              index--
        value
    #children:
    #  format: -> '*'
    #  vector: true
    #  #watch: (object, expression, handler, connect) -> gl_as.watch object, handler, connect
    #  evaluate: () ->
    #    if Array.isArray @
    #      _.clone @
    #    else
    #      _.values @
    primitive:
      constant: true
      vector: false
      format: (a) -> JSON.stringify a
      evaluate: (a) -> a
    block:
      format: (statements...) -> "{#{statements.join ';'}}"
      evaluate: ->
        arguments[arguments.length-1]
    if:
      evaluateParameters: false
      format: (a, b, c) ->
        if c?
          "if (#{a}) #{b} else #{c}"
        else
          "if (#{a}) #{b}"
      evaluate: (a, b, c) ->
        a = _evaluate @, a
        if _booleanize a
          _evaluate @, b
        else if c?
          _evaluate @, c
        else
          undefined
    #for:
    #  evaluateParameters: false
    #  format: (a, b) -> "for (#{a}) { #{b} }"
    #  evaluate: (a, b) ->
    #    a = _evaluate @, a
    #    return undefined unless a?
    #    for value in _.values a
    #      _evaluate value, b
    array:
      format  : (elements...) -> "[#{elements.join ','}]"
      evaluate: (elements...) -> elements
    object:
      format: ->
        buffer = []
        i = 0
        l = arguments.length
        while i < l
          buffer.push "#{arguments[i]}:#{arguments[i+1]}"
          i += 2
        "{#{buffer.join ','}}"
      evaluate: ->
        object = {}
        i = 0
        l = arguments.length
        while i < l
          object[arguments[i]] = arguments[i+1]
          i += 2
        object

  do ->

    _format = _operations.reference.format

    for key, value of _operations
      value.name = key
      value.toString = do -> k = key; -> k
      value.toJSON = ->
        @name
      if not value.format? and key[key.length - 1] is "="
          value.format = do -> k = key; (a,b) -> "(#{_format(a)}#{k}#{_stringify(b)})"
    return

  Expression.operator = _operator = (name) ->
    return op if (op = _operations[name])?
    throw new Error "operation not found: #{name}"

  ##
  # @param {Array.<>} context
  # @return void
  # @constructor
  constructor: (op, params=[]) ->
    @operator = _operator(op)
    @parameters = params

    #  is this expression a constant?
    @constant = @operator.constant is true
    if @constant
      for param in params
        if _isExpression(param) and not param.constant
          @constant = false
          break

    #  does this expression yield a vector result?
    @vector = @operator.vector
    if @vector is undefined
      @vector = false     #   assume false
      for param in params
        if _isExpression(param) and param.vector    #   if the parameter has a vector quantity then the result is a vector result
          @vector = true
          break

    #  if this expression is a constant then we pre-evaluate it now
    #  and just return a primitive expression with the result
    if @constant and @operator.name isnt 'primitive'
      return new Expression 'primitive', [ @evaluate global ]

    #  otherwise return this expression
    return

  ##
  # @return String
  toString: ->
    return @text unless @text is undefined
    @text = _stringify(@)

  ##
  # @return Object.<String:op,Array:parameters>
  toJSON: ->
    {op:@operator.name, parameters:@parameters};

  ##
  # @param {Object} context
  # @return mixed
  evaluate: (context) ->
    _evaluate context, @
