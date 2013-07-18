fs            = require 'fs'

# ANSI Terminal Colors.
bold = red = green = reset = ''
unless process.env.NODE_DISABLE_COLORS
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

task 'build:parser', 'rebuild the Jison parser (run build first)', ->
  require 'jison'
  {parser,grammar} = require('./src/Action/Expression/Compiler/Goateescript/Grammar')
  fs.writeFile './lib/Action/Expression/Compiler/Goateescript/Parser.js', \
               (grammar.header ? "") + parser.generate() + (grammar.footer ? "")
