define (require, exports, module) ->
  util = require 'jim/util'

  ## these return a new regex each time so that we always get a fresh lastIndex
  # a string of non-whitespace characters
  WORDRegex = -> /\S+/g 
  # a string of word characters (i.e. [A-Za-z0-9_]) OR a string of non-whitespace non-word characters (i.e. special chars)
  wordRegex = -> /(\w+)|([^\w\s]+)/g

  # used to find the last instance of the above regexes (there may be a better way of doing this...)
  lastWORDRegex = ///#{WORDRegex().source}\s*$///
  lastWordRegex = ///(#{wordRegex().source})\s*$///

  moveWordEnd = (regex) ->
    line = @adaptor.lineText()
    [row, column] = @adaptor.position()
    rightOfCursor = line.substring column

    if column >= line.length - 1
      loop
        line = @adaptor.lineText ++row
        firstMatchOnSubsequentLine = regex.exec line
        if firstMatchOnSubsequentLine
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1
          break
        else if row is @adaptor.lastRow()
          # there are no more non-blank characters, don't move the cursor
          return
    else
      thisMatch = regex.exec rightOfCursor
      if thisMatch.index > 1 or thisMatch[0].length > 1
        # go to the end of the WORD we're on top of
        # or the next WORD if we're in whitespace
        column += thisMatch[0].length + thisMatch.index - 1
      else
        # go to the end of the next WORD
        nextMatch = regex.exec rightOfCursor
        column += nextMatch.index + nextMatch[0].length - 1

    @adaptor.moveTo row, column

  moveNextWord = (regex) ->
    line = @adaptor.lineText()
    [row, column] = @adaptor.position()
    rightOfCursor = line.substring column

    thisMatch = regex.exec rightOfCursor
    if thisMatch?.index > 0
      # We've found the next beginning of the next match and it's not already
      # under the cursor. Go to it
      column += thisMatch.index
    else if not thisMatch or not nextMatch = regex.exec rightOfCursor
      # the next match isn't on this line, find it on the next
      line = @adaptor.lineText ++row
      nextLineMatch = regex.exec line
      column = nextLineMatch?.index or 0
    else
      # we're on top of part of a WORD, go to the next one
      column += nextMatch.index

    @adaptor.moveTo row, column

  moveBackWord = (regex) ->
    line = @adaptor.lineText()
    [row, column] = @adaptor.position()
    leftOfCursor = line.substring 0, column

    match = regex.exec leftOfCursor
    if match
      column = match.index
    else
      # there are no matches left of the cursor
      # go to the last word on the previous line
      loop
        # Vim skips lines that are only whitespace
        # (but not completely empty lines)
        line = @adaptor.lineText --row
        break unless /^\s+$/.test line
      match = regex.exec line
      column = match?.index or 0

    @adaptor.moveTo row, column

  nextColumnWithChar = (char, count) ->
    timesLeft = count ? 1
    [row, column] = @adaptor.position()
    rightOfCursor = @adaptor.lineText().substring column + 1
    columnsRight = 0
    while timesLeft--
      columnsRight = rightOfCursor.indexOf(char, columnsRight) + 1
    [row, column + columnsRight] if columnsRight

  lastColumnWithChar = (char, count) ->
    timesLeft = count ? 1
    [row, column] = @adaptor.position()
    leftOfCursor = @adaptor.lineText().substring 0, column
    targetColumn = column
    while timesLeft--
      targetColumn = leftOfCursor.lastIndexOf(char, targetColumn - 1)
    [row, targetColumn] if 0 <= targetColumn < column

  class Motion
    constructor: (props) ->
      this[key] = value for own key, value of props
      @linewise  ?= no
      @exclusive ?= no

    move: (jim, count, options, operation) ->
      timesLeft = count ? 1
      @moveOnce.call jim, options, operation while timesLeft--
    change: (jim, count, options) ->
      @delete jim, count, options, 'change'
      jim.setMode 'insert'
    delete: (jim, count, options, operation) ->
      jim.adaptor.setSelectionAnchor()
      @move jim, count, options, operation ? 'delete'
      adjustSelection.call this, jim
      jim.adaptor.moveToEndOfPreviousLine() if operation is 'change' and @linewise
      jim.deleteSelection @exclusive, @linewise
    yank: (jim, count, options) ->
      jim.adaptor.setSelectionAnchor()
      @move jim, count, options, 'yank'
      adjustSelection.call this, jim
      jim.yankSelection @exclusive, @linewise

    adjustSelection = (jim) ->
      if @linewise
        jim.adaptor.makeLinewise()
      else if not @exclusive
        jim.adaptor.includeCursorInSelection()

  simpleMotions =
    h: new Motion
      exclusive: yes
      moveOnce: -> @adaptor.moveLeft()
    j: new Motion
      linewise: yes
      moveOnce: -> @adaptor.moveDown()
    k: new Motion
      linewise: yes
      moveOnce: -> @adaptor.moveUp()
    l: new Motion
      exclusive: yes
      moveOnce: (options, operation) -> @adaptor.moveRight operation?

    W: new Motion
      exclusive: yes
      moveOnce: -> moveNextWord.call this, WORDRegex()
      change: (jim, count) -> simpleMotions['E'].change jim, count
    E: new Motion
      moveOnce: -> moveWordEnd.call this, WORDRegex()
    B: new Motion
      exclusive: yes
      moveOnce: -> moveBackWord.call this, lastWORDRegex 
    w: new Motion
      exclusive: yes
      moveOnce: -> moveNextWord.call this, wordRegex()
      change: (jim, count) -> simpleMotions['e'].change jim, count
    e: new Motion
      moveOnce: -> moveWordEnd.call this, wordRegex()
    b: new Motion
      exclusive: yes
      moveOnce: -> moveBackWord.call this, lastWordRegex
      
    0: new Motion
      exclusive: yes
      move: (jim) -> jim.adaptor.moveTo jim.adaptor.row(), 0

    '^': new Motion
      move: (jim) -> jim.moveToFirstNonBlank()
    $: new Motion
      move: (jim, count) ->
        additionalLines = (count ? 1) - 1
        simpleMotions['j'].move jim, additionalLines if additionalLines
        jim.adaptor.moveToLineEnd()

    G: new Motion
      linewise: yes
      move: (jim, count) ->
        lineNumber = count ? jim.adaptor.lastRow() + 1
        lineText = jim.adaptor.lineText lineNumber-1
        column = /\S/.exec(lineText)?.index or 0
        jim.adaptor.moveTo lineNumber-1, column

    gg: new Motion
      linewise: yes
      move: (jim, count) -> simpleMotions['G'].move jim, count ? 1

    H: new Motion
      linewise: yes
      move: (jim, count) ->
        line = jim.adaptor.firstFullyVisibleRow() + (count ? 1)
        simpleMotions['G'].move jim, line

    M: new Motion
      linewise: yes
      move: (jim, count) ->
        topRow = jim.adaptor.firstFullyVisibleRow()
        lines = jim.adaptor.lastFullyVisibleRow() - topRow
        linesFromTop = lines / 2
        simpleMotions['G'].move jim, topRow + 1 + linesFromTop

    L: new Motion
      linewise: yes
      move: (jim, count) ->
        line = jim.adaptor.lastFullyVisibleRow() + 2 - (count ? 1)
        simpleMotions['G'].move jim, line

    '/': new Motion
      exclusive: yes
      move: (jim, count) ->
        timesLeft = count ? 1
        pattern = prompt("Find:")
        jim.search = {pattern, backwards: no}
        jim.adaptor.findNext pattern while timesLeft--

    '?': new Motion
      exclusive: yes
      move: (jim, count) ->
        timesLeft = count ? 1
        pattern = prompt("Find:")
        jim.search = {pattern, backwards: yes}
        jim.adaptor.findPrevious pattern while timesLeft--

    n: new Motion
      exclusive: yes
      move: (jim, count) ->
        return if not jim.search
        timesLeft = count ? 1
        func = if jim.search.backwards then 'findPrevious' else 'findNext'
        jim.adaptor[func] jim.search.pattern while timesLeft--

    N: new Motion
      exclusive: yes
      move: (jim, count) ->
        return if not jim.search
        timesLeft = count ? 1
        func = if jim.search.backwards then 'findNext' else 'findPrevious'
        jim.adaptor[func] jim.search.pattern while timesLeft--

  # these motions have their own capture groups in the regex and need to be
  # handled separately
  toCharMotions =
    f: new Motion
      move: (jim, count, options) ->
        position = nextColumnWithChar.call jim, options.char, count
        jim.adaptor.moveTo position... if position
    F: new Motion
      move: (jim, count, options) ->
        position = lastColumnWithChar.call jim, options.char, count
        jim.adaptor.moveTo position... if position
    t: new Motion
      move: (jim, count, options) ->
        position = nextColumnWithChar.call jim, options.char, count
        jim.adaptor.moveTo position[0], position[1] - 1 if position
    T: new Motion
      move: (jim, count, options) ->
        position = lastColumnWithChar.call jim, options.char, count
        jim.adaptor.moveTo position[0], position[1] + 1 if position

  regex: ///
      ([1-9]\d*)?    # count (multiplier, line number, ...)
      (?:
        (
        #{util.propertyNameRegex(simpleMotions).source}
        )|
        ([fFtT])(.)?   # navigate to char
      )
    ///

  move: (jim, keys, operatorCount) -> @execute(jim, null, keys, operatorCount)

  execute: (jim, operator, matchOrKeys, operatorCount) ->
    if typeof matchOrKeys is 'string'
      simpleMatch = matchOrKeys
    else
      [fullMatch, count, simpleMatch, motionToChar, char] = matchOrKeys

    if simpleMatch
      motion = simpleMotions[simpleMatch]
    else if char
      motion = toCharMotions[motionToChar]
      options = {char}

    if motion
      count = (parseInt(count) or 1) * (operatorCount or 1) if count or operatorCount
      switch operator
        when 'c' then motion.change jim, count, options
        when 'd' then motion.delete jim, count, options
        when 'y' then motion.yank   jim, count, options
        else          motion.move   jim, count, options

      false
    else
      !!fullMatch
