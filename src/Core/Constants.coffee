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

root = module?.exports ? this

root.Constants = Constants =

  ##
  # Names of special variables defined by the jstemplate evaluation
  # context. These can be used in js expression in jstemplate
  # attributes.
  VAR_index            : '$index'
  VAR_count            : '$count'
  VAR_this             : '$this'
  VAR_context          : '$context'
  VAR_top              : '$top'

  ##
  # The name of the global variable which holds the value to be returned if
  # context evaluation results in an error.
  # Use `Context.setGlobal(Constants.GLOB_default, value)` to set this.
  GLOB_default         : '$default'

  ##
  # Un-inlined literals, to avoid object creation in IE6.
  CHAR_colon           : ':'
  REGEXP_semicolon     : /\s*;\s*/
  REGEXP_trim          : /^\s+|\s+$/g
  REGEXP_trimLeft      : /^\s+/
  REGEXP_trimRight     : /\s+$/
  REGEXP_camelize      : /-([a-z])/gi
  REGEXP_dashify       : /(^|[a-zA-Z])([A-Z])/g
  REGEXP_isEscaped     : /[^\\](\\\\)*$/

  ##
  # String literals defined globally and not to be inlined. (IE6 performance).
  STRING_variables     : '$_variables'
  STRING_data          : '$_data'
  STRING_with          : 'with ($_variables) with ($_data) return '
  STRING_empty         : ''

  # CSS Properties used in by some actions
  CSS_display          : 'display'
  CSS_position         : 'position'

  # Constants for possible values of the typeof operator.
  TYPE_boolean         : 'boolean'
  TYPE_number          : 'number'
  TYPE_object          : 'object'
  TYPE_string          : 'string'
  TYPE_function        : 'function'
  TYPE_undefined       : 'undefined'

  ##
  # Un-inlined string literals, to avoid object creation in IE6.
  CHAR_asterisk        : '*'
  CHAR_dollar          : '$'
  CHAR_period          : '.'
  CHAR_exclamation     : '!'
  CHAR_ampersand       : '&'
  CHAR_dash            : '-'
  CHAR_slash           : '/'
  CHAR_backslash       : '''\\'''
  CHAR_equals          : '='
  CHAR_colon           : ':'
  CHAR_semicolon       : ';'
  CHAR_doublequote     : '"'
  CHAR_singlequote     : "'"

  CHAR_space           : " "
  CHAR_tab             : "\t" # tabulator
  CHAR_vtab            : "\v" # vertical tabulator
  CHAR_cr              : "\r" # carriage return
  CHAR_lf              : "\n" # line feed
  CHAR_ff              : "\f" # form feed

  STRING_nonimportant  : '!important'
  STRING_opencomment   : '/*'
  STRING_closecomment  : '*/'
  STRING_div           : 'div'
  STRING_id            : 'id'
  STRING_asteriskzero  : '*0'
  STRING_zero          : '0'
  STRING_assignment    : '|=|'
  STRING_seperator     : '|||'
