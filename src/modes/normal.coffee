define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([iIAC])|            # insert mode transition
    ([vV])|              # visual mode transition
    (D)|                 # delete to end of line command
    (?:
      ([cdy])?           # operators
      (\d*)              # number prefix (multiplier, line number, ...)
      (?:
        (#{motions.regex.source})|
        ([[pPxXu])|      # multipliable commands
        (G)              # go!
      )?
    )
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

    [fullMatch, insertTransition, visualTransition, deleteCommand, @operator, numberPrefix,
      motion, multipliableCommand, go] = match
    numberPrefix = parseInt(numberPrefix) if numberPrefix

    continueBuffering = false

    if insertTransition
      switch insertTransition
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
      @adaptor.setSelectionAnchor() if @operator

      {exclusive, linewise} = motions.execute.call this, numberPrefix, motion

      switch @operator
        when 'c', 'd'
          @deleteSelection exclusive
          @setMode 'insert' if @operator is 'c'
        when 'y' then @yankSelection exclusive
    else if multipliableCommand
      switch multipliableCommand
        when "p", "P"
          text = repeatText numberPrefix, @registers['"']
          after = multipliableCommand is "p"
          @adaptor.insert text, after
        when "x", "X"
          #TODO delegate to dh and dl?
          @adaptor.setSelectionAnchor()
          if multipliableCommand is "x"
            @times numberPrefix - 1, -> @adaptor.moveRight() unless numberPrefix is ""
          else
            @times numberPrefix, -> @adaptor.moveLeft()

          if @adaptor.emptySelection()
            @adaptor.clearSelection()
          else
            @deleteSelection()
        when "u"
          @times numberPrefix, -> @adaptor.undo()
    else if go
      if numberPrefix
        @adaptor.goToLine numberPrefix
      else
        @adaptor.navigateFileEnd()
    else
      continueBuffering = true

    @buffer = '' unless continueBuffering
