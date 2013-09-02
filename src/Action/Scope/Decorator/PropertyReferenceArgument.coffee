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

{Constants:{
  CHAR_comma
}}              = require '../../Core/Constants'

exports = module?.exports ? this

exports.PropertyReferenceArgument = class PropertyReferenceArgument

  _cache = {}

  bind: (code, scope...) ->
    @build(code).apply(scope[0], scope)

  build: (code) ->
    self = @
    return (scope...) ->
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
