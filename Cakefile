fs      = require 'fs'
{print, puts} = require 'sys'
{spawn}       = require 'child_process'

appFiles  = ("src/#{name}.coffee" for name in [
  'motions'
  'jim'
  'modes/insert'
  'modes/normal'
  'modes/visual'
  'ace/jim_undo_manager'
  'ace/adaptor'
  'ace/module'
])

build = ->
  coffee = spawn 'coffee', ['--join', 'lib/jim.js', '--compile', appFiles...]
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()
  coffee.on 'exit', (status) ->
    puts "#{new Date()}: built lib/jim.js" if status is 0

task 'build', 'Build single application file from source files', ->
  build()

task 'watch', 'Run build wheneven an app file changes', ->
  build()
  for file in appFiles then do (file) ->
    fs.watchFile file, (curr, prev) ->
      if "#{curr.mtime}" != "#{prev.mtime}"
        build()
