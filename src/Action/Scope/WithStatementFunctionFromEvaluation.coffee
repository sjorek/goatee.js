
{Constants:{
  CHAR_comma
}}                      = require '../../Core/Constants'

{WithStatementFunction} = require './WithStatementFunction'

root = exports ? this

root.WithStatementFunctionFromEvaluation = \
class WithStatementFunctionFromEvaluation extends WithStatementFunction

  compile: (args, code) ->
    eval "code = function(#{args.implode(CHAR_comma)}) { #{code} }"
