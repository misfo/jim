define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([1-9]\d*)?                  # count (multiplier, line number, ...)
    (?:
      (#{motions.regex.source})|
      ([ydc])                    # operators
    )?
    $
  ///

  execute: ->
    match = @buffer.match regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{@buffer}"
      @onEscape()
      return

    [fullMatch, countMatch, motion, operator] = match
    count = parseInt(countMatch) or null

    continueBuffering = false

    if motion
      wasBackwards = @adaptor.isSelectionBackwards()

      motions[motion].move this, count

      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()
    else if operator
      @adaptor.makeLinewise() if @modeName is 'visual:linewise'
      switch operator
        when 'c', 'd'
          @adaptor.includeCursorInSelection() unless @modeName is 'visual:linewise'
          @deleteSelection()
          @setMode if operator is 'c' then 'insert' else 'normal'
        when 'y'
          @adaptor.includeCursorInSelection()
          @yankSelection()
          @setMode 'normal'
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
