class Keymap
  @getDefault: ->
    keymap = new Keymap
    keymap.mapCommand keys, commandClass for own keys, commandClass of require('./commands').defaultMappings
    keymap.mapOperator keys, operationClass for own keys, operationClass of require('./operators').defaultMappings
    keymap.mapMotion keys, motionClass for own keys, motionClass of require('./motions').defaultMappings
    keymap

  constructor: ->
    @commands = {}
    @motions = {}
    @visualCommands = {}

    # use objects to de-dup
    @partialCommands = {}
    @partialMotions = {}
    @partialVisualCommands = {}

  mapCommand: (keys, commandClass) ->
    if commandClass::exec
      @commands[keys] = commandClass
      if keys.length is 2
        @partialCommands[keys[0]] = true
    if commandClass::visualExec
      @visualCommands[keys] = commandClass
      if keys.length is 2
        @partialVisualCommands[keys[0]] = true

  mapMotion: (keys, motionClass) ->
    @commands[keys] = motionClass
    @motions[keys] = motionClass
    @visualCommands[keys] = motionClass
    if keys.length is 2
      @partialMotions[keys[0]] = true
      @partialCommands[keys[0]] = true
      @partialVisualCommands[keys[0]] = true

  mapOperator: (keys, operatorClass) ->
    @commands[keys] = operatorClass
    @visualCommands[keys] = operatorClass
    if keys.length is 2
      @partialCommands[keys[0]] = true
      @partialVisualCommands[keys[0]] = true

  buildPartialCommandRegex = (partialCommands) ->
    ///
      ^
      ([1-9]\d*)?
      (
        [#{(char for own char, nothing of partialCommands).join ''}]?
        # if the group below captures something, we know outer group is
        # is more than just a partial command (could be invalid, though)
        ([\s\S]*)
      )?
      $
    ///

  # returns a Command with a count if the commandPart is a complete command (e.g. '12gg')
  # returns true if commandPart is a valid partial command
  # returns false if commandPart is invalid
  commandFor: (commandPart) ->
    @partialCommandRegex or= buildPartialCommandRegex @partialCommands
    [commandPart, count, command, beyondPartial] = commandPart.match @partialCommandRegex

    if beyondPartial
      if commandClass = @commands[command]
        new commandClass(parseInt(count) or null)
      else
        false
    else
      # it's a partial command
      true

  motionFor: (commandPart, operatorPending) ->
    @partialMotionRegex or= buildPartialCommandRegex @partialMotions
    [commandPart, count, motion, beyondPartial] = commandPart.match @partialCommandRegex

    if beyondPartial
      if motion is operatorPending
        # e.g `cc`, `yy`
        {LinewiseCommandMotion} = require './motions'
        new LinewiseCommandMotion(parseInt(count) or null)
      else if motionClass = @motions[motion]
        new motionClass(parseInt(count) or null)
      else
        false
    else
      # it's a partial command
      true

  visualCommandFor: (commandPart) ->
    @partialVisualCommandRegex or= buildPartialCommandRegex @partialVisualCommands
    [commandPart, count, command, beyondPartial] = commandPart.match @partialVisualCommandRegex

    if beyondPartial
      if commandClass = @visualCommands[command]
        new commandClass(parseInt(count) or null)
      else
        false
    else
      # it's a partial command
      true

module.exports = Keymap
