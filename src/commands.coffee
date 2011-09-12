# All commands, other than operations and motions, live in here.  Commands can
# be prefixed with a `count` which multiplies their action in some way. Commands
# that define a `::visualExec` will be available in visual mode as well as
# normal mode.

{Command, repeatCountTimes} = require './helpers'
{Delete} = require './operators'
{MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank} = require './motions'

# The default key mappings are specified alongside the definitions of each command.
# Accumulate the mappings so they can be exported.
defaultMappings = {}
map = (keys, commandClass) -> defaultMappings[keys] = commandClass

# Define a convenience class for commands that switch to another mode.
class ModeSwitch extends Command
  exec: (jim) ->
    @beforeSwitch? jim
    jim.setMode @switchToMode


# Visual mode switches
# --------------------

# Switch to characterwise visual mode.
map 'v', class VisualSwitch extends Command
  isRepeatable: no
  exec: (jim) ->
    anchor = jim.adaptor.position()
    jim.adaptor.setSelectionAnchor()
    jim.setMode 'visual', {anchor}
  visualExec: (jim) ->
    if jim.mode.linewise
      jim.setMode 'visual', linewise: no
      jim.adaptor.editor.selection.setSelectionAnchor jim.mode.anchor...
    else
      jim.onEscape()

# Switch to linewise visual mode.
map 'V', class VisualLinewiseSwitch extends Command
  isRepeatable: no
  exec: (jim) ->
    anchor = jim.adaptor.setLinewiseSelectionAnchor()
    jim.setMode 'visual', {linewise: yes, anchor}
  visualExec: (jim) ->
    if jim.mode.linewise
      jim.onEscape()
    else
      modeState = linewise: yes
      anchor = jim.adaptor.setLinewiseSelectionAnchor()
      modeState.anchor = anchor unless jim.mode.anchor
      jim.setMode 'visual', modeState


# Insert mode switches
# --------------------

# Insert before the char under the cursor.
map 'i', class Insert extends ModeSwitch
  switchToMode: 'insert'
  exec: (jim) ->
    @beforeSwitch? jim
    if @repeatableInsert
      # If `@repeatableInsert` is set, this call to `::exec` is to repeat the
      # insert. Don't switch to insert mode, just insert the text that was
      # inserted the first time.
      jim.adaptor.insert @repeatableInsert.string
    else
      # In order to inform the undo manager (which helps figures out what text to
      # insert when repeating an insert) when the insert is done doing whatever it
      # may have done before the switch to insert mode (e.g. deleted to the end of
      # the line in the case of `C`) and is switching to insert mode, a boolean is
      # set so the undo manager can bookmark that spot during the next keypress event
      jim.afterInsertSwitch = true

      jim.setMode @switchToMode

# Insert after the char under the cursor.
map 'a', class InsertAfter extends Insert
  beforeSwitch: (jim) -> jim.adaptor.moveRight true

# Insert at the end of the line.
map 'A', class InsertAtEndOfLine extends Insert
  beforeSwitch: (jim) ->
    new MoveToEndOfLine().exec jim
    jim.adaptor.moveRight true

# Delete all remaining text on the line and insert in its place.
map 'C', class ChangeToEndOfLine extends Insert
  beforeSwitch: (jim) ->
    new DeleteToEndOfLine(@count).exec jim

# Insert before to first non-blank char of the line.
map 'I', class InsertBeforeFirstNonBlank extends Insert
  beforeSwitch: (jim) -> new MoveToFirstNonBlank().exec jim

# Create a new line below the cursor and insert there.
map 'o', class OpenLine extends Insert
  beforeSwitch: (jim) ->
    row = jim.adaptor.row() + (if @above then 0 else 1)
    jim.adaptor.insertNewLine row
    jim.adaptor.moveTo row, 0

# Create a new line above the cursor and insert there.
map 'O', class OpenLineAbove extends OpenLine
  above: yes

# Replace the char under the cursor with an insert.
map 's', class ChangeChar extends Insert
  beforeSwitch: (jim) -> new DeleteChar(@count).exec jim


# Replace mode switch
# -------------------

map 'R', class ReplaceSwitch extends ModeSwitch
  beforeSwitch: (jim) -> jim.adaptor.setOverwriteMode on
  switchToMode: 'replace'


# Miscellaneous commands
# ----------------------

# Join a line with the line following it.
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
    @count = maxRow - minRow + 1
    @exec jim
    jim.setMode 'normal'

# Join a line with the line following it, ensuring that one space separates the
# content from the lines.
map 'J', class JoinLinesNormalizingWhitespace extends JoinLines
  normalize: yes

# Delete all remaining text on the line.
map 'D', class DeleteToEndOfLine extends Command
  exec: (jim) -> new Delete(1, new MoveToEndOfLine @count).exec jim

# Paste after the cursor. Paste after the line if pasting linewise register.
map 'p', class Paste extends Command
  exec: (jim) ->
    return if not registerValue = jim.registers['"']

    # Using a count with `p` causes the pasted text to be repeated.
    text = new Array(@count + 1).join registerValue
    linewiseRegister = /\n$/.test registerValue
    if linewiseRegister
      # Registers with linewise text in them (e.g. yanked with `yy` instead of `yw`,
      # for instance) are never pasted mid-line.  Move to the beginning of a line to
      # ensure this doesn't happen.
      row = jim.adaptor.row() + (if @before then 0 else 1)
      lastRow = jim.adaptor.lastRow()

      # If we're pasting row(s) after the last row, we have to move the line
      # ending to the begining of the string.
      if row > lastRow
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
    if jim.mode.linewise
      jim.adaptor.makeLinewise()
    else
      jim.adaptor.includeCursorInSelection()
    overwrittenText = jim.adaptor.deleteSelection()
    @before = true
    @exec jim
    jim.registers['"'] = overwrittenText
    jim.setMode 'normal'

# Paste before the cursor. Paste before the line if pasting linewise register.
map 'P', class PasteBefore extends Paste
  before: yes

# Replace the char under the cursor with the char pressed after `r`.
map 'r', class ReplaceChar extends Command
  # Match `[\s\S]` so that it will match `\n` (windows' `\r\n`?)
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


# Repeat the last repeatable command.
map '.', class RepeatCommand extends Command
  isRepeatable: no
  exec: (jim) ->
    command = jim.lastCommand
    return if not command

    if command.switchToMode is 'insert'
      console.log 'command.repeatableInsert', command.repeatableInsert

      # For an insert that wasn't contiguous (i.e. the user moved the cursor
      # partway through the insert), Vim repeats it as a standard `i` insert
      # with just the last contigous piece of text.
      if not command.repeatableInsert.contiguous
        {string} = command.repeatableInsert
        command = new Insert()
        command.repeatableInsert = {string}

    if selectionSize = command.selectionSize
      # If we're repeating a command made in visual mode, it should affect the
      # same "amount" of text by using motions to move over the same aomount
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

# Undo the last command that modified the document.
map 'u', class Undo extends Command
  isRepeatable: no
  exec: repeatCountTimes (jim) -> jim.adaptor.undo()

# Delete the char under the cursor.
map 'x', class DeleteChar extends Command
  exec: (jim) -> new Delete(1, new MoveRight @count).exec jim
  
# Delete the char before the cursor.
map 'X', class Backspace extends Command
  exec: (jim) -> new Delete(1, new MoveLeft @count).exec jim


# Exports
# -------
module.exports = {defaultMappings}
