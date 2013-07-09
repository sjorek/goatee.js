
{Constants:{
  CHAR_comma
}}                      = require '../../Core/Constants'

{WithStatementFunction} = require './WithStatementFunction'

root = exports ? this

root.ArgumentWrapperFunction = class ArgumentWrapperFunction
  _cache = {}

  bind: (code, object, scope...) ->
    @build(code).apply(object, scope)

  build: (code) ->
    self = @
    return (scope) ->
      map  = {}
      args = []
      vals = []
      for object in scope
        for key of object
          continue if map[key]?
          map[key] = args.length
          args.push key
          vals.push object[key]
      self.compile(args, code).apply(@, vals)

  compile: (args, code) ->
    id = "(#{args.join(',')}) -> #{code}"
    return fn if (fn = _cache[id])?
    args.push "return #{code}"
    _cache[id] = Function.apply null, args
