# Motions are exactly that: motions.  They move the cursor but don't change the
# document at all.  They can be used in normal or visual mode and can follow an
# operator in normal mode to operate on the text that they move over.

{Command, repeatCountTimes} = require './helpers'


# The default key mappings are specified alongside the definitions of each
# motion.  Accumulate the mappings so they can be exported.
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


# Define an unmapped `Motion` that will be used for double operators (e.g. `cc`,
# `2yy`, `3d4d`).
class LinewiseCommandMotion extends Motion
  linewise: yes
  exec: (jim) ->
    if additionalLines = @count - 1
      new MoveDown(additionalLines).exec jim


# Basic directional motions
# -------------------------
map 'h', class MoveLeft extends Motion
  exclusive: yes
  exec: repeatCountTimes (jim) ->
    if @prevLine and jim.adaptor.column() is 0
      jim.adaptor.moveToEndOfPreviousLine()
    else jim.adaptor.moveLeft()
map 'j', class MoveDown extends Motion
  linewise: yes
  exec: repeatCountTimes (jim) -> jim.adaptor.moveDown()
map 'k', class MoveUp extends Motion
  linewise: yes
  exec: repeatCountTimes (jim) -> jim.adaptor.moveUp()
map 'l', class MoveRight extends Motion
  exclusive: yes
  exec: repeatCountTimes (jim) ->
    linelen = jim.adaptor.lineText().length - 1
    column = jim.adaptor.column()
    if @nextLine and column >= linelen
      jim.adaptor.moveTo jim.adaptor.row() + 1, 0
    else jim.adaptor.moveRight @operation?

map 'left', MoveLeft
map 'down', MoveDown
map 'up', MoveUp
map 'right', MoveRight

map 'space', class extends MoveRight
  nextLine: yes

# Word motions
# ------------

# Return a new regex with a fresh lastIndex each time for use in word motions.
# There are two different kinds of words:
#
# * A **WORD** is a string of non-whitespace characters.
# * A **word** is a string of regex word characters (i.e. `[A-Za-z0-9_]`) *or* a
#   string of non-whitespace non-word characters (i.e. special chars)
WORDRegex = -> /\S+/g 
wordRegex = -> /(\w+)|([^\w\s]+)/g


# Move to the next end of a **word**.
map 'e', class MoveToWordEnd extends Motion
  exec: repeatCountTimes (jim) ->
    regex = if @bigWord then WORDRegex() else wordRegex()
    line = jim.adaptor.lineText()
    [row, column] = jim.adaptor.position()
    rightOfCursor = line.substring column

    matchOnLine = regex.exec rightOfCursor

    # If we're on top of the last char of a word we want to match the next one.
    if matchOnLine?[0].length <= 1
      matchOnLine = regex.exec rightOfCursor

    # If there's a match on the current line, go to the end of the word that's
    # been matched.
    if matchOnLine
      column += matchOnLine[0].length + matchOnLine.index - 1

    # If there's no match on the current line go end of the next word, whatever
    # line that may be on.  If there are no more non-blank characters, don't
    # move the cursor.
    else
      loop
        line = jim.adaptor.lineText ++row
        firstMatchOnSubsequentLine = regex.exec line
        if firstMatchOnSubsequentLine
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1
          break
        else if row is jim.adaptor.lastRow()
          return

    # Move to the `row` and `column` that have been determined.
    jim.adaptor.moveTo row, column

# Move to the next end of a **WORD**.
map 'E', class MoveToBigWordEnd extends MoveToWordEnd
  bigWord: yes


# Move to the next beginning of a **word**.
map 'w', class MoveToNextWord extends Motion
  exclusive: yes
  exec: (jim) ->
    timesLeft = @count
    while timesLeft--
      regex = if @bigWord then WORDRegex() else wordRegex()
      line = jim.adaptor.lineText()
      [row, column] = jim.adaptor.position()
      rightOfCursor = line.substring column

      match = regex.exec rightOfCursor

      # If we're on top of part of a word, match the next one.
      match = regex.exec rightOfCursor if match?.index is 0

      # If the match isn't on this line, find it on the next.
      if not match

        # If the user typed `dw` on the last word of a line, for instance, just
        # delete the rest of the word instead of deleting to the start of the
        # word on the next line.
        if timesLeft is 0 and @operation
          column = line.length

        else
          line = jim.adaptor.lineText ++row
          nextLineMatch = regex.exec line
          column = nextLineMatch?.index or 0

      # `cw` actually behaves like `ce` instead of `dwi`. So if this motion is
      # part of a `Change` operation, ensure that the last time the loop is
      # executed we execute a `MoveToWordEnd` instead.
      else if timesLeft is 0 and @operation?.switchToMode is 'insert'
        lastMotion = new MoveToWordEnd()
        lastMotion.bigWord = @bigWord
        lastMotion.exec jim
        @exclusive = no
        return

      # If the match is on this line, go to the column.
      else
        column += match.index

      # Move to the `row` and `column` that have been determined.
      jim.adaptor.moveTo row, column

# Move to the next beginning of a **WORD**.
map 'W', class MoveToNextBigWord extends MoveToNextWord
  bigWord: yes


# Build regexes to find the last instance of a word.
lastWORDRegex = ///#{WORDRegex().source}\s*$///
lastWordRegex = ///(#{wordRegex().source})\s*$///

# Move to the last beginning of a **word**.
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

    # If there are no matches left of the cursor, go to the last word on the
    # previous line.  Vim skips lines that are have only whitespace on them, but
    # not completely empty lines.
    else
      row--
      row-- while /^\s+$/.test(line = jim.adaptor.lineText row)
      match = regex.exec line
      column = match?.index or 0

    # Move to the `row` and `column` that have been determined.
    jim.adaptor.moveTo row, column

# Move to the last beginning of a **WORD**.
map 'B', class MoveBackBigWord extends MoveBackWord
  bigWord: yes
  

# Other left/right motions
# ------------------------

# Move to the first column on the line.
map '0', class MoveToBeginningOfLine extends Motion
  exclusive: yes
  exec: (jim) -> jim.adaptor.moveTo jim.adaptor.row(), 0

# Move to the first non-blank character on the line.
map '^', class MoveToFirstNonBlank extends Motion
  exec: (jim) ->
    row = jim.adaptor.row()
    line = jim.adaptor.lineText row
    column = /\S/.exec(line)?.index or 0
    jim.adaptor.moveTo row, column

# Move to the last column on the line.
map '$', class MoveToEndOfLine extends Motion
  exec: (jim) ->
    additionalLines = @count - 1
    new MoveDown(additionalLines).exec jim if additionalLines
    jim.adaptor.moveToLineEnd()


# Jump motions
# ------------

# Go to `{count}` line number or the first line.
map 'gg', class GoToLine extends Motion
  linewise: yes
  exec: (jim) ->
    rowNumber = @count - 1
    lineText = jim.adaptor.lineText rowNumber
    jim.adaptor.moveTo rowNumber, 0
    new MoveToFirstNonBlank().exec jim

# Go to `{count}` line number or the last line.
map 'G', class GoToLineOrEnd extends GoToLine
  constructor: (@count) ->
  exec: (jim) ->
    @count or= jim.adaptor.lastRow() + 1
    super

# Go to the first line that's visible in the viewport.
map 'H', class GoToFirstVisibleLine extends Motion
  linewise: yes
  exec: (jim) ->
    line = jim.adaptor.firstFullyVisibleRow() + @count
    new GoToLineOrEnd(line).exec jim

# Go to the middle line of the lines that exist and are visible in the viewport.
map 'M', class GoToMiddleLine extends Motion
  linewise: yes
  exec: (jim) ->
    topRow = jim.adaptor.firstFullyVisibleRow()
    lines = jim.adaptor.lastFullyVisibleRow() - topRow
    linesFromTop = Math.floor(lines / 2)
    new GoToLineOrEnd(topRow + 1 + linesFromTop).exec jim

# Go to the last line of the lines that exist and are visible in the viewport.
map 'L', class GoToLastVisibleLine extends Motion
  linewise: yes
  exec: (jim) ->
    line = jim.adaptor.lastFullyVisibleRow() + 2 - @count
    new GoToLineOrEnd(line).exec jim


# Search motions
# --------------

# Prompt the user for a search term and search forward for it.
map '/', class Search extends Motion
  # Given that `jim.search` has already been set, search for the `{count}`'th
  # occurrence of the search.  Reverse `jim.search`'s direction if `reverse` is
  # true.
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

# Prompt the user for a search term and search backwards for it.
map '?', class SearchBackwards extends Search
  backwards: yes

# Search fowards for the next occurrence of the nearest word.
map '*', class NearestWordSearch extends Search
  getSearch: (jim) ->
    [searchString, charsAhead] = nearestWord jim

    # If we're searching for a word that's ahead of the cursor, ensure that the
    # search starts beyond it.
    new MoveRight(charsAhead).exec jim if charsAhead

    # Match only whole words unless searching for special chars.
    wholeWord = /^\w/.test searchString

    {searchString, wholeWord, @backwards}

  # The word used for `*` and `#` is the first of the following that matches on
  # the line:
  #
  # 1. The `\w+` word under or after the cursor
  # 2. The first string of non-blanks (i.e. `\S+`) under or after the cursor
  nearestWord = (jim) ->
    line = jim.adaptor.lineText()
    column = jim.adaptor.column()
    leftOfCursor = line.substring 0, column
    rightOfCursor = line.substring column
    charsAhead = null

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

# Search backwards for the next occurrence of the nearest word.
map '#', class NearestWordSearchBackwards extends NearestWordSearch
  backwards: yes
  

# Repeat the last search.
map 'n', class SearchAgain extends Motion
  exclusive: yes
  exec: (jim) -> Search.runSearch jim, @count

# Repeat the last search, reversing the direction.
map 'N', class SearchAgainReverse extends Motion
  exclusive: yes
  exec: (jim) -> Search.runSearch jim, @count, true


# Move-to-character motions
# -------------------------
#
# These motions are expected to get a be followed by a character keypress.  When
# they are executed this character is stored as the command's `@followedBy`.

# Go to the next `@followedBy` char on the line.
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

# Go to the char before the next `@followedBy` char on the line.
map 't', class GoUpToNextChar extends GoToNextChar
  beforeChar: yes


# Go to the previous `@followedBy` char on the line.
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

# Go to the char after the previous `@followedBy` char on the line.
map 'T', class GoUpToPreviousChar extends GoToPreviousChar
  beforeChar: yes


# Exports
# -------
module.exports = {
  GoToLine, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank, LinewiseCommandMotion,
  MoveToNextBigWord, MoveToNextWord, MoveToBigWordEnd, MoveToWordEnd, defaultMappings
}
