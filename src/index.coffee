require
  paths:
    jim: "./lib"
    ace: "./vendor/ace/lib/ace"
    pilot: "./vendor/ace/support/pilot/lib/pilot"
    text: "./vendor/text"

require ['ace/ace', 'jim/ace/module', 'ace/theme/idle_fingers'], ->
  require.ready ->
    @editor = require('ace/ace').edit 'editor'
    require('jim/ace/module').startup env: {editor}
    editor.setTheme require('ace/theme/idle_fingers')

