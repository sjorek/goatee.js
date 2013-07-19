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

root = module?.exports ? this

##
# @class
# @namespace goatee.Action.Expression.Compiler.Goateescript
root.Expression = (global.goatee ?= {}).Expression = class Expression

  # global will not just reference the original context from any expression
  _global             = undefined
  _variables          = null
  _errors             = null
  _stack              = null
  _scope              = null
  _current            = -> _stack?[_stack.length - 1]
  _parent             = -> _stack?[_stack.length - 2]
  _isExpression       = (obj) -> _.isFunction obj?.evaluate
  _isRightReference   = ->
    p = _parent()
    p? and p.operator.name is '.' and p.parameters[1] is _current()

  Expression.evaluate = _evaluate = (context={}, expression) ->
    return expression unless _isExpression expression
    isGlobalScope = _global is undefined
    if isGlobalScope
      _global    = context
      _errors    = null
      _variables = {}
      _stack     = []
      _scope     = []

    _stack.push expression
    _scope.push context
    try
      result = _process context, expression
    catch e
      (_errors ?= []).push e
    finally
      if isGlobalScope
        _global = undefined
      _stack.pop()
      _scope.pop()
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
        return op.evaluate.call context, context, e(context, right)

    if op.evaluateParameters != false
      values = (_evaluate context, p for p in params)
    else
      values = params
    op.evaluate.apply context, values

  Expression.operations = _operations =
    '=':  #  assignment
      evaluate: (a,b) ->
        _variables[a] = b
    '.':
      chain: true
      #  functions must be bound to their container now or else they would have the global as their context.
      evaluate: (a,b) -> if a != global and _.isFunction b then b.bind a else b
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
    '/':
      constant: true
      evaluate: (a,b) -> a / b
    '%':
      constant: true
      evaluate: (a,b) -> a % b
    '&&':
      evaluateParameters: false
      constant: true
      evaluate: (a,b) ->
        a = _evaluate this, a
        if not a
          return a
        b = _evaluate this, b
        return b
    '||':
      evaluateParameters: false
      constant: true
      evaluate: (a,b) ->
        a = _evaluate this, a
        if a
          return a
        b = _evaluate this, b
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
      evaluate: (a, b, c) ->
        a = _evaluate this, a
        if toBoolean a
          _evaluate this, b
        else
          _evaluate this, c
    #'$':
    #  format: -> '$'
    #  vector: false
    #  evaluate: -> _global
    #'@':
    #  format: -> '@'
    #  vector: false
    #  evaluate: -> this
    '()':
      vector: false
      format: (func) ->
        return func + '(' + Array.prototype.slice.call(arguments, 1).join(',') + ')'
      evaluate: (func) ->
        return func?.apply(this, Array.prototype.slice.call(arguments, 1))
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
      evaluate: (a, b) -> if toBoolean b then a else undefined
    context:
      format: (a) -> a
      vector: false
      evaluate: (a) -> { '$':_global, '@':@ }[a]
    reference:
      format: (a) -> a
      vector: false
      evaluate: (a) ->
        if _isRightReference()
          if this.hasOwnProperty a
            value = this[a]
        else
          if _variables.hasOwnProperty a
            value = _variables[a]
          else
            value = this[a]
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
    #    if Array.isArray this
    #      _.clone this
    #    else
    #      _.values this
    primitive:
      constant: true
      vector: false
      format: (a) -> JSON.stringify a
      evaluate: (a) -> a
    block:
      format: ->
        b = ['{ ']
        for arg in arguments
          b.push arg.toString(), '; '
        b.push '}'
        b.join ''
      evaluate: -> arguments[arguments.length-1]
    if:
      evaluateParameters: false
      format: (a, b, c) ->
        if c?
          "if (#{a}) #{b} else #{c}"
        else
          "if (#{a}) #{b}"
      evaluate: (a, b, c) ->
        a = _evaluate this, a
        if toBoolean a
          _evaluate this, b
        else if c?
          _evaluate this, c
        else
          undefined
    for:
      evaluateParameters: false
      format: (a, b) -> "for (#{a}) { #{b} }"
      evaluate: (a, b) ->
        a = _evaluate this, a
        return undefined unless a?
        for value in _.values a
          _evaluate value, b
    array:
      format: -> "[#{(arg for arg in arguments).join ','}]"
      evaluate: -> arg for arg in arguments
    object:
      format: ->
        buffer = []
        buffer.push '{'
        i = 0
        while i < arguments.length
          if (i > 0)
            buffer.push ','
          buffer.push arguments[i]
          buffer.push ':'
          buffer.push arguments[i+1]
          i += 2
        buffer.push '}'
        buffer.join ''
      evaluate: ->
        object = {}
        i = 0
        while i < arguments.length
          object[arguments[i]] = arguments[i+1]
          i += 2
        object

  do ->
    for key, value of _operations
      value.name = key
      value.toString = do -> k = key; -> k
      value.toJSON = -> @name
    return

  Expression.operator = _operator = (name) ->
    return op if (op = _operations[name])?
    throw new Error "operation not found: #{name}"

  Expression.booleanize = _booleanize = (value) ->
    if Array.isArray value
      for item in value
        if toBoolean item
          return true
      return false
    return Boolean value

  Expression.stringify = _stringify = (value) ->
    if not _isExpression value
      return JSON.stringify value

    format = value.operator.format
    if format?
      return format.apply this, value.parameters
    else if value.parameters.length == 2
      return '(' + _stringfy(value.parameters[0]) + value.operator +
                   _stringfy(value.parameters[1]) + ')'
    else
      return value.parameters.map(_stringfy).join ' '

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
    return @text = _stringify this if @text is undefined
    @text

  ##
  # @return Object.<String:op,Array:parameters>
  toJSON: ->
    {op:@operator.name, parameters:@parameters};

  ##
  # @param {Object} context
  # @return mixed
  evaluate: (context) ->
    _evaluate context, @
