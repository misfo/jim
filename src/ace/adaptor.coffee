define (require, exports, module) ->
  atLineEnd = (editor, beyond) ->
    selectionLead = editor.selection.getSelectionLead()
    lineLength = editor.selection.doc.getLine(selectionLead.row).length
    selectionLead.column >= lineLength - (if beyond then 0 else 1)

  beyondLineEnd = (editor) -> atLineEnd(editor, true)

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

    includeCursorInSelection: ->
      if not @editor.selection.isBackwards()
        @editor.selection.selectRight() unless beyondLineEnd(@editor)

    lastRow: -> @editor.session.getDocument().getLength() - 1

    lineText: (lineNumber) -> @editor.selection.doc.getLine lineNumber ? @row()

    makeLinewise: ->
      {selectionAnchor: {row: anchorRow}, selectionLead: {row: leadRow}} = @editor.selection
      @editor.selection.setSelectionAnchor Math.min(anchorRow, leadRow), 0
      @editor.selection.moveCursorTo Math.max(anchorRow, leadRow) + 1, 0

    moveUp:   -> @editor.selection.moveCursorBy -1, 0
    moveDown: -> @editor.selection.moveCursorBy 1, 0
    moveLeft: ->
      if @editor.selection.selectionLead.getPosition().column > 0
        @editor.selection.moveCursorLeft()
    moveRight: (beyond) ->
      @editor.selection.moveCursorRight() if beyond or not atLineEnd(@editor)

    moveTo: (row, column) -> @editor.moveCursorTo row, column

    moveToEndOfPreviousLine: ->
      previousRow = @row() - 1
      previousRowLength = @editor.session.doc.getLine(previousRow).length
      @editor.selection.moveCursorTo previousRow, previousRowLength

    navigateFileEnd:   -> @editor.navigateFileEnd()
    navigateLineEnd:   -> @editor.navigateLineEnd()
    navigateLineStart: -> @editor.navigateLineStart()

    deleteSelection: ->
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

    selectionText: -> @editor.getCopyText()

    setSelectionAnchor: ->
      lead = @editor.selection.selectionLead
      @editor.selection.setSelectionAnchor lead.row, lead.column
