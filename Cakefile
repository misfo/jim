fs = require 'fs'
CoffeeScript = require 'coffee-script'

sourceNames = [
  # in dependency order
  'helpers'
  'motions'
  'operators'
  'commands'
  'keymap'
  'modes'
  'jim'
  'ace'
]


task 'build:ace', 'build Jim for use with Ace', ->
  # based on coffee-script's dead-simple `cake build:browser`
  jsCode = ''
  for sourceName in sourceNames
    source = "src/#{sourceName}.coffee"

    coffeeCode = fs.readFileSync source, 'utf8'
    jsCode += """

      require['./#{sourceName}'] = (function() {
        var exports = {}, module = {};
        #{CoffeeScript.compile coffeeCode, bare: yes}
        return module.exports || exports;
      })();

    """

  jsCode = """
    /**
     * Jim v#{require('./src/jim').VERSION}
     * https://github.com/misfo/jim
     *
     * Copyright 2011, Trent Ogren
     * Released under the MIT License
     */
    this.Jim = (function() {
      function require(path) { return path[0] === '.' ? require[path] : window.require(path); }
      #{jsCode}
      return require['./jim'];
    })()
  """

  filename = 'build/jim-ace-uncompressed.js'
  fs.writeFileSync filename, jsCode
  console.log "#{(new Date).toLocaleTimeString()} - built #{filename}"

task 'build:ace:watch', 'continuously build Jim for use with Ace', ->
  invoke 'build:ace'
  for sourceName in sourceNames
    fs.watchFile "src/#{sourceName}.coffee", {persistent: yes, interval: 500}, (curr, prev) ->
      invoke 'build:ace' unless curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()
