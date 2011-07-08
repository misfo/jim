define (require, exports, module) ->
  atLineEnd = (editor, beyond) ->
    selectionLead = editor.selection.getSelectionLead()
    lineLength = editor.selection.doc.getLine(selectionLead.row).length
    selectionLead.column >= lineLength - (if beyond then 0 else 1)

  beyondLineEnd = (editor) -> atLineEnd(editor, true)

  fixSelection = (exclusive) ->
    if not exclusive and not @editor.selection.isBackwards()
      # the block cursor should be part of the selection
      @editor.selection.selectRight() unless beyondLineEnd(@editor)

  class Adaptor
    constructor: (@editor) ->

    clearSelection: -> @editor.clearSelection()

    undo: ->
      undoManager = @editor.session.getUndoManager()
      undoManager.jimUndo()
      @editor.clearSelection()

    column:   -> @editor.selection.selectionLead.column
    row:      -> @editor.selection.selectionLead.row
    position: -> [@row(), @column()]

    lastRow: -> @editor.session.getDocument().getLength() - 1

    goToLine: (lineNumber) -> @editor.gotoLine lineNumber

    lineText: (lineNumber) -> @editor.selection.doc.getLine lineNumber ? @row()

    moveUp:   -> @editor.selection.moveCursorBy -1, 0
    moveDown: -> @editor.selection.moveCursorBy 1, 0
    moveLeft: ->
      if @editor.selection.selectionLead.getPosition().column > 0
        @editor.selection.moveCursorLeft()
    moveRight: ->
      if not atLineEnd(@editor)
        @editor.selection.moveCursorRight()

    moveTo: (row, column) -> @editor.moveCursorTo row, column

    navigateFileEnd:   -> @editor.navigateFileEnd()
    navigateLineEnd:   -> @editor.navigateLineEnd()
    navigateLineStart: -> @editor.navigateLineStart()

    deleteSelection: (exclusive) ->
      fixSelection.call this, exclusive
      yank = @editor.getCopyText()
      @editor.session.remove @editor.getSelectionRange()
      @editor.clearSelection()
      yank

    insert: (text, after) ->
      @editor.selection.moveCursorRight() if after and not beyondLineEnd(@editor)
      @editor.insert text if text

    selectLine: -> @editor.selection.selectLine()

    selectToLineEnd: -> @editor.selection.selectLineEnd()

    emptySelection: -> @editor.selection.isEmpty()

    selectionText: (exclusive) ->
      fixSelection.call this, exclusive
      @editor.getCopyText()

    setSelectionAnchor: ->
      lead = @editor.selection.selectionLead
      @editor.selection.setSelectionAnchor lead.row, lead.column
