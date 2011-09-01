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
    # `@commandPart` is the current part of the command that's being typed.  For an
    # operation, the operator is one "part" and the motion is another. In normal or
    # visual mode, `@commandPart` can one of the following in normal mode:
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
          # hang onto the pending operator so that double-operators can recognized
          # (`cc`, `yy`, etc)
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
          # motions need a reference to the operation they're a part of since it sometimes
          # changes the amount of text they move over (`cw` deletes less text than `dw`)
          motion.operation = @command

          @command.motion = motion
          @operatorPending = null
          @commandPart = ''

    # execute the command if it's complete, otherwise wait for more keys
    if @command?.isComplete()
      @command.exec this
      @lastCommand = @command if @command.isRepeatable
      @command = null


# visual mode
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

    # operations are always "complete" in visual mode
    if @command?.isOperation or @command?.isComplete()
      if @command.isRepeatable
        # save the selection's "size", which will be used if the command is repeated
        @command.selectionSize = if @mode.name is 'visual' and @mode.linewise
          [minRow, maxRow] = @adaptor.selectionRowRange()
          lines: (maxRow - minRow) + 1
        else
          @adaptor.characterwiseSelectionSize()
        @command.linewise = @mode.linewise

        @lastCommand = @command

      @command.visualExec this
      @command = null

    # if we haven't changed out of characterwise visual mode and the direction
    # of the selection changes we have to make sure that the anchor character
    # stays selected
    if @mode.name is 'visual' and not @mode.linewise
      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()


# insert and replace modes just pass all keystrokes through (except <esc>)
exports.insert = onKeypress: -> true
exports.replace = onKeypress: -> true
