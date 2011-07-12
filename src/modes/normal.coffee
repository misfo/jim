define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([iaoOIAC])|         # insert mode transition
    ([vV])|              # visual mode transition
    (D)|                 # delete to end of line command
    (?:
      ([cdy])?           # operators
      ([1-9]\d*)?        # count (multiplier, line number, ...)
      (?:
        (#{motions.regex.source})|
        ([[pPxXu])       # multipliable commands
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

    [fullMatch, @insertTransition, visualTransition, deleteCommand, @operator, countMatch,
      motion, multipliableCommand] = match
    count = parseInt(countMatch) or null

    continueBuffering = false

    if @insertTransition
      switch @insertTransition
        when 'a' @adaptor.moveRight true
        when 'A' @adaptor.moveToLineEnd()
        when 'C' motions['\$'].change()
        when 'o', 'O'
          row = @adaptor.row() + (if @insertTransition is 'o' then 1 else 0)
          @adaptor.insertNewLine row
          @adaptor.moveTo row, 0
        when 'I' @adaptor.navigateLineStart()
      @setMode 'insert'
    else if visualTransition
      if visualTransition is 'V'
        @adaptor.selectLine()
        @setMode 'visual:linewise'
      else
        @adaptor.setSelectionAnchor()
        @setMode 'visual:characterwise'
    else if deleteCommand
      motions['\$'].delete()
    else if motion
      motionObj = motions[motion]
      switch @operator
        when 'c' then motionObj.change this, count
        when 'd' then motionObj.delete this, count
        when 'y' then motionObj.yank   this, count
        else          motionObj.move   this, count
    else if multipliableCommand
      switch multipliableCommand
        when "p", "P"
          text = new Array((count or 1) + 1).join @registers['"']
          after = multipliableCommand is "p"
          @adaptor.insert text, after
        when "x", "X"
          deleteMotion = if multipliableCommand is 'X' then 'h' else 'l'
          motions[deleteMotion].delete this, count
        when "u"
          timesLeft = count ? 1
          @adaptor.undo() while timesLeft--
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
