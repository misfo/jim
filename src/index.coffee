require
  paths:
    root: "."
    jim: "./lib"
    ace: "./vendor/ace/lib/ace"
    pilot: "./vendor/pilot/lib/pilot"
    text: "./vendor/text"

fileToEdit  = 'README.md'
#fileToEdit  = 'test/fixtures/sort_by.js'
fileRequire = "text!root/#{fileToEdit}"

require ['ace/ace', 'jim/ace', fileRequire, 'ace/theme/idle_fingers'], ->
  require.ready ->
    @editor = require('ace/ace').edit 'editor'
    jim = require('jim/ace').startup env: {editor}
    jim.debugMode = true
    editor.session.setValue require(fileRequire)
    editor.setTheme require('ace/theme/idle_fingers')

