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
}} = require '../Core/Constants'

{Utility:{
  trim
}} = require '../Core/Utility'

root = module?.exports ? this

## UnorderedRules

# UnorderedRules look like “identifier: expression; identifier2: expression2”.
#
# They provide a simplified implementation of:
# @see http://www.w3.org/TR/2000/REC-DOM-Level-2-Style-20001113/css.html#CSS-ElementCSSInlineStyle
# @see http://www.w3.org/TR/1998/REC-html40-19980424/present/styles.html#h-14.2.2
#
# @class
# @namespace goatee.Core
root.UnorderedRules = class UnorderedRules

  ##
  # @param {Object} rules
  # @param {Object} priority
  # @constructor
  constructor: (@rules, @priority) ->
    @rules    ?= {}
    @priority ?= {}

  ##
  # adds a new rule to this instance
  # @param  {String} string
  # @return {UnorderedRules}
  add: (key, value, important) ->

    id     = @normalizeKey key
    exists = @rules.hasOwnProperty(id)

    return @ unless important is true or \
                    exists is false or \
                    @priority.hasOwnProperty(id) is false

    @rules[id]    = @normalizeValue value
    @priority[id] = true if important is true

    return @

  ##
  # Call fn for each rule's key, value and priority.
  #
  # @param  {Function} fn
  # @return {Array}
  each: (fn) ->
    fn key, value, @priority.hasOwnProperty(key) for own key, value of @rules
    @

  ##
  # Call fn for each rule's key, value and priority and return the resulting
  # Array.
  #
  # @param  {Function} fn
  # @return {Array}
  map: (fn) ->
    fn key, value, @priority.hasOwnProperty(key) for own key, value of @rules

  ##
  # Opposite of @apply(string). Returns this map with all rules from given map
  # applied to this map, taking my and their priorities into consideration.
  #
  # @param  {String} string
  # @return {UnorderedRules}
  apply: (string) ->
    UnorderedRules.parse string, @

  ##
  # Opposite of @project(map). Returns this map with all rules from given map
  # applied to this map, taking my and their priorities into consideration.
  #
  # @param  {UnorderedRules} map
  # @return {UnorderedRules}
  inject: (map) ->
    map.project @
    @

  ##
  # Opposite of @inject(map). Returns the given map with all my rules applied
  # to given map, taking their and my priorities into consideration.
  #
  # @param  {UnorderedRules} map
  # @return {UnorderedRules}
  project: (map) ->
    @each (key, value, priority) ->
      map.add(key, value, priority)
    @

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
  # Return each rule's key, value and priority as Array of Arrays.
  #
  # @param  {Function} fn
  # @return {Array}
  flatten: (fn) ->
    @map (key, value, priority) ->
      [key, value, priority]

  ##
  # Opposite of @merge(map). Returns this map with all rules from given map
  # applied to this map, taking my and their priorities into consideration.
  #
  # @param  {UnorderedRules} map
  # @return {UnorderedRules}
  toString: () ->
    rules = @map (key, value, priority) ->
      rule  = key + CHAR_colon + value
      rule += CHAR_space + STRING_nonimportant if priority is true
      rule
    rules.implode(CHAR_semicolon)

##
# Internal list of error messages, used by UnorderedRules.parse
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
# @param  {UnorderedRules} Optional _map instance to merge into, for internal use.
# @return {UnorderedRules}
UnorderedRules.parse = (text, _map) ->

    _map      ?= new UnorderedRules
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
