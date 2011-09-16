# This is a pretty standard key-to-command keymap except for a few details:
#
# * It has some built-in Vim-like smarts about the concepts of motions and
#   operators and if/how they should be available in each mode
# * It differentiates between invalid commands (`gz`) and partial commands (`g`)
class Keymap

  # Building a Keymap
  # -----------------

  # Build an instance of `Keymap` with all the default keymappings.
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


  # Mapping commands
  # ----------------

  # Map the `comandClass` to the `keys` sequence.  Map it as a visual command as well
  # if the class has a `::visualExec`.
  mapCommand: (keys, commandClass) ->
    if commandClass::exec
      @commands[keys] = commandClass
      if keys.length is 2 and keys isnt 'up'
        @partialCommands[keys[0]] = true
    if commandClass::visualExec
      @visualCommands[keys] = commandClass
      if keys.length is 2 and keys isnt 'up'
        @partialVisualCommands[keys[0]] = true

  # Map `motionClass` to the `keys` sequence.
  mapMotion: (keys, motionClass) ->
    @commands[keys] = motionClass
    @motions[keys] = motionClass
    @visualCommands[keys] = motionClass
    if keys.length is 2 and keys isnt 'up'
      @partialMotions[keys[0]] = true
      @partialCommands[keys[0]] = true
      @partialVisualCommands[keys[0]] = true

  # Map `operatorClass` to the `keys` sequence.
  mapOperator: (keys, operatorClass) ->
    @commands[keys] = operatorClass
    @visualCommands[keys] = operatorClass
    if keys.length is 2 and keys isnt 'up'
      @partialCommands[keys[0]] = true
      @partialVisualCommands[keys[0]] = true


  # Finding commands in the Keymap
  # ------------------------------
  #
  # `commandFor`, `motionFor`, and `visualCommandFor` are defined for finding
  # their respective `Command` types.  Each of these methods will return one of the
  # following:
  #
  # * `true` if the `commandPart` passed in is a valid *partial* command.  For
  #   example, `Keymap.getDefault().commandFor('g')` will return `true` because
  #   it is the first part of what could be the valid command `gg`, among
  #   others.
  # * `false` if the `commandPart` is not a valid partial *or* complete command.
  # * A `Command` if the `commandPart` is a valid, complete command.  The
  #   `Command` will have it's `count` populated if `commandPart` includes a
  #   count.

  # Build a regex that will help us split up the `commandPart` in each of the
  # following methods.  The regex will match any key sequence, splitting it into
  # the following captured groups:
  #
  # 1. The preceding count
  # 2. The command/motion/operator
  # 3. Any chars beyond a *partial* command/motion/operator. If this group
  #    captures *anything*, we can stop accepting keystrokes for the command and
  #    execute it if it's valid.
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


  # Find a normal mode command, which could be a motion, an operator, or a
  # "regular" normal mode command.
  commandFor: (commandPart) ->
    @partialCommandRegex or= buildPartialCommandRegex @partialCommands
    [commandPart, count, command, beyondPartial] = commandPart.match @partialCommandRegex

    if beyondPartial
      if commandClass = @commands[command]
        new commandClass(parseInt(count) or null)
      else
        false
    else
      true

  # Find a motion.
  motionFor: (commandPart, operatorPending) ->
    @partialMotionRegex or= buildPartialCommandRegex @partialMotions
    [commandPart, count, motion, beyondPartial] = commandPart.match @partialCommandRegex

    if beyondPartial
      if motion is operatorPending

        # If we're finding `cc`, `yy`, etc, we return a "fake" linewise command.
        {LinewiseCommandMotion} = require './motions'
        new LinewiseCommandMotion(parseInt(count) or null)

      else if motionClass = @motions[motion]
        new motionClass(parseInt(count) or null)
      else
        false
    else
      true

  # Find a visual mode command, which could be a motion, an operator, or a
  # "regular" visual mode command.
  visualCommandFor: (commandPart) ->
    @partialVisualCommandRegex or= buildPartialCommandRegex @partialVisualCommands
    [commandPart, count, command, beyondPartial] = commandPart.match @partialVisualCommandRegex

    if beyondPartial
      if commandClass = @visualCommands[command]
        new commandClass(parseInt(count) or null)
      else
        false
    else
      true


# Exports
# -------
module.exports = Keymap
