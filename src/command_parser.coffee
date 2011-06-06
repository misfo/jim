CommandParser =
  chunker: ///
      ^
      (\d*)    # multiplier
      ([hjkl]) # movement
      $
    ///

  parse: (commandString) ->
    command = null
    if match = commandString.match(@chunker)
      command = new MovementCommand(match[1], match[2])
    
    command
    
#FIXME
window.CommandParser = CommandParser
