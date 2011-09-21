# Each mode handles key presses a bit differently.  For instance, typing an
# operator in visual mode immediately operates on the selected text. In normal
# mode Jim waits for a motion to follow the operator.  All of the modes'
# keyboard handling is defined here.
#
# Each mode's `onkeypress` is executed in the context of an instance of `Jim`.

# Define an unmapped `Motion` that will be used for double operators (e.g. `cc`,
# `2yy`, `3d4d`).
class LinewiseCommandMotion
  constructor: (@count = 1) ->
  linewise: yes
  isComplete: -> yes
  exec: (jim) ->
    additionalLines = @count - 1
    jim.adaptor.moveDown() while additionalLines--


# Shame the user in the console for not knowing their Jim commands.
invalidCommand = (type = 'command') ->
  console.log "invalid #{type}: #{@inputState}"
  @onEscape()


# Normal mode (a.k.a. "command mode")
# -----------------------------------
exports.normal =
  onKeypress: (key) ->
    if /^[1-9]$/.test(key) or (key is "0" and @inputState.count.length)
      @inputState.count += key

    else if not @inputState.command
      commandClass = (@inputState.keymap or Jim.keymap.normal)[key]

      if not commandClass
        invalidCommand.call this

      else if commandClass.prototype
        @inputState.setCommand commandClass

        if @inputState.command.isOperation
          # Hang onto the pending operator so that double-operators can
          # recognized (`cc`, `yy`, etc).
          @inputState.operatorPending = key

      else if commandClass
        @inputState.keymap = commandClass

    else if @inputState.command.constructor.followedBy
      # If we've got a command that expects a key to follow it, check if
      # the key is what it's expecting.
      if @inputState.command.constructor.followedBy.test key
        @inputState.command.followedBy = key
      else
        console.log "#{@inputState.command} didn't expect to be followed by \"#{key}\""

    else if @inputState.operatorPending
      if regex = @inputState.command.motion?.constructor.followedBy

        # If we've got a motion that expects a key to follow it, check if
        # the key is what it's expecting.
        if regex.test key
          @inputState.command.motion.followedBy = key
        else
          console.log "#{@inputState.command} didn't expect to be followed by \"#{key}\""

      else
        motionClass = if key is @inputState.operatorPending
          LinewiseCommandMotion
        else
          (@inputState.keymap or Jim.keymap.operatorPending)[key]

        if not motionClass
          invalidCommand.call this

        else if motionClass.prototype
          @inputState.setOperationMotion motionClass

        else
          @inputState.keymap = motion

    # Execute the command if it's complete, otherwise wait for more keys.
    if @inputState.command?.isComplete()
      @inputState.command.exec this
      @lastCommand = @inputState.command if @inputState.command.isRepeatable
      @inputState.clear()


# Visual mode
# -----------
exports.visual =
  onKeypress: (key) ->
    if /^[1-9]$/.test(key) or (key is "0" and @inputState.count.length)
      @inputState.count += key

    else if not @inputState.command
      commandClass = (@inputState.keymap or Jim.keymap.visual)[key]

      if not commandClass
        invalidCommand.call this

      else if commandClass.prototype
        @inputState.setCommand commandClass

      else
        @inputState.keymap = commandClass

    else if @inputState.command.constructor.followedBy

      # If we've got a motion that expects a key to follow it, check if
      # the key is what it's expecting.
      if @inputState.command.constructor.followedBy.test key
        @inputState.command.followedBy = key
      else
        console.log "#{@inputState.command} didn't expect to be followed by \"#{key}\""

    wasBackwards = @adaptor.isSelectionBackwards()

    # Operations are always "complete" in visual mode.
    if @inputState.command?.isOperation or @inputState.command?.isComplete()
      if @inputState.command.isRepeatable
        # Save the selection's "size", which will be used if the command is
        # repeated.
        @inputState.command.selectionSize = if @mode.name is 'visual' and @mode.linewise
          [minRow, maxRow] = @adaptor.selectionRowRange()
          lines: (maxRow - minRow) + 1
        else
          @adaptor.characterwiseSelectionSize()
        @inputState.command.linewise = @mode.linewise

        @lastCommand = @inputState.command

      @inputState.command.visualExec this
      @inputState.clear()

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
