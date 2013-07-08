
{WithStatementFunction} = require './WithStatementFunction'

root = exports ? this


root.PseudoStrictWithStatementFunction = \
class PseudoStrictWithStatementFunction extends WithStatementFunction

  build: (expression, scope) ->
    super """(function(){"use strict"; return #{expression}}).call(this)"""