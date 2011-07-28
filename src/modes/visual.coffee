define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([1-9]\d*)?                    # count (multiplier, line number, ...)
    (?:
      ([pPJ]|gJ?)|                 # commands
      (?:
        (#{motions.regex.source})|
        ([ydc><])                  # operators
      )
    )?
    $
  ///

  execute: ->
    match = @buffer.match regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{@buffer}"
      @onEscape()
      return

    [fullMatch, countMatch, command, motionMatch..., operator] = match
    count = parseInt(countMatch) or null

    continueBuffering = false

    if motionMatch[0]
      wasBackwards = @adaptor.isSelectionBackwards()

      motions.move this, motionMatch, count

      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()
    else if command
      switch command
        when 'J', 'gJ'
          [rowStart, rowEnd] = @adaptor.selectionRowRange()
          @joinLines rowStart, rowEnd - rowStart + 1, command is 'J'
          @setMode 'normal'
        when 'p', 'P'
          registerValue = @registers['"']
          @adaptor.includeCursorInSelection()
          if registerValue
            textToPaste = new Array((count or 1) + 1).join registerValue
            @deleteSelection()
            @adaptor.insert textToPaste
          else
            @yankSelection()
          @setMode 'normal'
        else
          continueBuffering = true
    else if operator
      if @modeName is 'visual:linewise'
        @adaptor.makeLinewise()
      else
        @adaptor.includeCursorInSelection()

      switch operator
        when 'c'
          @adaptor.moveToEndOfPreviousLine()
          @deleteSelection()
          @setMode 'insert'
        when 'd'
          @deleteSelection()
          @setMode 'normal'
        when 'y'
          @yankSelection()
          @setMode 'normal'
        when '>'
          @indentSelection()
          @setMode 'normal'
        when '<'
          @outdentSelection()
          @setMode 'normal'
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
