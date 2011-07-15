define (require, exports, module) ->
  motions = require 'jim/motions'

  regex = ///
    ^
    ([vV])|              # visual mode switch
    (?:
      ([1-9]\d*)?        # count (multiplier, line number, ...)
      (?:
        ([iaoOIAC])|     # insert mode switch
        ([DpPsxXu])|     # commands
        ([cdy]{2})|      # linewise commands
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

    [fullMatch, visualSwitch, countMatch, insertSwitch, command,
      linewiseCommand, operator, motionCountMatch, motion] = match
    count       = parseInt(countMatch) or null
    motionCount = parseInt(motionCountMatch) or null

    continueBuffering = false

    if insertSwitch
      switch insertSwitch
        when 'a' then @adaptor.moveRight true
        when 'A'
          motions['$'].move this
          @adaptor.moveRight true
        when 'C' then motions['$'].change this, count
        when 'o', 'O'
          row = @adaptor.row() + (if insertSwitch is 'o' then 1 else 0)
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
    else if motion and motionObj = motions[motion]
      motionCount = (count or 1) * (motionCount or 1) if count or motionCount
      switch operator
        when 'c' then motionObj.change this, motionCount
        when 'd' then motionObj.delete this, motionCount
        when 'y' then motionObj.yank   this, motionCount
        else          motionObj.move   this, motionCount
    else if command
      switch command
        when 'D'
          motions['$'].delete this, count
        when 'p', 'P'
          if registerValue = @registers['"']
            text = new Array((count or 1) + 1).join registerValue
            after = command is "p"
            linewiseRegister = /\n$/.test registerValue
            if linewiseRegister
              row = @adaptor.row() + (if after then 1 else 0)
              lastRow = @adaptor.lastRow()
              if row > lastRow
                # we have to move the line ending to the begining of the string
                [wholeString, beforeLineEnding, lineEnding] = /^([\s\S]*)(\r?\n)$/.exec text
                text = lineEnding + beforeLineEnding

                column = @adaptor.lineText(lastRow).length - 1
                @adaptor.moveTo row, column
              else
                @adaptor.moveTo row, 0
              @adaptor.insert text
              @adaptor.moveTo row, 0
            else
              @adaptor.insert text, after
        when 's' then motions['l'].change this, count
        when "x", "X"
          deleteMotion = if command is 'X' then 'h' else 'l'
          motions[deleteMotion].delete this, count
        when "u"
          timesLeft = count ? 1
          @adaptor.undo() while timesLeft--
    else if linewiseCommand
      startingPosition = @adaptor.position()
      @adaptor.setSelectionAnchor()
      additionalLines = (count or 1) - 1
      motions['j'].move this, additionalLines if additionalLines
      @adaptor.makeLinewise()
      switch linewiseCommand
        when 'cc'
          @adaptor.moveToEndOfPreviousLine()
          @deleteSelection()
          @setMode 'insert'
        when 'dd'
          @deleteSelection()
          @moveToFirstNonBlank()
        when 'yy'
          @yankSelection()
          @adaptor.moveTo startingPosition...
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
