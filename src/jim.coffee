class Jim
  constructor: ->
    @buffer = ''
    @setMode 'normal'

  setMode: (modeName) ->
    console.log 'setMode', modeName
    @buffer = ''
    @mode = modes[modeName]

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
