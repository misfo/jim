define (require, exports, module) ->
  class Jim
    @modes:
      insert: require 'jim/modes/insert'
      normal: require 'jim/modes/normal'
      visual: require 'jim/modes/visual'

    constructor: (@adaptor) ->
      @buffer = ''
      @registers = {}
      @setMode 'normal'

    setMode: (modeName) ->
      console.log 'setMode', modeName
      prevModeName = @modeName
      @buffer = ''
      return if modeName is prevModeName
      @modeName = modeName
      modeParts = modeName.split ":"
      @mode = Jim.modes[modeParts[0]]
      @onModeChange? prevModeName

    onEscape: ->
      @setMode 'normal'
      @adaptor.clearSelection()

    onKeypress: (key) ->
      @buffer += key
      console.log '@buffer', @buffer
      @mode.execute.call this

    deleteSelection: (exclusive) -> @registers['"'] = @adaptor.deleteSelection exclusive
    yankSelection:   (exclusive) -> @registers['"'] = @adaptor.selectionText exclusive

    times: (number, func) ->
      number = 1 if not number? or number is ""
      func.call this while number--
