# # Supported Languages

module.exports = LANGUAGES =
  Markdown:
    nameMatchers: ['.md']
    commentsOnly: true

  CoffeeScript:
    nameMatchers:      ['.coffee', 'Cakefile']
    pygmentsLexer:     'coffee-script'
    multiLineComment:  [
    #  '###*',   ' *',   '###',
      '###',     ' ',    '###'
    ]
    singleLineComment: ['#']
    ignorePrefix:      '!'
    foldPrefix:        '~'
    doctags           : require 'groc/lib/languages/doctags'
    namespace         :
      separator       : '.'
      types           : [
        require './goatee_namespace.json'
        require 'groc/lib/languages/javascript/namespace_global.json'
        require 'groc/lib/languages/javascript/namespace_dom.json'
      ]
