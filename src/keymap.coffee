# This is a pretty standard key-to-command keymap except for a few details:
#
# * It has some built-in Vim-like smarts about the concepts of motions and
#   operators and if/how they should be available in each mode
# * It differentiates between invalid commands (`gz`) and partial commands (`g`)
class Keymap

  # Build an instance of Keymap with all the default keymappings.
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

    # Use some objects to de-duplicate repeated partial commands.
    @partialCommands = {}
    @partialMotions = {}
    @partialVisualCommands = {}

  # Map the `comandClass` to the `keys` sequence.  Map it as a visual command as well
  # if the class has a `::visualExec`.
  mapCommand: (keys, commandClass) ->
    if commandClass::exec
      @commands[keys] = commandClass
      if keys.length is 2
        @partialCommands[keys[0]] = true
    if commandClass::visualExec
      @visualCommands[keys] = commandClass
      if keys.length is 2
        @partialVisualCommands[keys[0]] = true

  # Map `motionClass` to the `keys` sequence.
  mapMotion: (keys, motionClass) ->
    @commands[keys] = motionClass
    @motions[keys] = motionClass
    @visualCommands[keys] = motionClass
    if keys.length is 2
      @partialMotions[keys[0]] = true
      @partialCommands[keys[0]] = true
      @partialVisualCommands[keys[0]] = true

  # Map `operatorClass` to the `keys` sequence.
  mapOperator: (keys, operatorClass) ->
    @commands[keys] = operatorClass
    @visualCommands[keys] = operatorClass
    if keys.length is 2
      @partialCommands[keys[0]] = true
      @partialVisualCommands[keys[0]] = true

  # Build a regex that will match any key sequence, splitting it into the
  # following capture groups:
  #
  # 1. The preceding count
  # 2. The command/motion/operator
  # 3. Any chars beyond a *partial* command/motion/operator. If this group
  #    captures *any* characters, we know the command is not a partial
  #    command for which we should continue accepting keystrokes.
  buildPartialCommandRegex = (partialCommands) ->
    ///
      ^
      ([1-9]\d*)?
      (
        [#{(char for own char, nothing of partialCommands).join ''}]?
        ([\s\S]*)
      )?
      $
    ///


  # returns:
  # * a `Command` with a count if `commandPart` is a complete command:
  #     commandFor('12gg') # returns GoToLine with a count of 12
  # * true if `commandPart` is a valid partial command
  # * false if `commandPart` is invalid
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

  # returns:
  # * a `Motion` with a count if `motionPart` is a complete motion:
  #     motionFor('3j') # returns MoveDown with a count of 3
  # * true if `motionPart` is a valid partial motion
  # * false if `motionPart` is invalid
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

  # returns:
  # * a `Command` with a count if `commandPart` is a complete visual command:
  #     visualCommandFor('c') # returns Change with a count of `null`
  # * true if `commandPart` is a valid partial visual command
  # * false if `commandPart` is invalid
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
