# All the default commands (other than operations and motions) for normal mode.  All commands
# can be prefixed with a {count} which multiplies their action in some way.
#
# Commands that also work in visual mode define a `::visualExec` here.

{Command, repeatCountTimes} = require './helpers'
{Change, Delete} = require './operators'
{GoToLine, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank} = require './motions'

# The default key mappings are specified alongside the definitions of each command.
# Accumulate the mappings so they can be exported.
defaultMappings = {}
map = (keys, commandClass) -> defaultMappings[keys] = commandClass

# convenience class for commands that switch to another mode
class ModeSwitch extends Command
  exec: (jim) ->
    @beforeSwitch? jim
    jim.setMode @switchToMode

#### visual mode switches

# switch to characterwise visual mode
map 'v', class extends ModeSwitch
  isRepeatable: no
  beforeSwitch: (jim) -> jim.adaptor.setSelectionAnchor()
  switchToMode: 'visual:characterwise'

# switch to linewise visual mode
map 'V', class extends ModeSwitch
  isRepeatable: no
  beforeSwitch: (jim) -> jim.adaptor.setLinewiseSelectionAnchor()
  switchToMode: 'visual:linewise'

#### insert mode switches

# insert before the char under the cursor
map 'i', class Insert extends ModeSwitch
  switchToMode: 'insert'
  exec: (jim) ->
    @beforeSwitch? jim
    if @repeatableInsert
      # If @repeatableInsert is set, this call to `::exec` is to repeat the insert.
      # Don't switch to insert mode, just insert the text that was inserted the
      # first time.
      jim.adaptor.insert @repeatableInsert.string
    else
      # In order to inform the undo manager (which helps figures out what text to
      # insert when repeating an insert) when the insert is done doing whatever it
      # may have done before the switch to insert mode (e.g. deleted to the end of
      # the line in the case of `C`) and is switching to insert mode, a boolean is
      # set so the undo manager can bookmark that spot during the next keypress event
      jim.afterInsertSwitch = true
      jim.setMode @switchToMode

# insert after the char under the cursor
map 'a', class InsertAfter extends Insert
  beforeSwitch: (jim) -> jim.adaptor.moveRight true

# insert at the end of the line
map 'A', class InsertAtEndOfLine extends Insert
  beforeSwitch: (jim) ->
    new MoveToEndOfLine().exec jim
    jim.adaptor.moveRight true

# delete all remaining text on the line and insert in it's place
map 'C', class ChangeToEndOfLine extends Insert
  beforeSwitch: (jim) ->
    new DeleteToEndOfLine(@count).exec jim

# insert before to first non-blank char of the line
map 'I', class InsertBeforeFirstNonBlank extends Insert
  beforeSwitch: (jim) -> new MoveToFirstNonBlank().exec jim

# create a new line below the cursor and insert there
map 'o', class OpenLine extends Insert
  beforeSwitch: (jim) ->
    row = jim.adaptor.row() + (if @above then 0 else 1)
    jim.adaptor.insertNewLine row
    jim.adaptor.moveTo row, 0

# create a new line above the cursor and insert there
map 'O', class OpenLineAbove extends OpenLine
  above: yes

# replace the char under the cursor with an insert
map 's', class ChangeChar extends Insert
  beforeSwitch: (jim) -> new DeleteChar(@count).exec jim


#### replace mode switch

map 'R', class ReplaceSwitch extends ModeSwitch
  beforeSwitch: (jim) -> jim.adaptor.setOverwriteMode on
  switchToMode: 'replace'


#### general commands

# join a line with the line following it
map 'gJ', class JoinLines extends Command
  exec: (jim) ->
    timesLeft = Math.max(@count, 2) - 1
    while timesLeft--
      jim.adaptor.selectLineEnding @normalize
      jim.adaptor.deleteSelection()
      if @normalize
        jim.adaptor.insert ' '
        jim.adaptor.moveLeft()

  visualExec: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.clearSelection()
    jim.adaptor.moveTo minRow, 0
    # gross?
    @count = maxRow - minRow + 1
    @exec jim
    jim.setMode 'normal'

# join a line with the line following it, with one space separating the lines' content
map 'J', class JoinLinesNormalizingWhitespace extends JoinLines
  normalize: yes

# delete all remaining text on the line
map 'D', class DeleteToEndOfLine extends Command
  exec: (jim) -> new Delete(1, new MoveToEndOfLine @count).exec jim

# paste from the register
map 'p', class Paste extends Command
  exec: (jim) ->
    return if not registerValue = jim.registers['"']

    # using a count with `p` causes the pasted text to be repeated
    text = new Array(@count + 1).join registerValue
    linewiseRegister = /\n$/.test registerValue
    if linewiseRegister
      # Registers with linewise text in them (e.g. yanked with `yy` instead of `yw`,
      # for instance) are never pasted mid-line.  Move to the beginning of a line to
      # ensure this doesn't happen.
      row = jim.adaptor.row() + (if @before then 0 else 1)
      lastRow = jim.adaptor.lastRow()
      if row > lastRow
        # we have to move the line ending to the begining of the string
        [wholeString, beforeLineEnding, lineEnding] = /^([\s\S]*)(\r?\n)$/.exec text
        text = lineEnding + beforeLineEnding

        column = jim.adaptor.lineText(lastRow).length - 1
        jim.adaptor.moveTo row, column
      else
        jim.adaptor.moveTo row, 0
      jim.adaptor.insert text
      jim.adaptor.moveTo row, 0
    else
      jim.adaptor.insert text, not @before

  visualExec: (jim) ->
    if jim.modeName is 'visual:linewise'
      jim.adaptor.makeLinewise()
    else
      jim.adaptor.includeCursorInSelection()
    overwrittenText = jim.adaptor.deleteSelection()
    # gross?
    @before = true
    @exec jim
    jim.registers['"'] = overwrittenText
    jim.setMode 'normal'

# paste after the cursor (or after the line for linewise registers)
map 'P', class extends Paste
  before: yes

# replace the char under the cursor with the key pressed after `r`
map 'r', class extends Command
  # [\s\S] so that it will match \n (windows' \r\n?)
  @followedBy: /[\s\S]+/
  exec: (jim) ->
    jim.adaptor.setSelectionAnchor()
    new MoveRight(@count).exec jim
    jim.adaptor.deleteSelection() # don't yank
    replacementText = if /^\r?\n$/.test @followedBy
      @followedBy
    else
      new Array(@count + 1).join @followedBy
    jim.adaptor.insert replacementText
    new MoveLeft().exec jim


# repeat the previous repeatable command
map '.', class RepeatCommand extends Command
  isRepeatable: no
  exec: (jim) ->
    command = jim.lastCommand
    return if not command

    if command.switchToMode is 'insert'
      command.repeatableInsert or= jim.adaptor.lastInsert()
      console.log 'command.repeatableInsert', command.repeatableInsert
      if not command.repeatableInsert.contiguous
        # for inserts that weren't contiguous (i.e. the user moved the cursor
        # partway through the insert), Vim repeats the insert as a standard `i`
        # insert with just the last contigous piece of the inserted text as
        # the text that gets inserted for the repeat
        {string} = command.repeatableInsert
        command = new Insert()
        command.repeatableInsert = {string}

    if selectionSize = command.selectionSize
      # if we're repeating command made in visual mode, repeating the commmand should
      # affect the same "amount" of text by using motions to move over the same aomount
      # of text
      if selectionSize.lines
        jim.adaptor.makeLinewise selectionSize.lines - 1
      else if selectionSize.chars
        jim.adaptor.setSelectionAnchor()
        new MoveRight(selectionSize.chars).exec jim
      else
        jim.adaptor.setSelectionAnchor()
        row = jim.adaptor.row() + selectionSize.lineEndings
        jim.adaptor.moveTo row, selectionSize.trailingChars - 1

      command.visualExec jim
    else
      #TODO count should replace the lastCommand's count
      command.exec jim

# undo the last command that changed text
map 'u', class Undo extends Command
  isRepeatable: no
  exec: repeatCountTimes (jim) -> jim.adaptor.undo()

# delete the char under the cursor
map 'x', class DeleteChar extends Command
  exec: (jim) -> new Delete(1, new MoveRight @count).exec jim
  
# delete the char before the cursor
map 'X', class extends Command
  exec: (jim) -> new Delete(1, new MoveLeft @count).exec jim


module.exports = {defaultMappings}
