{Command, repeatCountTimes} = require './helpers'

## these return a new regex each time so that we always get a fresh lastIndex
# a string of non-whitespace characters
WORDRegex = -> /\S+/g 
# a string of word characters (i.e. [A-Za-z0-9_]) OR a string of non-whitespace non-word characters (i.e. special chars)
wordRegex = -> /(\w+)|([^\w\s]+)/g

# used to find the last instance of the above regexes (there may be a better way of doing this...)
lastWORDRegex = ///#{WORDRegex().source}\s*$///
lastWordRegex = ///(#{wordRegex().source})\s*$///

defaultMappings = {}
map = (keys, motionClass) -> defaultMappings[keys] = motionClass

wordCursorIsOn = (line, column) ->
  leftOfCursor = line.substring 0, column
  rightOfCursor = line.substring column
  charsAhead = null

  # If the item on the cursor isn't a word it goes to the next word or
  # the next group of special characters if there isn't a word.
  if /\W/.test line[column]
    leftMatch = ['']
    nextWord = /\w+/.exec rightOfCursor
    rightMatch = if not nextWord
      /[^\w\s]+/.exec rightOfCursor
    else
      nextWord
    charsAhead = rightMatch.index
  else
    leftMatch = /\w*$/.exec leftOfCursor
    rightMatch = /^\w*/.exec rightOfCursor

  [leftMatch[0] + rightMatch[0], charsAhead]

class Motion extends Command
  constructor: (@count = 1) ->
  isRepeatable: false
  linewise: no
  exclusive: no

  # motions do the same thing in visual mode
  visualExec: (jim) -> @exec jim

# used for double operators `cc`, `2yy`, `3d4d`
class LinewiseCommandMotion extends Motion
  linewise: yes
  exec: (jim) ->
    if additionalLines = @count - 1
      new MoveDown(additionalLines).exec jim

map 'h', class MoveLeft extends Motion
  exclusive: yes
  exec: repeatCountTimes (jim) -> jim.adaptor.moveLeft()
map 'j', class MoveDown extends Motion
  linewise: yes
  exec: repeatCountTimes (jim) -> jim.adaptor.moveDown()
map 'k', class MoveUp extends Motion
  linewise: yes
  exec: repeatCountTimes (jim) -> jim.adaptor.moveUp()
map 'l', class MoveRight extends Motion
  exclusive: yes
  exec: repeatCountTimes (jim) -> jim.adaptor.moveRight @operation?

map 'e', class MoveToWordEnd extends Motion
  exec: repeatCountTimes (jim) ->
    regex = if @bigWord then WORDRegex() else wordRegex()
    line = jim.adaptor.lineText()
    [row, column] = jim.adaptor.position()
    rightOfCursor = line.substring column

    if column >= line.length - 1
      loop
        line = jim.adaptor.lineText ++row
        firstMatchOnSubsequentLine = regex.exec line
        if firstMatchOnSubsequentLine
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1
          break
        else if row is jim.adaptor.lastRow()
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

    jim.adaptor.moveTo row, column

map 'E', class MoveToBigWordEnd extends MoveToWordEnd
  bigWord: yes


map 'w', class MoveToNextWord extends Motion
  exclusive: yes
  exec: repeatCountTimes (jim) ->
    regex = if @bigWord then WORDRegex() else wordRegex()
    line = jim.adaptor.lineText()
    [row, column] = jim.adaptor.position()
    rightOfCursor = line.substring column

    thisMatch = regex.exec rightOfCursor
    if thisMatch?.index > 0
      # We've found the next beginning of the next match and it's not already
      # under the cursor. Go to it
      column += thisMatch.index
    else if not thisMatch or not nextMatch = regex.exec rightOfCursor
      # the next match isn't on this line, find it on the next
      line = jim.adaptor.lineText ++row
      nextLineMatch = regex.exec line
      column = nextLineMatch?.index or 0
    else
      # we're on top of part of a WORD, go to the next one
      column += nextMatch.index

    jim.adaptor.moveTo row, column

map 'W', class MoveToNextBigWord extends MoveToNextWord
  bigWord: yes


map 'b', class MoveBackWord extends Motion
  exclusive: yes
  exec: repeatCountTimes (jim) ->
    regex = if @bigWord then lastWORDRegex else lastWordRegex
    line = jim.adaptor.lineText()
    [row, column] = jim.adaptor.position()
    leftOfCursor = line.substring 0, column

    match = regex.exec leftOfCursor
    if match
      column = match.index
    else
      # there are no matches left of the cursor
      # go to the last word on the previous line
      row--
      # Vim skips lines that are only whitespace
      # (but not completely empty lines)
      row-- while /^\s+$/.test(line = jim.adaptor.lineText row)
      match = regex.exec line
      column = match?.index or 0

    jim.adaptor.moveTo row, column

map 'B', class MoveBackBigWord extends MoveBackWord
  bigWord: yes
  
map '0', class extends Motion
  exclusive: yes
  exec: (jim) -> jim.adaptor.moveTo jim.adaptor.row(), 0

map '^', class MoveToFirstNonBlank extends Motion
  exec: (jim) ->
    row = jim.adaptor.row()
    line = jim.adaptor.lineText row
    column = /\S/.exec(line)?.index or 0
    jim.adaptor.moveTo row, column

map '$', class MoveToEndOfLine extends Motion
  exec: (jim) ->
    additionalLines = @count - 1
    new MoveDown(additionalLines).exec jim if additionalLines
    jim.adaptor.moveToLineEnd()

map 'gg', class GoToLine extends Motion
  linewise: yes
  exec: (jim) ->
    rowNumber = @count - 1
    lineText = jim.adaptor.lineText rowNumber
    jim.adaptor.moveTo rowNumber, 0
    new MoveToFirstNonBlank().exec jim

map 'G', class GoToLineOrEnd extends GoToLine
  constructor: (@count) ->
  exec: (jim) ->
    @count or= jim.adaptor.lastRow() + 1
    super

map 'H', class extends Motion
  linewise: yes
  exec: (jim) ->
    line = jim.adaptor.firstFullyVisibleRow() + @count
    literalMotions['G'].move jim, line

map 'M', class extends Motion
  linewise: yes
  exec: (jim) ->
    topRow = jim.adaptor.firstFullyVisibleRow()
    lines = jim.adaptor.lastFullyVisibleRow() - topRow
    linesFromTop = lines / 2
    literalMotions['G'].move jim, topRow + 1 + linesFromTop

map 'L', class extends Motion
  linewise: yes
  exec: (jim) ->
    line = jim.adaptor.lastFullyVisibleRow() + 2 - @count
    literalMotions['G'].move jim, line

map '/', class extends Motion
  exclusive: yes
  exec: (jim) ->
    timesLeft = @count
    pattern = prompt("Find:")
    jim.search = {pattern, backwards: no}
    jim.adaptor.findNext pattern while timesLeft--

map '?', class extends Motion
  exclusive: yes
  exec: (jim) ->
    timesLeft = @count
    pattern = prompt("Find:")
    jim.search = {pattern, backwards: yes}
    jim.adaptor.findPrevious pattern while timesLeft--

map '*', class extends Motion
  exclusive: yes
  exec: (jim) ->
    timesLeft = @count
    adaptor = jim.adaptor
    [pattern, charsAhead] = wordCursorIsOn adaptor.lineText(), adaptor.column()
    if charsAhead
      # if we're searching for a word that's ahead of the cursor, ensure that
      # we the search starts at the word beyond that one
      new MoveRight(charsAhead).exec jim
    jim.search = {pattern, backwards: no}
    jim.adaptor.findNext pattern while timesLeft--

map '#', class extends Motion
  exclusive: yes
  exec: (jim) ->
    timesLeft = @count
    adaptor = jim.adaptor
    [pattern, charsAhead] = wordCursorIsOn adaptor.lineText(), adaptor.column()
    jim.search = {pattern, backwards: yes}
    jim.adaptor.findPrevious pattern while timesLeft--

map 'n', class extends Motion
  exclusive: yes
  exec: (jim) ->
    return if not jim.search
    timesLeft = @count
    func = if jim.search.backwards then 'findPrevious' else 'findNext'
    jim.adaptor[func] jim.search.pattern while timesLeft--

map 'N', class extends Motion
  exclusive: yes
  exec: (jim) ->
    return if not jim.search
    timesLeft = @count
    func = if jim.search.backwards then 'findNext' else 'findPrevious'
    jim.adaptor[func] jim.search.pattern while timesLeft--


map 'f', class GoToNextChar extends Motion
  @followedBy: /./
  exec: (jim) ->
    timesLeft = @count ? 1
    [row, column] = jim.adaptor.position()
    rightOfCursor = jim.adaptor.lineText().substring column + 1
    columnsRight = 0
    while timesLeft--
      columnsRight = rightOfCursor.indexOf(@followedBy, columnsRight) + 1
    if columnsRight
      columnsRight-- if @beforeChar
      jim.adaptor.moveTo row, column + columnsRight

map 't', class GoUpToNextChar extends GoToNextChar
  beforeChar: yes


map 'F', class GoToPreviousChar extends Motion
  @followedBy: /./
  exec: (jim) ->
    timesLeft = @count ? 1
    [row, column] = jim.adaptor.position()
    leftOfCursor = jim.adaptor.lineText().substring 0, column
    targetColumn = column
    while timesLeft--
      targetColumn = leftOfCursor.lastIndexOf(@followedBy, targetColumn - 1)
    if 0 <= targetColumn < column
      targetColumn++ if @beforeChar
      jim.adaptor.moveTo row, targetColumn

map 'T', class GoUpToPreviousChar extends GoToPreviousChar
  beforeChar: yes


module.exports = {
  GoToLine, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank, LinewiseCommandMotion,
  MoveToNextBigWord, MoveToNextWord, MoveToBigWordEnd, MoveToWordEnd, defaultMappings
}
