

root = exports ? this


root.WithStatementFunction = class WithStatementFunction
  _cache: {}

  bind: (expression, scope...) ->
    @_cache[expression] || @_cache[expression] = @build code, scope

  build: (expression, scope) ->
    code = "return #{expression}"
    args = for index, object in scope
      name = "__scope#{index}__"
      code = "with(#{name}) { #{code} }"
      name
    @compile args, code

  compile: (args, code) ->
    args.push(code)
    Function.apply null, args
