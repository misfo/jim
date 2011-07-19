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

    [fullMatch, countMatch, motionMatch..., operator] = match
    count = parseInt(countMatch) or null

    continueBuffering = false

    if motionMatch[0]
      wasBackwards = @adaptor.isSelectionBackwards()

      motions.move this, motionMatch, count

      if wasBackwards
        @adaptor.adjustAnchor -1 if not @adaptor.isSelectionBackwards()
      else
        @adaptor.adjustAnchor 1 if @adaptor.isSelectionBackwards()
    else if operator
      if @modeName is 'visual:linewise'
        @adaptor.makeLinewise()
      else
        @adaptor.includeCursorInSelection()

      switch operator
        when 'c', 'd'
          @deleteSelection()
          @setMode if operator is 'c' then 'insert' else 'normal'
        when 'y'
          @yankSelection()
          @setMode 'normal'
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
