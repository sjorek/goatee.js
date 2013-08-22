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

clean = (root) ->
  try
    files = fs.readdirSync root
  catch e
    log null, '', e.message
    return
  if  files.length > 0
    for file in files
      path = "#{root}/#{file}"
      stat = fs.lstatSync path
      if stat.isFile() or stat.isSymbolicLink()
        fs.unlinkSync path
      else
        clean path
  fs.rmdirSync root

task 'all', 'invokes build and clean in given order', ->
  console.log 'all'
  invoke 'clean'
  invoke 'build'

task 'build', 'invokes build:once and … in given order', ->
  console.log 'build'
  invoke 'build:once'

task 'clean', 'removes Javascript in “lib/”', ->
  console.log 'clean'
  clean 'lib'

task 'build:watch', 'compile Coffeescript in “src/” to Javascript in “lib/” continiously', ->
  spawn 'coffee', '-o ../lib/ -mcw .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:once', 'compile Coffeescript in “src/” to Javascript in “lib/” once', ->
  spawn 'coffee', '-o ../lib/ -mc .'.split(' '), stdio: 'inherit', cwd: 'src'
