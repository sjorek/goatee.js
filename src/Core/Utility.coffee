###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2006 Google Inc.

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

##
# @fileoverview Miscellaneous functions referenced in
# the main source files.
#
# @author Steffen Meschkat (mesch@google.com)
##

{Constants} = require 'goatee/Core/Constants'

root = exports ? this

root.Utility = Utility =

  ##
  # Detect if an object looks like an Array.
  # Note that instanceof Array is not robust; for example an Array
  # created in another iframe fails instanceof Array.
  # @param {Object|null} value Object to interrogate
  # @return {Boolean} Is the object an array?
  isArray: (value) ->
    typeof value?.length is Constants.TYPE_number

  ##
  # Finds a slice of an array.
  #
  # @param  {Array}  array  Array to be sliced.
  # @param  {Number} start  The start of the slice.
  # @param  {Number} end    The end of the slice (optional).
  # @return {Array}  array  The slice of the array from start to end.
  arraySlice: (array, start, end) ->
    # Use
    #   return Function.prototype.call.apply(Array.prototype.slice, arguments);
    # instead of the simpler
    #   return Array.prototype.slice.call(array, start, opt_end);
    # here because of a bug in the FF and IE implementations of
    # Array.prototype.slice which causes this function to return an empty list
    # if end is not provided.
    Function.prototype.call.apply Array.prototype.slice, arguments

  ##
  # Clears the array by setting the length property to 0. This usually
  # works, and if it should turn out not to work everywhere, here would
  # be the place to implement the browser specific workaround.
  #
  # @param {Array} array  Array to be cleared.
  arrayClear: (array) ->
    array.length = 0
    return

  ##
  # Jscompiler wrapper for parseInt() with base 10.
  #
  # @param {String} s string repersentation of a number.
  # @return {Number} The integer contained in s, converted on base 10.
  parseInt10: (s) ->
    parseInt(s, 10)

  ##
  # Prebinds "this" within the given method to an object, but ignores all
  # arguments passed to the resulting function.
  # I.e. var_args are all the arguments that method is invoked with when
  # invoking the bound function.
  #
  # @param {Object|null} object  The object that the method call targets.
  # @param {Function} method  The target method.
  # @return {Function}  Method with the target object bound to it and curried by
  #                     the provided arguments.
  bind: (object, method, args...) ->
    return () ->
      return method.apply(object, args)

  ##
  # Trim whitespace from begin and end of string.
  #
  # @see testStringTrim();
  #
  # @param {String} str  Input string.
  # @return {String}  Trimmed string.
  trim: (string) ->
    # Utility.trimRight(Utility.trimLeft(string))
    string.replace(Constants.REGEXP_trim, '')

  ##
  # Trim whitespace from beginning of string.
  #
  # @see testStringTrimLeft();
  #
  # @param {String} str  Input string.
  # @return {String}  Trimmed string.
  trimLeft: (string) ->
    string.replace(Constants.REGEXP_trimLeft, '')

  ##
  # Trim whitespace from end of string.
  #
  # @see testStringTrimRight();
  #
  # @param {String} str  Input string.
  # @return {String}  Trimmed string.
  trimRight: (string) ->
    string.replace(Constants.REGEXP_trimRight, '')
