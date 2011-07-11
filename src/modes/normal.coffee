define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([iaIAC])|           # insert mode transition
    ([vV])|              # visual mode transition
    (D)|                 # delete to end of line command
    (?:
      ([cdy])?           # operators
      (\d*)              # number prefix (multiplier, line number, ...)
      (?:
        (#{motions.regex.source})|
        ([[pPxXu])       # multipliable commands
      )?
    )
    $
  ///

  repeatText = (number, string) ->
    number = 1 if not number? or number is ""
    new Array(number + 1).join string

  execute: ->
    match = @buffer.match regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{@buffer}"
      @onEscape()
      return

    [fullMatch, @insertTransition, visualTransition, deleteCommand, @operator, numberPrefix,
      motion, multipliableCommand] = match
    numberPrefix = parseInt(numberPrefix) if numberPrefix

    continueBuffering = false

    if @insertTransition
      switch @insertTransition
        when 'a'
          @adaptor.moveRight true
        when "A"
          @adaptor.navigateLineEnd()
        when "C"
          @adaptor.selectToLineEnd()
          @deleteSelection()
        when "I"
          @adaptor.navigateLineStart()
      @setMode 'insert'
    else if visualTransition
      if visualTransition is 'V'
        @adaptor.selectLine()
        @setMode 'visual:linewise'
      else
        @adaptor.setSelectionAnchor()
        @setMode 'visual:characterwise'
    else if deleteCommand
      @adaptor.selectToLineEnd()
      @deleteSelection()
    else if motion
      motionObj = motions[motion]
      switch @operator
        when 'c' then motionObj.change this, numberPrefix
        when 'd' then motionObj.delete this, numberPrefix
        when 'y' then motionObj.yank   this, numberPrefix
        else          motionObj.move   this, numberPrefix
    else if multipliableCommand
      switch multipliableCommand
        when "p", "P"
          text = repeatText numberPrefix, @registers['"']
          after = multipliableCommand is "p"
          @adaptor.insert text, after
        when "x", "X"
          deleteMotion = if multipliableCommand is 'X' then 'h' else 'l'
          motions[deleteMotion].delete this, numberPrefix
        when "u"
          @times numberPrefix, -> @adaptor.undo()
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
