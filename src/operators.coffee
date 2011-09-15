# An operator followed by a motion is an `Operation`.  For example, `ce` changes
# all the text to the end of the current word since `c` is the change operator
# and `e` is a motion that moves to the end of the word.

{Command} = require './helpers'
{GoToLine, MoveToFirstNonBlank} = require './motions'

# The default key mappings are specified alongside the definitions of each
# `Operation`.  Accumulate the mappings so they can be exported.
defaultMappings = {}
map = (keys, operationClass) -> defaultMappings[keys] = operationClass

# Define the base class for all operations.
class Operation extends Command
  constructor: (@count = 1, @motion) ->
    @motion.operation = this if @motion
  isOperation: true
  isComplete: -> @motion?.isComplete()
  switchToMode: 'normal'

  # Adjust the selection, if needed, and operate on that selection.
  visualExec: (jim) ->
    if @linewise
      jim.adaptor.makeLinewise()
    else if not @motion?.exclusive
      jim.adaptor.includeCursorInSelection()

    @operate jim

    jim.setMode @switchToMode

  # Select the amount of text that the motion moves over and operate on that
  # selection.
  exec: (jim) ->
    @startingPosition = jim.adaptor.position()
    jim.adaptor.setSelectionAnchor()
    if @count isnt 1
      @motion.count *= @count
      @count = 1
    @linewise ?= @motion.linewise
    @motion.exec jim
    @visualExec jim


# Change the selected text or the text that `@motion` moves over (i.e. delete
# the text and switch to insert mode).
map 'c', class Change extends Operation
  visualExec: (jim) ->
    super

    # If we're repeating a `Change`, insert the text that was inserted now that
    # we've deleted the selected text.
    if @repeatableInsert
      jim.adaptor.insert @repeatableInsert.string
      jim.setMode 'normal'

    # If we're executing this `Change` for the first time, set a flag so that an
    # undo mark can be pushed onto the undo stack before any text is inserted.
    else
      jim.afterInsertSwitch = true

  operate: (jim) ->
    # If we're changing a linewise selection or motion, move the end of the
    # previous line so that the cursor is left on an open line once the lines
    # are deleted.
    jim.adaptor.moveToEndOfPreviousLine() if @linewise

    jim.deleteSelection @motion?.exclusive, @linewise

  switchToMode: 'insert'

# Delete the selection or the text that `@motion` moves over.
map 'd', class Delete extends Operation
  operate: (jim) ->
    jim.deleteSelection @motion?.exclusive, @linewise
    new MoveToFirstNonBlank().exec jim if @linewise

# Yank into a register the selection or the text that `@motion` moves over.
map 'y', class Yank extends Operation
  operate: (jim) ->
    jim.yankSelection @motion?.exclusive, @linewise
    jim.adaptor.moveTo @startingPosition... if @startingPosition

# Indent the lines in the selection or the text that `@motion` moves over.
map '>', class Indent extends Operation
  operate: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.indentSelection()
    new GoToLine(minRow + 1).exec jim

# Outdent the lines in the selection or the text that `@motion` moves over.
map '<', class Outdent extends Operation
  operate: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.outdentSelection()
    new GoToLine(minRow + 1).exec jim

module.exports = {Change, Delete, defaultMappings}
