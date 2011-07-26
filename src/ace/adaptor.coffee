define (require, exports, module) ->
  atLineEnd = (editor, beyond) ->
    selectionLead = editor.selection.getSelectionLead()
    lineLength = editor.selection.doc.getLine(selectionLead.row).length
    selectionLead.column >= lineLength - (if beyond then 0 else 1)

  beyondLineEnd = (editor) -> atLineEnd(editor, true)

  class Adaptor
    constructor: (@editor) ->

    setOverwriteMode: (active) -> @editor.setOverwrite active

    clearSelection: (beginning) ->
      if beginning and not @editor.selection.isBackwards()
        {row, column} = @editor.selection.getSelectionAnchor()
        @editor.navigateTo row, column
      else
        @editor.clearSelection()

    undo: ->
      undoManager = @editor.session.getUndoManager()
      undoManager.jimUndo()
      @editor.clearSelection()

    column:   -> @editor.selection.selectionLead.column
    row:      -> @editor.selection.selectionLead.row
    position: -> [@row(), @column()]

    firstFullyVisibleRow: -> @editor.renderer.getFirstFullyVisibleRow()
    lastFullyVisibleRow:  -> @editor.renderer.getLastFullyVisibleRow()

    includeCursorInSelection: ->
      if not @editor.selection.isBackwards()
        @editor.selection.selectRight() unless beyondLineEnd(@editor)

    insertNewLine: (row) ->
      @editor.session.doc.insertNewLine row: row, column: 0

    adjustAnchor: (columnOffset) ->
      {row, column} = @editor.selection.getSelectionAnchor()
      @editor.selection.setSelectionAnchor row, column + columnOffset

    isSelectionBackwards: -> @editor.selection.isBackwards()

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
      dontMove = if beyond then beyondLineEnd(@editor) else atLineEnd(@editor)
      @editor.selection.moveCursorRight() unless dontMove

    moveTo: (row, column) -> @editor.moveCursorTo row, column

    moveToLineEnd: ->
      {row, column} = @editor.selection.selectionLead
      position = @editor.session.getDocumentLastRowColumnPosition row, column
      @moveTo position.row, position.column - 1
    moveToEndOfPreviousLine: ->
      previousRow = @row() - 1
      previousRowLength = @editor.session.doc.getLine(previousRow).length
      @editor.selection.moveCursorTo previousRow, previousRowLength

    navigateFileEnd:   -> @editor.navigateFileEnd()
    navigateLineStart: -> @editor.navigateLineStart()

    findNext:     (pattern) -> @editor.findNext(needle: pattern)
    findPrevious: (pattern) -> @editor.findPrevious(needle: pattern)

    deleteSelection: ->
      yank = @editor.getCopyText()
      @editor.session.remove @editor.getSelectionRange()
      @editor.clearSelection()
      yank

    indentSelection: ->
      @editor.indent()
      @clearSelection()

    outdentSelection: ->
      @editor.blockOutdent()
      @clearSelection()

    insert: (text, after) ->
      @editor.selection.moveCursorRight() if after and not beyondLineEnd(@editor)
      @editor.insert text if text

    emptySelection: -> @editor.selection.isEmpty()

    selectionText: -> @editor.getCopyText()

    setSelectionAnchor: ->
      lead = @editor.selection.selectionLead
      @editor.selection.setSelectionAnchor lead.row, lead.column

    # Jim's linewise selections are really just regular selections with a CSS
    # width of 100%.  When an operation is done, that's when the selection is
    # actually made linewise.  Because of this, it only matters what line the
    # anchor is on.  Therefore, we "hide" the anchor at the end of the line
    # where Jim's cursor won't go so that Ace doesn't remove the selection
    # elements from the DOM (which happens when the cursor and the anchor are
    # in the same place).  It's a wierd hack, but it works.
    #   https://github.com/misfo/jim/issues/5
    setLinewiseSelectionAnchor: ->
      {row, column} = @editor.selection.selectionLead
      lastColumn = @editor.session.getDocumentLastRowColumnPosition row, column
      @editor.selection.setSelectionAnchor row, lastColumn


    selectLineEnding: (andFollowingWhitespace) ->
      @editor.selection.moveCursorLineEnd()
      @editor.selection.selectRight()
      if andFollowingWhitespace
        firstNonBlank = /\S/.exec(@lineText())?.index or 0
        @moveTo @row(), firstNonBlank

    selectionRowRange: ->
      [cursorRow, cursorColumn] = @position()
      {row: anchorRow} = @editor.selection.getSelectionAnchor()
      [Math.min(cursorRow, anchorRow), Math.max(cursorRow, anchorRow)]
