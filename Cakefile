fs      = require 'fs'
{spawn} = require 'child_process'

# ANSI Terminal Colors.
bold = red = green = reset = ''
unless process.env.NODE_DISABLE_COLORS
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

task 'build', 'invokes build:once and build:parser in given order', ->
  invoke 'build:once'
  invoke 'build:parser'

task 'clean', 'removes Javascript in “lib/”', ->
  spawn 'rm', '-rv lib'.split(' '), stdio: 'inherit'
  spawn 'mkdir', '-v lib'.split(' '), stdio: 'inherit'

task 'build:watch', 'compile Coffeescript in “src/” to Javascript in “lib/” continiously', ->
  spawn 'coffee', '-o ../lib/ -mcw .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:once', 'compile Coffeescript in “src/” to Javascript in “lib/” once', ->
  spawn 'coffee', '-o ../lib/ -mc .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:parser', 'rebuild the Goateescript parser', ->
  require 'jison' # TODO This seems to be important, have to figure out why !
  {
    parser, grammar
  } = require('./src/Action/Expression/Compiler/Goateescript/Grammar')
  fs.writeFile './lib/Action/Expression/Compiler/Goateescript/Parser.js', \
               (grammar.header ? "") + parser.generate() + (grammar.footer ? "")
