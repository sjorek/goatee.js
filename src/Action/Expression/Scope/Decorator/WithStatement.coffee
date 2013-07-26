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

exports = module?.exports ? this

exports.WithStatement = class WithStatement
  _cache: {}

  bind: (code, scope...) ->
    @buildMany(code).apply(scope[0], scope)

  build: (code) ->
    self = @
    return (scope...) ->
      code = "return #{code}"
      args = for index, object in scope
        name = "__scope#{index}__"
        code = "with(#{name}) #{code}"
        name
      id = self.identify(args, code)
      _cache[id] || _cache[id] = self.compile args, code

  identify: (args, code) ->
    "(#{args.join(',')}) -> (#{code})"

  compile: (id, args, code) ->
    args.push(code)
    Function.apply null, args
