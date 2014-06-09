fs            = require 'fs'
{exec,spawn}  = require 'child_process'

# ANSI Terminal Colors. Currently unused
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

option '-v', '--verbose [LEVEL]', 'set groc\'s verbosity level during documentation generation. [0=silent,1,2,3]'

groc = (verbose = 1, options = []) ->
  pkg = require './package.json'
  options.push '--title'
  options.push "#{pkg.name} [ version #{pkg.version} ]"
  options.push '--languages'
  options.push process.cwd() + '/misc/groc_languages'
  if verbose? and 0 < verbose
    options.push '--verbose' if 1 < verbose
    options.push '--very-verbose' if 2 < verbose
  else
    options.push '--silent'
  spawn 'groc', options, stdio: 'inherit', cwd: '.'

task 'all', 'invokes build and clean in given order', ->
  console.log 'all'
  invoke 'clean'
  invoke 'build'
  invoke 'doc'

task 'build', 'invokes build:once and … in given order', ->
  console.log 'build'
  invoke 'build:once'

task 'clean', 'cleans “doc/” and “lib/” folders', ->
  console.log 'clean'
  clean 'doc'
  fs.mkdirSync 'doc'
  clean 'lib'
  fs.mkdirSync 'lib'

task 'build:watch', 'compile Coffeescript in “src/” to Javascript in “lib/” continiously', ->
  console.log 'build:watch'
  spawn 'coffee', '-o ../lib/ -mcw .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'build:once', 'compile Coffeescript in “src/” to Javascript in “lib/” once', ->
  console.log 'build:once'
  spawn 'coffee', '-o ../lib/ -mc .'.split(' '), stdio: 'inherit', cwd: 'src'

task 'doc', 'invokes “doc:source” and “doc:github” in given order', ->
  console.log 'doc'
  invoke 'doc:source'
  #invoke 'doc:github'

task 'doc:source', 'rebuild the internal documentation', (options) ->
  console.log 'doc:source'
  clean 'doc'
  groc options['verbose']

task 'doc:github', 'rebuild the github documentation', (options) ->
  console.log 'doc:github'
  groc options['verbose'], ['--github']

