###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>  
© Copyright 2006 Google Inc. <http://www.google.com>

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

#~ require
{Constants:{
  CHAR_dash,
  TYPE_number,
  REGEXP_trim,
  REGEXP_trimLeft,
  REGEXP_trimRight,
  REGEXP_camelize,
  REGEXP_dashify
}} = require './Constants'

#~ export
exports = module?.exports ? this

# Utility
# ================================

# --------------------------------
# This objeect provides a collection of miscellaneous utility functions
# referenced in the main source files.
#
# @public
# @module     Utility
# @namespace  goatee.Core
# @author     Steffen Meschkat  <mesch@google.com>
# @author     Stephan Jorek     <stephan.jorek@gmail.com>
# @type       {Object}
exports.Utility = Utility =

  # --------------------------------
  # Detect if an object looks like an Array.
  # Note that instanceof Array is not robust; for example an Array
  # created in another iframe fails instanceof Array.
  #
  # @static
  # @public
  # @method isArray
  # @param  {mixed}   value   Object to interrogate
  # @return {Boolean}         Is the object an array?
  isArray: (value) ->
    value.length? and typeof value.length is TYPE_number

  # --------------------------------
  # Finds a slice of an array.
  #
  # @static
  # @public
  # @method arraySlice
  # @param  {Array}   array             An array to be sliced.
  # @param  {Number}  start             The start of the slice.
  # @param  {Number}  [end=undefined]   The end of the slice.
  # @return {Array}                               A sliced array from start to end.
  arraySlice: (array, start, end) ->
    # We use
    #
    #   `return Function.prototype.call.apply(Array.prototype.slice, arguments);`
    #
    # instead of the simpler
    #
    #   `return Array.prototype.slice.call(array, start, opt_end);`
    #
    # here because of a bug in the FF ≤ 3.6 and IE ≤ 7 implementations of
    # `Array.prototype.slice` which causes this function to return
    # an empty list if end is not provided.
    Function.prototype.call.apply Array.prototype.slice, arguments

  # --------------------------------
  # Clears the array by setting the length property to 0. This usually
  # works, and if it should turn out not to work everywhere, here would
  # be the place to implement the <del>browser</del> specific workaround.
  #
  # @static
  # @public
  # @method arrayClear
  # @param  {Array} array  Array to be cleared.
  arrayClear: (array) ->
    array.length = 0
    return

  # --------------------------------
  # Jscompiler wrapper for parseInt() with base 10.
  #
  # @static
  # @public
  # @method parseInt10
  # @param  {String}  string  String representation of a number.
  # @return {Number}          The integer contained in string,
  #                           converted to base 10.
  parseInt10: (string) ->
    parseInt(string, 10)

  # --------------------------------
  # Binds `this` within the given method to an object, but ignores all arguments
  # passed to the resulting function, i.e. `args` are all the arguments that
  # method is invoked with when invoking the bound function.
  #
  # @static
  # @public
  # @method bind
  # @param  {Object}    [object]  If object isn't `null` it becomes the method's
  #                               call target to bind to.
  # @param  {Function}  method    The target method to bind.
  # @param  {mixed...}  [args]    The arguments to bind.
  # @return {Function}            Method with the target object bound and
  #                               curried with provided arguments.
  bind: (object, method, args...) ->
    return -> method.apply(object, args)

  # --------------------------------
  # Trim whitespace from begin and end of string.
  #
  # @static
  # @public
  # @method trim
  # @param  {String}  string  Input string.
  # @return {String}          Trimmed string.
  # @see `testStringTrim();`
  trim: if String::trim?
  then (string) -> string.trim()
    # Is `Utility.trimRight(Utility.trimLeft(string));` an alternative ?
  else (string) -> string.replace REGEXP_trim, ''

  # --------------------------------
  # Trim whitespace from beginning of string.
  #
  # @static
  # @public
  # @method trimLeft
  # @param  {String}  string  Input string.
  # @return {String}          Left trimmed string.
  # @see `testStringTrimLeft();`
  trimLeft: if String::trimLeft?
  then (string) -> string.trimLeft()
  else (string) -> string.replace REGEXP_trimLeft, ''

  # --------------------------------
  # Trim whitespace from end of string.
  #
  # @static
  # @public
  # @method trimRight
  # @param  {String}  string  Input string.
  # @return {String}          Right trimmed string.
  # @see `testStringTrimRight();`
  trimRight: if String::trimRight?
  then (string) -> string.trimRight()
  else (string) -> string.replace REGEXP_trimRight, ''

  # --------------------------------
  # Convert “a-property-name” to “aPropertyName”
  #
  # @static
  # @public
  # @method camelize
  # @param  {String}  string  Input string.
  # @return {String}          Camelized string.
  camelize: do ->

    # Internal camelize-helper function
    #
    # @private
    # @method _camelize
    # @param  {String}  match
    # @param  {String}  char
    # @param  {Number}  index
    # @param  {String}  string
    # @return {String}          Camelized string fragment.
    _camelize = (match, char, index, string) -> char.toUpperCase()

    # The camelize implementation
    (string) -> string.replace REGEXP_camelize, _camelize

  # --------------------------------
  # Convert “aPropertyName” to “a-property-name”
  #
  # @static
  # @public
  # @method dashify
  # @param  {String}  string  Input string.
  # @return {String}          Dashed string.
  dashify: do ->

    # Internal dashify-helper function
    #
    # @private
    # @method _dashify
    # @param  {String}  match
    # @param  {String}  char
    # @param  {String}  camel
    # @param  {Number}  index
    # @param  {String}  string
    # @return {String}          Dashed string fragment.
    _dashify  = (match, char, camel, index, string) ->
      char + CHAR_dash + camel.toLowerCase()

    # The dashify implementation
    (string) -> string.replace REGEXP_dashify, _dashify
