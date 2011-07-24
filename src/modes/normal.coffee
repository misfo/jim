define (require, exports, module) ->
  motions = require 'jim/motions'
  util    = require 'jim/util'

  insertInNewLine = (below) ->
    row = @adaptor.row() + (if below then 1 else 0)
    @adaptor.insertNewLine row
    @adaptor.moveTo row, 0
    @setMode 'insert'

  paste = (count, after) ->
    return if not registerValue = @registers['"']

    text = new Array((count or 1) + 1).join registerValue
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

  makeLinewiseSelection = (count) ->
    startingPosition = @adaptor.position()
    @adaptor.setSelectionAnchor()
    additionalLines = (count or 1) - 1
    motions.move this, 'j', additionalLines if additionalLines
    @adaptor.makeLinewise()

  commands =
    #### insert mode switches

    a: ->
      @adaptor.moveRight true
      @setMode 'insert'

    A: ->
      motions.move this, '$'
      @adaptor.moveRight true
      @setMode 'insert'

    C: (count) ->
      motions.execute this, 'c', '$', count
      @setMode 'insert'

    o: -> insertInNewLine.call this, true
    O: -> insertInNewLine.call this, false

    i: -> @setMode 'insert'
    I: ->
      motions.move this, '^'
      @setMode 'insert'


    #### general commands

    J:  (count) -> @joinLines @adaptor.row(), count or 2, true
    gJ: (count) -> @joinLines @adaptor.row(), count or 2, false

    D: (count) ->
      motions.execute this, 'd', '$', count

    p: (count) -> paste.call this, count, true
    P: (count) -> paste.call this, count, false

    s: (count) ->
      motions.execute this, 'c', 'l', count

    u: (count) ->
      timesLeft = count ? 1
      @adaptor.undo() while timesLeft--

    x: (count) -> motions.execute this, 'd', 'l', count
    X: (count) -> motions.execute this, 'd', 'h', count


    #### linewise commands

    cc: (count) ->
      makeLinewiseSelection.call this, count
      @adaptor.moveToEndOfPreviousLine()
      @deleteSelection()
      @setMode 'insert'
    dd: (count) ->
      makeLinewiseSelection.call this, count
      @deleteSelection()
      @moveToFirstNonBlank()
    yy: (count) ->
      startingPosition = @adaptor.position()
      makeLinewiseSelection.call this, count
      @yankSelection()
      @adaptor.moveTo startingPosition...

  regex = ///
    ^
    ([vV])|              # visual mode switch
    (?:
      ([1-9]\d*)?        # count (multiplier, line number, ...)
      (?:
        (#{util.propertyNameRegex(commands).source})|
        (?:r([\s\S])?)|  # replace char command
        (?:
          ([cdy])?       # operators
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

    [fullMatch, visualSwitch, countMatch, commandMatch,
      replacementChar, operator, motionMatch...] = match
    count = parseInt(countMatch) or null

    continueBuffering = false

    if visualSwitch
      @adaptor.setSelectionAnchor()
      if visualSwitch is 'V'
        @setMode 'visual:linewise'
      else
        @setMode 'visual:characterwise'
    else if motionMatch[0]
      continueBuffering = motions.execute this, operator, motionMatch, count
    else if commandMatch and command = commands[commandMatch]
      command.call this, count
    else if replacementChar
      @adaptor.setSelectionAnchor()
      motions.move this, 'l', count or 1
      @adaptor.deleteSelection() # don't yank
      replacementText = if /^\r?\n$/.test replacementChar
        replacementChar
      else
        new Array((count or 1) + 1).join replacementChar
      @adaptor.insert replacementText
      motions.move this, 'h'
    else
      continueBuffering = true

    @clearBuffer() unless continueBuffering
