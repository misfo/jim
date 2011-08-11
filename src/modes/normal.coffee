# normal mode commands can take the following forms:
#     [count] command
# or
#     [count] motion
# or
#     [count] operator [count] motion
define (require, exports, module) ->
  {MoveLeft, MoveDown} = require 'jim/motions'

  # tokenize the command into the @command object or nullify
  # it if something invalid is encountered
  #
  # token names:
  #    count
  #    command
  #    operator
  #    motionCount
  #    motion
  tokenize = ->
    if not @command
      command = @keymap.commandFor @commandPart

      if command is false
        invalidCommand.call this
      else if command isnt true
        if command.isOperation
          [@operatorPending] = @commandPart.match /[^\d]+$/
        @command = command
        @commandPart = ''
    else if @command.constructor.followedBy
      # if we've got a command that expects a key to follow it,
      # check if nextToken is what it's expecting
      if @command.constructor.followedBy.test @commandPart
        @command.followedBy = @commandPart
      else
        console.log "#{@command} didn't expect to be followed by \"#{@commandPart}\""
      @commandPart = ''
    else if @command.isOperation
      motion = @keymap.motionFor @commandPart, @operatorPending

      if motion is false
        invalidCommand.call this, 'motion'
      else if motion isnt true
        @command.motion = motion
        @command.motion.operation = @command
        @operatorPending = null
        @commandPart = ''

  invalidCommand = (type = 'command') ->
    console.log "invalid #{type}: #{@commandPart}"
    @commandPart = ''

  exports.onKeypress = (keys) ->
    @commandPart = (@commandPart or '') + keys

    tokenize.call this

    if @command?.isComplete()
      @command.exec this
      @lastCommand = @command if @command.isRepeatable
      @command = null

  return
