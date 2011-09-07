# An operator followed by a motion is an operation.  For example, `ce` changes
# all the text to the end of the current word since `c` is the change operator
# and `e` is a motion that moves to the end of the word.

{Command} = require './helpers'
{GoToLine, MoveToFirstNonBlank, MoveToNextBigWord, MoveToNextWord, MoveToBigWordEnd, MoveToWordEnd} = require './motions'

defaultMappings = {}
map = (keys, operatorClass) -> defaultMappings[keys] = operatorClass

# base class for all operations
class Operation extends Command
  constructor: (@count = 1, @motion) ->
    @motion.operation = this if @motion
  isOperation: true
  isComplete: -> @motion?.isComplete()
  switchToMode: 'normal'

  # Adjust the selection, if needed, and operate on that selection
  visualExec: (jim) ->
    if @linewise
      jim.adaptor.makeLinewise()
    else if not @motion?.exclusive
      jim.adaptor.includeCursorInSelection()

    @operate jim

    jim.setMode @switchToMode

  exec: (jim) ->
    @startingPosition = jim.adaptor.position()
    jim.adaptor.setSelectionAnchor()
    if @count isnt 1
      @motion.count *= @count
      @count = 1
    @linewise ?= @motion.linewise
    @motion.exec jim
    @visualExec jim


map 'c', class Change extends Operation
  visualExec: (jim) ->
    super

    if @repeatableInsert
      jim.adaptor.insert @repeatableInsert.string
      jim.setMode 'normal'
    else
      jim.afterInsertSwitch = true

  operate: (jim) ->
    jim.adaptor.moveToEndOfPreviousLine() if @linewise
    jim.deleteSelection @motion?.exclusive, @linewise
  switchToMode: 'insert'

map 'd', class Delete extends Operation
  operate: (jim) ->
    jim.deleteSelection @motion?.exclusive, @linewise
    new MoveToFirstNonBlank().exec jim if @linewise

map 'y', class Yank extends Operation
  operate: (jim) ->
    jim.yankSelection @motion?.exclusive, @linewise
    jim.adaptor.moveTo @startingPosition... if @startingPosition

map '>', class Indent extends Operation
  operate: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.indentSelection()
    new GoToLine(minRow + 1).exec jim

map '<', class Outdent extends Operation
  operate: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.outdentSelection()
    new GoToLine(minRow + 1).exec jim

module.exports = {Change, Delete, defaultMappings}
