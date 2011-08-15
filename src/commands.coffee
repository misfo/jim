define (require, exports, module) ->
  {Command, repeatCountTimes} = require 'jim/helpers'
  {Change, Delete} = require 'jim/operators'
  {GoToLine, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank} = require 'jim/motions'

  defaultMappings = {}
  map = (keys, commandClass) -> defaultMappings[keys] = commandClass

  class ModeSwitch extends Command
    exec: (jim) ->
      @beforeSwitch? jim
      jim.setMode @switchToMode

  #### visual mode switches

  map 'v', class extends ModeSwitch
    isRepeatable: no
    beforeSwitch: (jim) -> jim.adaptor.setSelectionAnchor()
    switchToMode: 'visual:characterwise'

  map 'V', class extends ModeSwitch
    isRepeatable: no
    beforeSwitch: (jim) -> jim.adaptor.setLinewiseSelectionAnchor()
    switchToMode: 'visual:linewise'

  #### insert mode switches

  map 'i', class Insert extends ModeSwitch
    switchToMode: 'insert'
    exec: (jim) ->
      @beforeSwitch? jim
      if @repeatableInsert
        jim.adaptor.insert @repeatableInsert.string
      else
        jim.afterInsertSwitch = true
        jim.setMode @switchToMode

  map 'a', class InsertAfter extends Insert
    beforeSwitch: (jim) -> jim.adaptor.moveRight true

  map 'A', class InsertAtEndOfLine extends Insert
    beforeSwitch: (jim) ->
      new MoveToEndOfLine().exec jim
      jim.adaptor.moveRight true

  map 'C', class ChangeToEndOfLine extends Insert
    beforeSwitch: (jim) ->
      new DeleteToEndOfLine(@count).exec jim

  map 'I', class InsertBeforeFirstNonBlank extends Insert
    beforeSwitch: (jim) -> new MoveToFirstNonBlank().exec jim

  map 'o', class OpenLine extends Insert
    beforeSwitch: (jim) ->
      row = jim.adaptor.row() + (if @above then 0 else 1)
      jim.adaptor.insertNewLine row
      jim.adaptor.moveTo row, 0

  map 'O', class OpenLineAbove extends OpenLine
    above: yes

  map 's', class ChangeChar extends Insert
    beforeSwitch: (jim) -> new DeleteChar(@count).exec jim


  #### replace mode switch

  map 'R', class ReplaceSwitch extends ModeSwitch
    beforeSwitch: (jim) -> jim.adaptor.setOverwriteMode on
    switchToMode: 'replace'


  #### general commands
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

  map 'J', class JoinLinesNormalizingWhitespace extends JoinLines
    normalize: yes

  map 'D', class DeleteToEndOfLine extends Command
    exec: (jim) -> new Delete(1, new MoveToEndOfLine @count).exec jim

  map 'p', class Paste extends Command
    exec: (jim) ->
      return if not registerValue = jim.registers['"']

      text = new Array(@count + 1).join registerValue
      linewiseRegister = /\n$/.test registerValue
      if linewiseRegister
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
      jim.adaptor.includeCursorInSelection()
      overwrittenText = jim.adaptor.deleteSelection()
      # gross?
      @before = true
      @exec jim
      jim.registers['"'] = overwrittenText
      jim.setMode 'normal'

  map 'P', class extends Paste
    before: yes

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

      #TODO count should replace the lastCommand's count
      command.exec jim

  map 'u', class Undo extends Command
    isRepeatable: no
    exec: repeatCountTimes (jim) -> jim.adaptor.undo()

  map 'x', class DeleteChar extends Command
    exec: (jim) -> new Delete(1, new MoveRight @count).exec jim
  map 'X', class extends Command
    exec: (jim) -> new Delete(1, new MoveLeft @count).exec jim


  #### exported properties

  {defaultMappings}
