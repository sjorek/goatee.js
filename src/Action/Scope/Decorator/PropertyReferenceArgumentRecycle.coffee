###
© Copyright 2013-2014 Stephan Jorek <stephan.jorek@gmail.com>  

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
}}                          = require '../../Core/Constants'

{PropertyReferenceArgument} = require './PropertyReferenceArgument'

{Utility:{
  arrayClear
}}                          = require '../../Core/Constants'

exports = module?.exports ? this

exports.PropertyReferenceArgumentRecycle = \
class PropertyReferenceArgumentRecycle extends PropertyReferenceArgument

  _map   = {}
  _args  = []
  _vals  = []

  _clearMap = (key) ->
    delete _map[key]
    return

  _collectProperties = (object) ->
    for key of object
      continue if _map[key]?
      _map[key] = _args.length
      _args.push key
      _vals.push object[key]
    return

  build: (code) ->
    self = @
    return (scope...) ->
      arrayClear _args
      arrayClear _vals
      scope.map _collectProperties
      _args.map _clearMap
      self.compile(_args, code).apply(@, _vals)
