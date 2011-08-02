define (require, exports, module) ->
  Keymap     = require 'jim/keymap'
  {GoToLine} = require 'jim/motions'

  class Jim
    constructor: (@adaptor) ->
      @command = null
      @registers = {}
      @keymap = Keymap.getDefault()
      @setMode 'normal'

    modes:
      insert: require 'jim/modes/insert'
      normal: require 'jim/modes/normal'
      replace: require 'jim/modes/replace'
      visual: require 'jim/modes/visual'

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
      @adaptor.clearSelection()

    onKeypress: (keys) -> @mode.onKeypress.call this, keys

    deleteSelection: (exclusive, linewise) ->
      @registers['"'] = @adaptor.deleteSelection exclusive, linewise
    yankSelection: (exclusive, linewise) ->
      @registers['"'] = @adaptor.selectionText exclusive, linewise
      @adaptor.clearSelection true
