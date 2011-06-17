fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  # omit src/ and .coffee to make the below lines a little shorter
  'modes'
  'jim'
  'ace_adaptor'
]

task 'build', 'Build single application file from source files', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
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
