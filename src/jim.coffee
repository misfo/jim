class Jim
  @movements: ///
    [hjkl]
  ///

  # modes are defined in src/modes/*
  @modes: {}

  constructor: ->
    @buffer = ''
    @setMode 'normal'

  setMode: (modeName) ->
    console.log 'setMode', modeName
    @buffer = ''
    prevMode = @mode
    #FIXME better way to refer to modes?
    @mode = Jim.modes[modeName]
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
