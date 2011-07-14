define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([iaoOIAC])|         # insert mode switch
    ([vV])|              # visual mode switch
    (D)|                 # delete to end of line command
    (?:
      ([1-9]\d*)?        # count (multiplier, line number, ...)
      (?:
        ([pPsxXu])|      # commands
        (?:
          ([cdy])?       # operators
          ([1-9]\d*)?    # count (multiplier, line number, ...)
          (#{motions.regex.source})?
        )
      )?
    )
    $
  ///

  execute: ->
    match = @buffer.match regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{@buffer}"
      @onEscape()
      return

    [fullMatch, @insertSwitch, visualSwitch, deleteCommand, countMatch, command,
      @operator, motionCountMatch, motion] = match
    count       = parseInt(countMatch) or null
    motionCount = parseInt(motionCountMatch) or null

    continueBuffering = false

    if @insertSwitch
      switch @insertSwitch
        when 'a' then @adaptor.moveRight true
        when 'A'
          motions['$'].move this
          @adaptor.moveRight true
        when 'C' then motions['$'].change this
        when 'o', 'O'
          row = @adaptor.row() + (if @insertSwitch is 'o' then 1 else 0)
          @adaptor.insertNewLine row
          @adaptor.moveTo row, 0
        when 'I' then @adaptor.navigateLineStart()
      @setMode 'insert'
    else if visualSwitch
      @adaptor.setSelectionAnchor()
      if visualSwitch is 'V'
        @setMode 'visual:linewise'
      else
        @setMode 'visual:characterwise'
    else if deleteCommand
      motions['$'].delete this
    else if motion
      motionObj = motions[motion]
      motionCount = (count or 1) * (motionCount or 1) if count or motionCount
      switch @operator
        when 'c' then motionObj.change this, motionCount
        when 'd' then motionObj.delete this, motionCount
        when 'y' then motionObj.yank   this, motionCount
        else          motionObj.move   this, motionCount
    else if command
      switch command
        when "p", "P"
          text = new Array((count or 1) + 1).join @registers['"']
          after = command is "p"
          @adaptor.insert text, after
        when 's' then motions['l'].change this, count
        when "x", "X"
          deleteMotion = if command is 'X' then 'h' else 'l'
          motions[deleteMotion].delete this, count
        when "u"
          timesLeft = count ? 1
          @adaptor.undo() while timesLeft--
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
