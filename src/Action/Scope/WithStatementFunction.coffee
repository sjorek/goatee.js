

root = exports ? this


root.WithStatementFunction = class WithStatementFunction
  _cache: {}

  build: (code) ->
    return @_cache[code] if @_cache[code]?
    code = "return #{code}"
    args = scope.map (object) ->
      name = "__#{object.name}__"
      code = "with(#{name}) { #{code} }"
      name
    args.push(code)
    Function.apply null, args
