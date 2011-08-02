define (require, exports, module) ->
  motions = require 'jim/motions'

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
      @command.visualExec this
      @lastCommand = @command if @command.isRepeatable
      @command = null

    if @inVisualMode()
      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()
