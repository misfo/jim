# Key handling for each of Jim's modes
#
# Each mode handles key presses a bit differently.  For instance, typing an operator in
# visual mode immediately operates on the selected text. In normal mode Jim
# waits for a motion to follow the operator.

{MoveLeft, MoveDown} = require './motions'

# shame the user in the console for not knowing their Jim commands
invalidCommand = (type = 'command') ->
  console.log "invalid #{type}: #{@commandPart}"
  @onEscape()

# Normal mode (a.k.a. Command mode)
exports.normal =
  onKeypress: (keys) ->
    # `@commandPart` can one of the following in normal mode
    #   * `{count}command`
    #   * `{count}motion`
    #   * `{count}operator`
    #   * chars expected to follow a command (e.g. when `r` is pressed, the next
    #     `@commandPart` will be the char that's used in the replace)
    @commandPart = (@commandPart or '') + keys

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
      # check if @commandPart is what it's expecting
      if @command.constructor.followedBy.test @commandPart
        @command.followedBy = @commandPart
      else
        console.log "#{@command} didn't expect to be followed by \"#{@commandPart}\""
      @commandPart = ''
    else if @command.isOperation
      if regex = @command.motion?.constructor.followedBy
        # if we've got a motion that expects a key to follow it,
        # check if @commandPart is what it's expecting
        if regex.test @commandPart
          @command.motion.followedBy = @commandPart
        else
          console.log "#{@command} didn't expect to be followed by \"#{@commandPart}\""
      else
        motion = @keymap.motionFor @commandPart, @operatorPending

        if motion is false
          invalidCommand.call this, 'motion'
        else if motion isnt true
          motion.operation = @command
          @command.motion = motion
          @operatorPending = null
          @commandPart = ''

    if @command?.isComplete()
      @command.exec this
      @lastCommand = @command if @command.isRepeatable
      @command = null


exports.visual =
  onKeypress: (newKeys) ->
    @commandPart = (@commandPart or '') + newKeys

    if not @command
      command = @keymap.visualCommandFor @commandPart

      if command is false
        invalidCommand.call this
      else if command isnt true
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
    wasBackwards = @adaptor.isSelectionBackwards()

    if @command?.isOperation or @command?.isComplete()
      if @command.isRepeatable
        @command.selectionSize = if @mode.name is 'visual' and @mode.linewise
          [minRow, maxRow] = @adaptor.selectionRowRange()
          lines: (maxRow - minRow) + 1
        else
          @adaptor.characterwiseSelectionSize()
        @command.linewise = @mode.name is 'visual' and @mode.linewise
        @command.visualExec this
        @lastCommand = @command
        console.log 'repeatable visual command', @lastCommand
      else
        @command.visualExec this
      @command = null

    if @mode.name is 'visual'
      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()


# insert and replace modes just pass all keystrokes through (except <esc>)
exports.insert = onKeypress: -> true
exports.replace = onKeypress: -> true
