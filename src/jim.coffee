class Jim
  constructor: ->
    @buffer = ''
    @setMode 'normal'

  setMode: (modeName) ->
    console.log 'setMode', modeName
    @buffer = ''
    prevMode = @mode
    @mode = modes[modeName]
    @onModeChange?(modeName) if @mode isnt prevMode

  onEscape: ->
      @setMode 'normal'

  onKeypress: (key) ->
    @buffer += key
    console.log '@buffer', @buffer
    result = @mode.parse(@buffer)
    if result is 'continueBuffering'
      method: 'doNothing'
    else
      @buffer = ''
      result
