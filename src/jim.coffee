class Jim
  constructor: ->
    @buffer = ''
    @mode = 'command'

  keyup: (key) ->
    console.log 'key', key
    @buffer += key
    console.log '@buffer', @buffer
    command = CommandParser.parse(@buffer)
    console.log 'command', command
    if command
      command.execute()
      @buffer = ''

    command

#FIXME
window.Jim = Jim
