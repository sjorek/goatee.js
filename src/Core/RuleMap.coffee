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

{Utility} = require './Utility'

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
# NON-STANDARD
# lightweight version of CSSOM.CSSStyleRule.parse, which in turn is a
# lightweight version of parse.js
#
# @param  {String}  text
# @param  {RuleMap} map
# @return RuleMap
RuleMap.parse = (text) ->

    i          = 0
    j          = i
    state      = "name"
    buffer     = ""
    char       = ""
    rules      = {}
    priorize   = {}
    important  = false

    add        = (name) ->
      if not `(name in rules)` or important or not `(name in priorize)`
        rules[name] = Utility.trim buffer
        priorize[name] = true if important

    error      = () ->
      "“" +
      text.slice(0, i) + '»»»' + text.charAt(i) + '«««' + text.slice(i + 1) + \
      "” (state: #{state}, position: #{i}, character: “#{char}”)"

    `for (char = text.charAt(i); (char = text.charAt(i)) !== ""; i++) {`

    switch char

      when " ", "\t", "\r", "\n", "\f"
        # SIGNIFICANT_WHITESPACE
        buffer += char if state is "value" and not important
        continue
        break

      # String
      when "'", '"'
        if important
          throw "unexpected content after important declaration: #{error()}"
        else if state is "value"
          j = i + 1
          while index = text.indexOf(char, j) + 1
            console.log(1, index, 2, j, 3, text.charAt(index - 2), 4, text.slice(i, index - 1))
            break if text.charAt(index - 2) isnt "\\" or \
                  /[^\\](\\\\)*$/.test(text.slice(i, index - 1))
            j = index

          throw "Missing closing string: #{error()}" if index is 0
          buffer += text.slice(i, index)
          i = index - 1
          continue
        else
          throw "unexpected string: #{error()}"
        break

      # Comment
      when "/"
        if text.charAt(i + 1) is "*"
          i += 2
          index = text.indexOf "*/", i
          throw "Missing closing comment: #{error()}" if index is -1
          i = index + 1
          continue
        else if important
          throw "unexpected content after important declaration: #{error()}"
        else
          buffer += char
          continue
        break

      when ":"
        if state is "name"
          name = Utility.trim buffer
          throw "missing identifer: #{error()}" if name is ""
          buffer = ""
          state = "value"
          continue
        else if important
          throw "unexpected content after important declaration: #{error()}"
        else
          buffer += char
          continue
        break

      when "!"
        if state is "value" and text.indexOf("!important", i) is i
          if important
            throw "unexpected important after another important declaration: #{error()}"
          important = true
          i += 9 # = "important".length
          continue
        else if important
          throw "unexpected content after important declaration: #{error()}"
        else
          buffer += char;
          continue
        break

      when ";"
        continue if state is "name"
        if state is "value"
          add(name)
          important = false
          buffer = ""
          state = "name"
          continue
        else if important
          throw "unexpected content after important declaration: #{error()}"
        else
          buffer += char
          continue
        break

      else
        if important
          throw "unexpected content after important declaration: #{error()}"
        buffer += char
        continue
        break

    `}`

    add(name) if state is "value"

    return new RuleMap rules, priorize
