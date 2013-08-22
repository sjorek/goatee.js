fs            = require 'fs'
{exec,spawn}  = require 'child_process'

# ANSI Terminal Colors.
bold = red = green = reset = ''
unless process.env.NODE_DISABLE_COLORS
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

log = (error, stdout, stderr) ->
  console.log stdout, stderr
  console.log(error) if error?

task 'build', 'invokes build:once and build:parser in given order', ->
  invoke 'build:once'
  invoke 'build:parser'

task 'clean', 'removes Javascript in “lib/”', ->
  exec 'rm -rv lib', log
  exec 'mkdir -v lib', log

task 'build:watch', 'compile Coffeescript in “src/” to Javascript in “lib/” continiously', ->
  spawn 'coffee', '-o ../lib/ -mcw .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:once', 'compile Coffeescript in “src/” to Javascript in “lib/” once', ->
  spawn 'coffee', '-o ../lib/ -mc .'.split(' '), stdio: 'inherit', cwd: 'src'
