define (require, exports, module) ->
  {MoveLeft, MoveDown} = require 'jim/motions'

  exports.normal = do ->
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
            @command.motion = motion
            @command.motion.operation = @command
            @operatorPending = null
            @commandPart = ''

    invalidCommand = (type = 'command') ->
      console.log "invalid #{type}: #{@commandPart}"
      @onEscape()

    onKeypress: (keys) ->
      @commandPart = (@commandPart or '') + keys

      tokenize.call this

      if @command?.isComplete()
        @command.exec this
        @lastCommand = @command if @command.isRepeatable
        @command = null


  exports.visual = do ->
    invalidCommand = (type = 'command') ->
      console.log "invalid #{type}: #{@commandPart}"
      @commandPart = ''

    tokenize = ->
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

    onKeypress: (newKeys) ->
      @commandPart = (@commandPart or '') + newKeys

      tokenize.call this

      wasBackwards = @adaptor.isSelectionBackwards()

      if @command?.isOperation or @command?.isComplete()
        if @command.isRepeatable
          @command.selectionSize = if @modeName is 'visual:linewise'
            [minRow, maxRow] = @adaptor.selectionRowRange()
            lines: (maxRow - minRow) + 1
          else
            @adaptor.characterwiseSelectionSize()
          @command.linewise = @modeName is 'visual:linewise'
          @command.visualExec this
          @lastCommand = @command
          console.log 'repeatable visual command', @lastCommand
        else
          @command.visualExec this
        @command = null

      if @inVisualMode()
        if wasBackwards
          @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
        else
          @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()


  # insert and replace modes just pass all keystrokes through (except <esc>)
  exports.insert = onKeypress: -> true
  exports.replace = onKeypress: -> true

  return
