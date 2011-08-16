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

    lastInsert: -> @editor.session.getUndoManager().lastInsert()

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

    makeLinewise: (lines) ->
      {selectionAnchor: {row: anchorRow}, selectionLead: {row: leadRow}} = @editor.selection
      [firstRow, lastRow] = if lines?
        [leadRow, leadRow + (lines - 1)]
      else
        [Math.min(anchorRow, leadRow), Math.max(anchorRow, leadRow)]
      @editor.selection.setSelectionAnchor firstRow, 0
      @editor.selection.moveCursorTo lastRow + 1, 0

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

    findNext: (pattern) ->
      @editor.$search.set needle: pattern, backwards: false
      # move the cursor right so that it won't match what's already under the
      # cursor. move the cursor back afterwards if nothing's found
      @editor.selection.moveCursorRight()
      range = @editor.$search.find @editor.session
      if range
        @moveTo range.start.row, range.start.column
      else
        @editor.selection.moveCursorLeft()
    findPrevious: (pattern) ->
      @editor.$search.set needle: pattern, backwards: true
      range = @editor.$search.find @editor.session
      @moveTo range.start.row, range.start.column if range

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

    characterwiseSelectionSize: ->
      {selectionAnchor, selectionLead} = @editor.selection
      rowsDown = selectionLead.row - selectionAnchor.row
      if rowsDown is 0
        chars: Math.abs(selectionAnchor.column - selectionLead.column)
      else
        lineEndings: Math.abs(rowsDown)
        trailingChars: (if rowsDown > 0 then selectionLead else selectionAnchor).column
