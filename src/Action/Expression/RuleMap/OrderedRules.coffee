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


{Constants:{
  CHAR_colon
  CHAR_semicolon
}}                  = require './Constants'

{UnorderedRules}    = require './UnorderedRules'

exports = module?.exports ? this

## OrderedRules

# OrderedRules look like “identifier: expression; identifier2: expression2”.
# They provide a simplified implementation of UnorderedRules keeping the
# initial order of all rules added.
#
# @class
# @namespace goatee.Core
exports.OrderedRules = class OrderedRules extends UnorderedRules

  ##
  # @param {Array}  sequence
  # @param {Object} rules
  # @param {Object} priority
  # @constructor
  constructor: (@sequence, @rules, @priority) ->
    @sequence ?= []
    super @rules, @priority

  ##
  # adds a new rule to this instance
  # @param  {String} string
  # @return {OrderedRules}
  add: (key, value, important) ->

    id     = @normalizeKey key
    exists = @rules.hasOwnProperty(id)

    return @ unless important is true or \
                    exists is false or \
                    @priority.hasOwnProperty(id) is false

    @rules[id]    = @normalizeValue value
    @priority[id] = true if important is true

    @sequence.push(id) if exists is false
    return @

  ##
  # Call fn for each rule's key, value and priority.
  #
  # @param  {Function} fn
  # @return {Array}
  each: (fn) ->
    fn key, @rules[key], @priority.hasOwnProperty(key) for key in @sequence
    @

  ##
  # Call fn for each rule's key, value and priority and return the resulting
  # Array.
  #
  # @param  {Function} fn
  # @return {Array}
  map: (fn) ->
    fn key, @rules[key], @priority.hasOwnProperty(key) for key in @sequence


##
# NON-STANDARD
# lightweight version of CSSOM.CSSStyleRule.parse, which in turn is a
# lightweight version of parse.js
#
# @param  {String}  text
# @param  {OrderedRules} Optional _map instance to merge into, for internal use.
# @return {OrderedRules}
OrderedRules.parse = (text, _map) ->
  return UnorderedRules.parse text, _map ? new OrderedRules
