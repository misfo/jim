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
    prevModeName = @modeName
    @modeName = modeName
    @buffer = ''
    #FIXME better way to refer to modes?
    modeParts = modeName.split ":"
    @mode = Jim.modes[modeParts[0]]
    @onModeChange? prevModeName if modeName isnt prevModeName

  onEscape: ->
      @setMode 'normal'

  onKeypress: (key) ->
    @buffer += key
    console.log '@buffer', @buffer
    result = @mode.parse(@buffer)
    if result is 'continueBuffering'
      return method: 'doNothing'

    @buffer = ''
    result
