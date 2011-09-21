# Define the base class for all commands.
class exports.Command
  constructor: (@count = 1) ->
  isRepeatable: yes

  # If the class specifies a regex for char(s) that should follow the command,
  # then the command isn't complete until those char(s) have been matched.
  isComplete: ->
    if @constructor.followedBy then @followedBy else true

class exports.InputState
  constructor: ->
  	@clear()

  clear: ->
  	@command = null
  	@count = ''
  	@keymap = null
  	@operatorPending = null

  setCommand: (commandClass) ->
  	@command = new commandClass(parseInt(@count) or null)
  	@count = ''

  setOperationMotion: (motionClass) ->
    @command.motion = new motionClass(parseInt(@count) or null)

    # Motions need a reference to the operation they're a part of since it
    # sometimes changes the amount of text they move over (e.g. `cw`
    # deletes less text than `dw`).
    @command.motion.operation = @command

  	@count = ''

  toString: ->
  	"TODO"

# A bunch of commands can just repeat an action however many times their `@count`
# specifies.  For example `5x` does exactly the same thing as pressing `x` five times.
# This helper is used for that case.
exports.repeatCountTimes = (func) ->
  (jim) ->
    timesLeft = @count
    func.call this, jim while timesLeft--
