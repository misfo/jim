define (require, exports, module) ->
  motions = require 'jim/motions'

  class Jim
    constructor: (@adaptor) ->
      @clearBuffer()
      @registers = {}
      @setMode 'normal'

    modes:
      insert: require 'jim/modes/insert'
      normal: require 'jim/modes/normal'
      replace: require 'jim/modes/replace'
      visual: require 'jim/modes/visual'

    clearBuffer: -> @buffer = @operator = ''

    setMode: (modeName) ->
      console.log 'setMode', modeName if @debugMode
      prevModeName = @modeName
      @clearBuffer()
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

    onKeypress: (key) ->
      @buffer += key
      console.log '@buffer', @buffer if @debugMode
      @mode.execute.call this

    joinLines: (rowStart, lines, replaceWithSpace) ->
      @adaptor.clearSelection()
      @adaptor.moveTo rowStart, 0
      timesLeft = Math.max(lines, 2) - 1
      while timesLeft--
        @adaptor.selectLineEnding replaceWithSpace
        @adaptor.deleteSelection()
        if replaceWithSpace
          @adaptor.insert ' '
          @adaptor.moveLeft()

    moveToFirstNonBlank: (row) ->
      row ?= @adaptor.row()
      line = @adaptor.lineText row
      column = /\S/.exec(line)?.index or 0
      @adaptor.moveTo row, column

    deleteSelection: (exclusive, linewise) ->
      @registers['"'] = @adaptor.deleteSelection exclusive, linewise
    yankSelection: (exclusive, linewise) ->
      @registers['"'] = @adaptor.selectionText exclusive, linewise
      @adaptor.clearSelection true
    indentSelection: ->
      [minRow, maxRow] = @adaptor.selectionRowRange()
      @adaptor.indentSelection()
      motions.move this, 'G', minRow + 1
    outdentSelection: ->
      [minRow, maxRow] = @adaptor.selectionRowRange()
      @adaptor.outdentSelection()
      motions.move this, 'G', minRow + 1
