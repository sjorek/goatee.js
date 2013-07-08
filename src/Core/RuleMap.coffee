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
  CHAR_space
  CHAR_tab
  CHAR_vtab
  CHAR_cr
  CHAR_lf
  CHAR_ff
  CHAR_doublequote
  CHAR_singlequote
  CHAR_slash
  CHAR_backslash
  CHAR_colon
  CHAR_semicolon
  CHAR_exclamation
  CHAR_asterisk
  STRING_empty
  STRING_closecomment
  STRING_nonimportant
  REGEXP_isEscaped
}} = require './Constants'

{Utility:{
  trim
}} = require './Utility'

root = exports ? this

## RuleMap

# A RuleMap looks like “identifier: expression; identifier2: expression2”.
# They provide a simplified implementation of …
# @see http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/css.html#CSS-ElementCSSInlineStyle
# @see http://www.w3.org/TR/1998/REC-html40-19980424/present/styles.html#h-14.2.2
# @class
# @namespace goatee.Core
root.RuleMap = class RuleMap

  ##
  # @param {Object} rules
  # @param {Object} priorize
  # @constructor
  constructor: (@rules, @priorize) ->
    @rules    ?= {}
    @priorize ?= {}

  ##
  # adds a new rule to this instance
  # @param  {String} string
  # @return {RuleMap}
  add: (key, value, important) ->
    k = @normalizeKey key
    return @ unless important is true or \
       not @rules.hasOwnProperty(k) or \
       not @priorize.hasOwnProperty(k)

    @rules[k]    = @normalizeValue value
    @priorize[k] = true if important is true

    return @

  ##
  # Opposite of @merge(map). Returns this map with all rules from given map
  # applied to this map, taking my and their priorities into consideration.
  #
  # @param  {RuleMap} map
  # @return {RuleMap}
  inject: (map) ->
    {rules,priorize} = map
    @add key, value, priorize.hasOwnProperty(key) for own key, value of rules
    @

  ##
  # Opposite of @inject(map). Returns the given map with all my rules applied
  # to given map, taking their and my priorities into consideration.
  #
  # @param  {RuleMap} map
  # @return {RuleMap}
  merge: (map) ->
    map.inject(@)

  ##
  # @param  {String} string
  # @return {String}
  normalizeKey: (string) ->
    trim string

  ##
  # @param  {String} string
  # @return {String}
  normalizeValue: (string) ->
    trim string

##
# Internal list of error messages, used by RuleMap.parse
# @type {Array}
_errors = [
  "Unexpected content after important declaration"
  "Missing closing string"
  "Missing closing comment"
  "Unexpected string opener"
  "Missing identifier key"
  "Important already declared"
]

##
# NON-STANDARD
# lightweight version of CSSOM.CSSStyleRule.parse, which in turn is a
# lightweight version of parse.js
#
# @param  {String}  text
# @param  {RuleMap} Optional _map instance to merge into, for internal use.
# @return {RuleMap}
RuleMap.parse = (text, _map) ->

    i          = 0
    j          = i
    stateKey   = "key"
    stateValue = "value"
    state      = stateKey
    buffer     = ""
    char       = ""
    key        = ""
    value      = ""
    important  = false
    _map      ?= new RuleMap
    rules      = _map.rules
    priorize   = _map.priorize

    error      = (num) ->
      msg = _errors[num - 1]
      msg + ":" + CHAR_lf + "“" +
      text.slice(0, i) + '»»»' + text.charAt(i) + '«««' + text.slice(i + 1) +
      "”" + CHAR_lf + "(state: #{state}, position: #{i}, character: “#{char}”)"


    `for (char = text.charAt(i); (char = text.charAt(i)) !== ""; i++) {`

    # console.log 'Processing', i, '=', char

    switch char

      # " ", "\t", "\v", "\r", "\n", "\f"
      when CHAR_space, CHAR_tab, CHAR_vtab, CHAR_cr, CHAR_lf, CHAR_ff

        # SIGNIFICANT_WHITESPACE
        buffer += char if state is stateValue and not important
        continue
        break

      # String
      # "'", '"'
      when CHAR_singlequote, CHAR_doublequote
        if important
          throw (error 1)
        else if state is stateValue
          j = i + 1
          while index = text.indexOf(char, j) + 1
            break if text.charAt(index - 2) isnt CHAR_backslash or \
                  REGEXP_isEscaped.test text.slice(i, index - 1)
            j = index

          throw (error 2) if index is 0
          buffer += text.slice(i, index)
          i = index - 1
          continue
        else
          throw (error 4)
        break

      # Comment
      # "/"
      when CHAR_slash
        if text.charAt(i + 1) is CHAR_asterisk # "*"
          i += 2
          index = text.indexOf STRING_closecomment, i # "*/", i
          throw (error 3) if index is -1
          i = index + 1
          continue
        else if important
          throw (error 1)
        else
          buffer += char
          continue
        break

      # ":"
      when CHAR_colon
        if state is stateKey
          key   += buffer
          throw (error 5) if key is STRING_empty
          buffer = ""
          state  = stateValue
          continue
        else if important
          throw (error 1)
        else
          buffer += char
          continue
        break

      # "!"
      when CHAR_exclamation
        if state is stateValue and text.indexOf(STRING_nonimportant, i) is i
          throw (error 6) if important
          important = true
          i += 9 # = "important".length
          continue
        else if important
          throw (error 1)
        else
          buffer += char;
          continue
        break

      # ";"
      when CHAR_semicolon
        continue if state is stateKey
        if state is stateValue
          value    += buffer

          _map.add(key, value, important)

          important = false
          key       = ""
          value     = ""
          buffer    = ""
          state     = stateKey
          continue
        else if important
          throw (error 1)
        else
          buffer += char
          continue
        break

      else
        throw (error 1) if important
        buffer += char
        continue
        break

    `}`

    _map.add(key, value + buffer, important) if state is stateValue

    return _map
