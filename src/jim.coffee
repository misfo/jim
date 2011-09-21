# An instance of `Jim` holds all the Jim-specific state of the editor: the
# current command, the current mode, the values of all the registers, etc. It
# also holds a reference to the adaptor that is doing its bidding in the editor.
# `Command`s are passed an instance of `Jim` when they are executed which allows
# them to change Jim's state and manipulate the editor (through the `@adaptor`).

{InputState} = require './helpers'
Keymap       = require './keymap'

class Jim
  @VERSION: '0.2.1-pre'

  @keymap: new Keymap

  constructor: (@adaptor) ->
    @registers = {}
    @setMode 'normal'
    @inputState = new InputState

  modes: require './modes'

  # Change Jim's mode to `modeName` with optional `modeState`:
  #
  #     jim.setMode 'visual', linewise: yes
  setMode: (modeName, modeState) ->
    console.log 'setMode', modeName, modeState if @debugMode
    prevMode = @mode
    if modeName is prevMode?.name
      return unless modeState
      @mode[key] = value for own key, value of modeState
    else
      @mode = modeState or {}
      @mode.name = modeName
      
    @adaptor.onModeChange? prevMode, @mode

    switch prevMode?.name
      when 'insert'
        @adaptor.moveLeft()

        # Get info about what was inserted so the insert "remembers" how to
        # repeat itself.
        @lastCommand.repeatableInsert = @adaptor.lastInsert()

      when 'replace'
        @adaptor.setOverwriteMode off

  # Pressing escape blows away all the state.
  onEscape: ->
    @setMode 'normal'
    @inputState.clear()
    @adaptor.clearSelection()

  # When a key is pressed, let the current mode figure out what to do about it.
  onKeypress: (keys) -> @modes[@mode.name].onKeypress.call this, keys

  # Delete the selected text and put it in the default register.
  deleteSelection: (exclusive, linewise) ->
    @registers['"'] = @adaptor.deleteSelection exclusive, linewise
    
  # Yank the selected text into the default register.
  yankSelection: (exclusive, linewise) ->
    @registers['"'] = @adaptor.selectionText exclusive, linewise
    @adaptor.clearSelection true

module.exports = Jim
