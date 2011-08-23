# An instance of Jim holds all the Jim-specific state of the editor.  The current command,
# the current mode, the values of all the registers, etc.  It also holds a reference to the
# adaptor that is doing its bidding in the editor.  Commands are passed an instance of Jim
# which allows them to change Jim's state and manipulate the editor (through the @adaptor).

Keymap     = require './keymap'
{GoToLine} = require './motions'

class Jim
  constructor: (@adaptor) ->
    @command = null
    @registers = {}
    @keymap = Keymap.getDefault()
    @setMode 'normal'

  modes: require './modes'

  setMode: (modeName) ->
    console.log 'setMode', modeName if @debugMode
    prevModeName = @modeName
    return if modeName is prevModeName
    @modeName = modeName
    modeParts = modeName.split ":"
    @mode = @modes[modeParts[0]]
    switch prevModeName
      when 'insert'  then @adaptor.moveLeft()
      when 'replace' then @adaptor.setOverwriteMode off
    @onModeChange? prevModeName

  inVisualMode: -> /^visual:/.test @modeName

  onEscape: ->
    @setMode 'normal'
    @command = null
    @commandPart = '' # just in case...
    @adaptor.clearSelection()

  onKeypress: (keys) -> @mode.onKeypress.call this, keys

  # delete the selected text, putting it in the default register
  deleteSelection: (exclusive, linewise) ->
    @registers['"'] = @adaptor.deleteSelection exclusive, linewise
    
  # yank the selected text into the default register
  yankSelection: (exclusive, linewise) ->
    @registers['"'] = @adaptor.selectionText exclusive, linewise
    @adaptor.clearSelection true

module.exports = Jim
