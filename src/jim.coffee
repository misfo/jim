class Jim
  constructor: ->
    @buffer = ''
    @setMode 'normal'

  setMode: (modeName) ->
    console.log 'setMode', modeName
    @buffer = ''
    @mode = modes[modeName]

  keypress: (key) ->
    if key is "esc"
      @setMode 'normal'
      return
    @buffer += key
    console.log '@buffer', @buffer
    result = @mode.parse(@buffer)
    if result is 'continueBuffering'
      method: 'doNothing'
    else
      @buffer = ''
      result
