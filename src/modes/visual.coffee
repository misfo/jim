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
      motions[motion].move this, count
    else if operator
      switch operator
        when 'c', 'd'
          @adaptor.includeCursorInSelection()
          @deleteSelection()
          @setMode if operator is 'c' then 'insert' else 'normal'
        when 'y'
          @adaptor.includeCursorInSelection()
          @yankSelection()
          @setMode 'normal'
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
