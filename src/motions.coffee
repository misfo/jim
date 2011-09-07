# Motions are exactly that: motions.  They move the cursor but don't change the
# document at all.  They can be used in normal or visual mode and can follow an
# operator in normal mode to operate on the text that they move over.

{Command, repeatCountTimes} = require './helpers'

## these return a new regex each time so that we always get a fresh lastIndex
# a string of non-whitespace characters
WORDRegex = -> /\S+/g 
# a string of word characters (i.e. [A-Za-z0-9_]) OR a string of non-whitespace non-word characters (i.e. special chars)
wordRegex = -> /(\w+)|([^\w\s]+)/g

# used to find the last instance of the above regexes (there may be a better way of doing this...)
lastWORDRegex = ///#{WORDRegex().source}\s*$///
lastWordRegex = ///(#{wordRegex().source})\s*$///

# accumulate the default mappings
defaultMappings = {}
map = (keys, motionClass) -> defaultMappings[keys] = motionClass

# base class for all motions
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

# move to the end of the current word or the end of the next word if on the end of a
# word
map 'e', class MoveToWordEnd extends Motion
  exec: repeatCountTimes (jim) ->
    regex = if @bigWord then WORDRegex() else wordRegex()
    line = jim.adaptor.lineText()
    [row, column] = jim.adaptor.position()
    rightOfCursor = line.substring column

    matchOnLine = regex.exec rightOfCursor
    if matchOnLine?[0].length <= 1
      # if we're on top of the last char of a word we want to go to the next one
      matchOnLine = regex.exec rightOfCursor

    if matchOnLine
      # go to the end of the word that's been matched
      column += matchOnLine[0].length + matchOnLine.index - 1
    else
      # if there's no match on the current line go end of the next word, whatever line
      # that may be
      loop
        line = jim.adaptor.lineText ++row
        firstMatchOnSubsequentLine = regex.exec line
        if firstMatchOnSubsequentLine
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1
          break
        else if row is jim.adaptor.lastRow()
          # there are no more non-blank characters, don't move the cursor
          return

    jim.adaptor.moveTo row, column

map 'E', class MoveToBigWordEnd extends MoveToWordEnd
  bigWord: yes


# move to the beginning of the next word
map 'w', class MoveToNextWord extends Motion
  exclusive: yes
  exec: (jim) ->
    timesLeft = @count
    while timesLeft--
      regex = if @bigWord then WORDRegex() else wordRegex()
      line = jim.adaptor.lineText()
      [row, column] = jim.adaptor.position()
      rightOfCursor = line.substring column

      thisMatch = regex.exec rightOfCursor
      if not thisMatch or not nextMatch = regex.exec rightOfCursor
        # the next match isn't on this line, find it on the next

        if timesLeft is 0 and @operation
          # one exception: e.g. `dw` on the last word of a line just deletes the rest
          # of the word (instead of deleting to the start of the word on the next line)
          column = line.length
        else
          line = jim.adaptor.lineText ++row
          nextLineMatch = regex.exec line
          column = nextLineMatch?.index or 0
      else if timesLeft is 0 and @operation?.switchToMode is 'insert'
        # this motion is part of a Change operation, this accounts for the exception
        # that `cw` behaves like `ce` instead of `dwi`
        lastMotion = new MoveToWordEnd()
        lastMotion.bigWord = @bigWord
        lastMotion.exec jim
        @exclusive = no
        return
      else if thisMatch?.index > 0
        # We've found the beginning of the next match and it's not already
        # under the cursor. Go to it
        column += thisMatch.index
      else
        # we're on top of part of a WORD, go to the next one
        column += nextMatch.index

      jim.adaptor.moveTo row, column

map 'W', class MoveToNextBigWord extends MoveToNextWord
  bigWord: yes


# move to the last beginning of a word
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
  
# move to the first column on the line
map '0', class MoveToBeginningOfLine extends Motion
  exclusive: yes
  exec: (jim) -> jim.adaptor.moveTo jim.adaptor.row(), 0

# move to the first non-blank character on the line
map '^', class MoveToFirstNonBlank extends Motion
  exec: (jim) ->
    row = jim.adaptor.row()
    line = jim.adaptor.lineText row
    column = /\S/.exec(line)?.index or 0
    jim.adaptor.moveTo row, column

# move to the last column on the line
map '$', class MoveToEndOfLine extends Motion
  exec: (jim) ->
    additionalLines = @count - 1
    new MoveDown(additionalLines).exec jim if additionalLines
    jim.adaptor.moveToLineEnd()

# go to `{count}` line number or the first line
map 'gg', class GoToLine extends Motion
  linewise: yes
  exec: (jim) ->
    rowNumber = @count - 1
    lineText = jim.adaptor.lineText rowNumber
    jim.adaptor.moveTo rowNumber, 0
    new MoveToFirstNonBlank().exec jim

# go to `{count}` line number or the last line
map 'G', class GoToLineOrEnd extends GoToLine
  constructor: (@count) ->
  exec: (jim) ->
    @count or= jim.adaptor.lastRow() + 1
    super

# go to the first line that's visible in the viewport
map 'H', class GoToFirstVisibleLine extends Motion
  linewise: yes
  exec: (jim) ->
    line = jim.adaptor.firstFullyVisibleRow() + @count
    new GoToLineOrEnd(line).exec jim

# go to the middle line of the lines that exist and are visible in the viewport
map 'M', class GoToMiddleLine extends Motion
  linewise: yes
  exec: (jim) ->
    topRow = jim.adaptor.firstFullyVisibleRow()
    lines = jim.adaptor.lastFullyVisibleRow() - topRow
    linesFromTop = Math.floor(lines / 2)
    new GoToLineOrEnd(topRow + 1 + linesFromTop).exec jim

# go to the last line of the lines that exist and are visible in the viewport
map 'L', class GoToLastVisibleLine extends Motion
  linewise: yes
  exec: (jim) ->
    line = jim.adaptor.lastFullyVisibleRow() + 2 - @count
    new GoToLineOrEnd(line).exec jim


# prompt the user for a search term and search forward for that
map '/', class Search extends Motion
  # Given that `jim.search` has already been set, search for the `{count}`'th
  # occurrence of the search.  Reverse `jim.search`'s direction if `reverse` is true
  @runSearch: (jim, count, reverse) ->
    return if not jim.search
    {backwards, searchString, wholeWord} = jim.search
    backwards = not backwards if reverse
    jim.adaptor.search backwards, searchString, wholeWord while count--

  exclusive: yes
  getSearch: -> {searchString: prompt("Find:"), @backwards}
  exec: (jim) ->
    jim.search = @getSearch jim
    Search.runSearch jim, @count

# prompt the user for a search term and search backwards for that
map '?', class SearchBackwards extends Search
  backwards: yes

# search fowards for the next occurrence of the nearest word
map '*', class NearestWordSearch extends Search
  getSearch: (jim) ->
    [searchString, charsAhead] = nearestWord jim
    if charsAhead
      # if we're searching for a word that's ahead of the cursor, ensure that
      # we the search starts at the word beyond that one
      new MoveRight(charsAhead).exec jim
    # match only whole word's unless searching for special chars
    wholeWord = /^\w/.test searchString
    {searchString, wholeWord, @backwards}

  # the word used for `*` and `#` is the first of the following that matches:
  #     1. the word under or after the cursor (i.e. a `\w+` word)
  #     2. the first non-blank (i.e. `\S+`) under or after the cursor
  nearestWord = (jim) ->
    line = jim.adaptor.lineText()
    column = jim.adaptor.column()
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

# search backwards for the next occurrence of the nearest word
map '#', class NearestWordSearchBackwards extends NearestWordSearch
  backwards: yes
  

# repeat the last search made
map 'n', class SearchAgain extends Motion
  exclusive: yes
  exec: (jim) -> Search.runSearch jim, @count

# repeat the last search made, reversing the direction
map 'N', class SearchAgainReverse extends Motion
  exclusive: yes
  exec: (jim) -> Search.runSearch jim, @count, true

# once followed by `{char}`, go to the next `{char}` on the line
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

# once followed by `{char}`, go to the char before the next `{char}` on the line
map 't', class GoUpToNextChar extends GoToNextChar
  beforeChar: yes


# once followed by `{char}`, go to the previous `{char}` on the line
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

# once followed by `{char}`, go to the char after the previous `{char}` on the line
map 'T', class GoUpToPreviousChar extends GoToPreviousChar
  beforeChar: yes


module.exports = {
  GoToLine, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank, LinewiseCommandMotion,
  MoveToNextBigWord, MoveToNextWord, MoveToBigWordEnd, MoveToWordEnd, defaultMappings
}
