define (require, exports, module) ->
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

  class Motion
    constructor: (props) ->
      this[key] = value for own key, value of props
      @linewise  ?= false
      @exclusive ?= false

    move: (jim, count) ->
      timesLeft = count ? 1
      @moveOnce.call jim while timesLeft--
    change: (jim, count) ->
      jim.adaptor.setSelectionAnchor()
      @move jim, count
      adjustSelection.call this, jim
      jim.adaptor.moveToEndOfPreviousLine() if @linewise
      jim.deleteSelection @exclusive, @linewise
      jim.setMode 'insert'
    delete: (jim, count) ->
      jim.adaptor.setSelectionAnchor()
      @move jim, count
      adjustSelection.call this, jim
      jim.deleteSelection @exclusive, @linewise
    yank: (jim, count) ->
      jim.adaptor.setSelectionAnchor()
      @move jim, count
      adjustSelection.call this, jim
      jim.yankSelection @exclusive, @linewise

    adjustSelection = (jim) ->
      if @linewise
        jim.adaptor.makeLinewise()
      else if not @exclusive
        jim.adaptor.includeCursorInSelection()

  motions =
    h: new Motion
      exclusive: true
      moveOnce: -> @adaptor.moveLeft()
    j: new Motion
      linewise: true
      moveOnce: -> @adaptor.moveDown()
    k: new Motion
      linewise: true
      moveOnce: -> @adaptor.moveUp()
    l: new Motion
      exclusive: true
      moveOnce: -> @adaptor.moveRight()

    W: new Motion
      exclusive: true
      moveOnce: -> moveNextWord.call this, WORDRegex()
      change: (jim, count) -> motions['E'].change jim, count
    E: new Motion
      moveOnce: -> moveWordEnd.call this, WORDRegex()
    B: new Motion
      exclusive: true
      moveOnce: -> moveBackWord.call this, lastWORDRegex 
    w: new Motion
      exclusive: true
      moveOnce: -> moveNextWord.call this, wordRegex()
      change: (jim, count) -> motions['e'].change jim, count
    e: new Motion
      moveOnce: -> moveWordEnd.call this, wordRegex()
    b: new Motion
      exclusive: true
      moveOnce: -> moveBackWord.call this, lastWordRegex
      
    0: new Motion
      exclusive: true
      move: (jim) -> jim.adaptor.moveTo jim.adaptor.row(), 0

    '$': new Motion
      move: (jim) -> jim.adaptor.moveToLineEnd()

    G: new Motion
      linewise: true
      move: (jim, count) ->
        lineNumber = count ? jim.adaptor.lastRow()
        lineText = jim.adaptor.lineText lineNumber-1
        column = /\S/.exec(lineText)?.index or 0
        jim.adaptor.moveTo lineNumber-1, column

  motions.regex = ///[#{(k for own k, v of motions).join ''}]///

  motions
