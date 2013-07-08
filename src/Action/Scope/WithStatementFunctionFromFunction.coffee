
{Constants:{
  CHAR_comma
}}                      = require '../../Core/Constants'

{WithStatementFunction} = require './WithStatementFunction'

root = exports ? this

root.WithStatementFunctionFromFunction = \
class WithStatementFunctionFromFunction extends WithStatementFunction

  compile: (args, code) ->
    Function("return function(#{args.implode(CHAR_comma)}) { #{code} }")()
