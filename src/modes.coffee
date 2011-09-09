# Each mode handles key presses a bit differently.  For instance, typing an
# operator in visual mode immediately operates on the selected text. In normal
# mode Jim waits for a motion to follow the operator.  All of the modes'
# keyboard handling is defined here.
#
# Each mode's `onkeypress` is executed in the context of an instance of `Jim`.
# In normal and visual mode the current `@commandPart` is the current *part* of
# the command that's being typed.  For an operation, the operator is one *part*
# and the motion is another. `@commandPart` can one of the following:
#
#   * `{count}command`
#   * `{count}motion`
#   * `{count}operator`
#   * chars expected to follow a command (e.g. when `r` is pressed, the next
#     `@commandPart` will be the char that's used as the replacement)

{MoveLeft, MoveDown} = require './motions'

# Shame the user in the console for not knowing their Jim commands.
invalidCommand = (type = 'command') ->
  console.log "invalid #{type}: #{@commandPart}"
  @onEscape()

# Normal mode (a.k.a. "command mode")
# -----------------------------------
exports.normal =
  onKeypress: (keys) ->
    @commandPart = (@commandPart or '') + keys

    if not @command
      command = @keymap.commandFor @commandPart

      if command is false
        invalidCommand.call this
      else if command isnt true
        if command.isOperation
          # Hang onto the pending operator so that double-operators can
          # recognized (`cc`, `yy`, etc).
          [@operatorPending] = @commandPart.match /[^\d]+$/

        @command = command
        @commandPart = ''
    else if @command.constructor.followedBy
      # If we've got a command that expects a key to follow it, check if
      # `@commandPart` is what it's expecting.
      if @command.constructor.followedBy.test @commandPart
        @command.followedBy = @commandPart
      else
        console.log "#{@command} didn't expect to be followed by \"#{@commandPart}\""

      @commandPart = ''
    else if @command.isOperation
      if regex = @command.motion?.constructor.followedBy

        # If we've got a motion that expects a key to follow it, check if
        # `@commandPart` is what it's expecting.
        if regex.test @commandPart
          @command.motion.followedBy = @commandPart
        else
          console.log "#{@command} didn't expect to be followed by \"#{@commandPart}\""

      else
        motion = @keymap.motionFor @commandPart, @operatorPending

        if motion is false
          invalidCommand.call this, 'motion'
        else if motion isnt true
          # Motions need a reference to the operation they're a part of since it
          # sometimes changes the amount of text they move over (e.g. `cw`
          # deletes less text than `dw`).
          motion.operation = @command

          @command.motion = motion
          @operatorPending = null
          @commandPart = ''

    # Execute the command if it's complete, otherwise wait for more keys.
    if @command?.isComplete()
      @command.exec this
      @lastCommand = @command if @command.isRepeatable
      @command = null


# Visual mode
# -----------
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

      # If we've got a motion that expects a key to follow it, check if
      # `@commandPart` is what it's expecting.
      if @command.constructor.followedBy.test @commandPart
        @command.followedBy = @commandPart
      else
        console.log "#{@command} didn't expect to be followed by \"#{@commandPart}\""
      @commandPart = ''

    wasBackwards = @adaptor.isSelectionBackwards()

    # Operations are always "complete" in visual mode.
    if @command?.isOperation or @command?.isComplete()
      if @command.isRepeatable
        # Save the selection's "size", which will be used if the command is
        # repeated.
        @command.selectionSize = if @mode.name is 'visual' and @mode.linewise
          [minRow, maxRow] = @adaptor.selectionRowRange()
          lines: (maxRow - minRow) + 1
        else
          @adaptor.characterwiseSelectionSize()
        @command.linewise = @mode.linewise

        @lastCommand = @command

      @command.visualExec this
      @command = null

    # If we haven't changed out of characterwise visual mode and the direction
    # of the selection changes, we have to make sure that the anchor character
    # stays selected.
    if @mode.name is 'visual' and not @mode.linewise
      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()


# Other modes
# -----------
#
# Insert and replace modes just pass all keystrokes through (except `<esc>`).
exports.insert = onKeypress: -> true
exports.replace = onKeypress: -> true
