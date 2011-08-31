# An instance of Jim holds all the Jim-specific state of the editor.  The current command,
# the current mode, the values of all the registers, etc.  It also holds a reference to the
# adaptor that is doing its bidding in the editor.  Commands are passed an instance of Jim
# which allows them to change Jim's state and manipulate the editor (through the @adaptor).

Keymap     = require './keymap'
{GoToLine} = require './motions'

class Jim
  @VERSION: '0.2.0-pre'

  constructor: (@adaptor) ->
    @command = null
    @registers = {}
    @keymap = Keymap.getDefault()
    @setMode 'normal'

  modes: require './modes'

  # changes Jim's mode to `modeName` with optional `modeState`:
  #
  #     @setMode 'visual', linewise: yes
  setMode: (modeName, modeState) ->
    console.log 'setMode', modeName, modeState if @debugMode
    prevMode = @mode
    if modeName is prevMode?.name
      return unless modeState
      @mode[key] = value for own key, value of modeState
    else
      @mode = modeState or {}
      @mode.name = modeName

    switch prevMode?.name
      when 'insert'  then @adaptor.moveLeft()
      when 'replace' then @adaptor.setOverwriteMode off
    @onModeChange? prevMode

  # pressing escape blows away all the state
  onEscape: ->
    @setMode 'normal'
    @command = null
    @commandPart = '' # just in case...
    @adaptor.clearSelection()

  # when a key is pressed let the current mode figure out what to do about it
  onKeypress: (keys) -> @modes[@mode.name].onKeypress.call this, keys

  # delete the selected text, putting it in the default register
  deleteSelection: (exclusive, linewise) ->
    @registers['"'] = @adaptor.deleteSelection exclusive, linewise
    
  # yank the selected text into the default register
  yankSelection: (exclusive, linewise) ->
    @registers['"'] = @adaptor.selectionText exclusive, linewise
    @adaptor.clearSelection true

module.exports = Jim
