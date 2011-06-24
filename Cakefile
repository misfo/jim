fs      = require 'fs'
{print} = require 'sys'
{spawn} = require 'child_process'

appFiles  = ("src/#{name}.coffee" for name in [
  'motions'
  'jim'
  'modes/insert'
  'modes/normal'
  'modes/visual'
  'ace_adaptor'
])

build = ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'lib/jim.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err

      coffee = spawn 'coffee', ['--compile', 'lib/jim.coffee']
      coffee.stdout.on 'data', (data) -> print data.toString()
      coffee.stderr.on 'data', (data) -> print data.toString()
      coffee.on 'exit', ->
        fs.unlink 'lib/jim.coffee', (err) -> throw err if err
        console.log "#{new Date()}: compiled lib/jim.js"

task 'build', 'Build single application file from source files', ->
  build()

task 'watch', 'Run build wheneven an app file changes', ->
  build()
  for file in appFiles then do (file) ->
    fs.watchFile file, (curr, prev) ->
      if "#{curr.mtime}" != "#{prev.mtime}"
        build()
