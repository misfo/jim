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
    match = @buffer.match(@mode.regex)
    result = null
    if match?
      result = @mode.execute(match)
      @buffer = '' if result? and result.method isnt 'doNothing'
    else
      console.log "unrecognized command: #{@buffer}"
      @buffer = ''
    
    result
