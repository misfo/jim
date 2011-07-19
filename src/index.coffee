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

require ['ace/ace', 'jim/ace/module', fileRequire, 'ace/theme/idle_fingers'], ->
  require.ready ->
    @editor = require('ace/ace').edit 'editor'
    require('jim/ace/module').startup env: {editor}
    editor.session.setValue require(fileRequire)
    editor.setTheme require('ace/theme/idle_fingers')

