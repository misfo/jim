fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = ("src/#{name}.coffee" for name in [
  'jim'
  'modes/normal'
  'modes/insert'
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
      filesCompiled = 0
      handleCompilation = (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        if ++filesCompiled is 2
          fs.unlink 'lib/jim.coffee', (err) ->
            throw err if err
            console.log 'Done.'
      exec 'coffee --compile lib/jim.coffee', handleCompilation
      exec 'coffee --compile --bare --print lib/jim.coffee > lib/jim-bare.js', handleCompilation

task 'build', 'Build single application file from source files (jim.js and jim-bare.js)', ->
  build()

task 'watch', 'Run build wheneven an app file changes', ->
  build()
  for file in appFiles then do (file) ->
    fs.watchFile file, (curr, prev) ->
      if "#{curr.mtime}" != "#{prev.mtime}"
        build()
