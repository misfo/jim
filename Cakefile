fs = require 'fs'
CoffeeScript = require 'coffee-script'

sourceNames = [
  'ace'
  'commands'
  'helpers'
  'jim'
  'keymap'
  'modes'
  'motions'
  'operators'
]

compileModule = (sourceName) ->
  source = "src/#{sourceName}.coffee"
  lib    = "lib/#{sourceName}.js"

  fs.readFile source, (err, coffeeCode) ->
    try
      jsCode = CoffeeScript.compile coffeeCode.toString(), bare: yes
      jsCode = """
        define(function(require, exports, module) {

        #{jsCode}

        });
      """
      fs.writeFile lib, jsCode, (err) ->
        console.log "#{(new Date).toLocaleTimeString()} - compiled #{source}"
    catch err
      console.log "err while compiling #{source}", err

task 'compile', 'compile individual files for development', ->
  compileModule(sourceName) for sourceName in sourceNames

task 'watch', 'watch files in src/, compiling for development', ->
  invoke 'compile'
  for sourceName in sourceNames
    do (sourceName) ->
      fs.watchFile "src/#{sourceName}.coffee", {persistent: yes, interval: 500}, (curr, prev) ->
        unless curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()
          compileModule sourceName
