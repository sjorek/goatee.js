
{Constants:{
  CHAR_comma
}}                      = require '../../Core/Constants'

{WithStatementFunction} = require './WithStatementFunction'

root = exports ? this

root.PropertyReferenceAsWrapperFunctionArgument = \
class PropertyReferenceAsWrapperFunctionArgument extends WithStatementFunction

  compile: (args, code) ->
    Function("return function(#{args.implode(CHAR_comma)}) { #{code} }")()
