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

{OrderedRules} = require './OrderedRules'

{Utility:{
  dashify
}}             = require './Utility'

root = module?.exports ? this

## OrderedAttributes

# OrderedAttributes look like “attribute-key: expression; another-key: value”.
# They provide a implementation of normalized to dash-seperated OrderedRules.
#
# @class
# @namespace goatee.Core
root.OrderedAttributes = class OrderedAttributes extends OrderedRules

  ##
  # @param  {String} string
  # @return {String}
  normalizeKey: (string) ->
    dashify super(string)

##
# NON-STANDARD
# lightweight version of CSSOM.CSSStyleRule.parse, which in turn is a
# lightweight version of parse.js
#
# @param  {String}  text
# @param  {OrderedAttributes} Optional _map instance to merge into, for internal use.
# @return {OrderedAttributes}
OrderedAttributes.parse = (text, _map) ->
  return OrderedRules.parse text, _map ? new OrderedAttributes
