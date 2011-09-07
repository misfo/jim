{UndoManager} = require 'ace/undomanager'
Jim           = require './jim'

class Adaptor
  constructor: (@editor) ->

  atLineEnd = (editor, beyond) ->
    selectionLead = editor.selection.getSelectionLead()
    lineLength = editor.selection.doc.getLine(selectionLead.row).length
    selectionLead.column >= lineLength - (if beyond then 0 else 1)

  beyondLineEnd = (editor) -> atLineEnd(editor, true)

  onModeChange: (prevMode, newMode) ->
    for mode in ['insert', 'normal', 'visual']
      @editor[if mode is newMode.name then 'setStyle' else 'unsetStyle'] "jim-#{mode}-mode"

    @editor[if newMode.name is 'visual' and newMode.linewise then 'setStyle' else 'unsetStyle'] 'jim-visual-linewise-mode'

    if newMode.name is 'insert'
      @markUndoPoint 'jim:insert:start'
    else if prevMode?.name is 'insert'
      @markUndoPoint 'jim:insert:end'

    if newMode.name is 'replace'
      @markUndoPoint 'jim:replace:start'
    else if prevMode?.name is 'replace'
      @markUndoPoint 'jim:replace:end'

  markUndoPoint: (markName) ->
    @editor.session.getUndoManager().execute args: [markName, @editor.session]

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
  lastFullyVisibleRow:  ->
    # Ace sometimes sees more rows then there are lines, this will
    # keep that in check.
    totalLines = @editor.selection.doc.$lines.length
    lastVisibleRow = @editor.renderer.getLastFullyVisibleRow()
    if totalLines < lastVisibleRow
      totalLines
    else
      lastVisibleRow

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

  search: (backwards, needle, wholeWord) ->
    @editor.$search.set {backwards, needle, wholeWord}

    # move the cursor right so that it won't match what's already under the
    # cursor. move the cursor back afterwards if nothing's found
    @editor.selection.moveCursorRight() unless backwards

    if range = @editor.$search.find @editor.session
      @moveTo range.start.row, range.start.column
    else if not backwards
      @editor.selection.moveCursorLeft()

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
  # width of 100%.  Before a visual command is exececuted the selection is
  # actually made linewise.  Because of this, it only matters what line the
  # anchor is on.  Therefore, we "hide" the anchor at the end of the line
  # where Jim's cursor won't go so that Ace doesn't remove the selection
  # elements from the DOM (which happens when the cursor and the anchor are
  # in the same place).  It's a wierd hack, but it works.
  #   https://github.com/misfo/jim/issues/5
  setLinewiseSelectionAnchor: ->
    {selection} = @editor
    {row, column} = selection[if selection.isEmpty() then 'selectionLead' else 'selectionAnchor']
    lastColumn = @editor.session.getDocumentLastRowColumnPosition row, column
    selection.setSelectionAnchor row, lastColumn
    [row, column]


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
      trailingChars: (if rowsDown > 0 then selectionLead else selectionAnchor).column + 1


class JimUndoManager extends UndoManager
  # override so that the default undo (button and keyboard shortcut)
  # will skip over Jim's bookmarks and behave as they usually do
  undo: ->
    @silentUndo() if @isJimMark @lastOnUndoStack()
    super

  isJimMark: (entry) ->
    typeof entry is 'string' and /^jim:/.test entry

  lastOnUndoStack: -> @$undoStack[@$undoStack.length-1]

  silentUndo: ->
    deltas = @$undoStack.pop()
    @$redoStack.push deltas if deltas

  matchingMark:
    'jim:insert:end':  'jim:insert:start'
    'jim:replace:end': 'jim:replace:start'

  jimUndo: ->
    lastDeltasOnStack = @lastOnUndoStack()
    if typeof lastDeltasOnStack is 'string' and startMark = @matchingMark[lastDeltasOnStack]
      startIndex = null
      for i in [(@$undoStack.length-1)..0]
        if @$undoStack[i] is startMark
          startIndex = i
          break

      if not startIndex?
        console.log "found a \"#{lastDeltasOnStack}\" on the undoStack, but no \"#{startMark}\""
        return

      @silentUndo() # pop the end off
      while @$undoStack.length > startIndex + 1
        if @isJimMark @lastOnUndoStack()
          @silentUndo()
        else
          @undo()
      @silentUndo() # pop the start off
    else
      @undo()

  lastInsert: ->
    return '' if @lastOnUndoStack() isnt 'jim:insert:end'

    startPosition = null
    stringParts = []
    isContiguousInsert = (delta) ->
      return false unless delta.action is 'insertText'
      not startPosition or delta.range.isEnd startPosition...

    for i in [(@$undoStack.length - 2)..0]
      break if typeof @$undoStack[i] is 'string'
      for j in [(@$undoStack[i].length - 1)..0]
        for k in [(@$undoStack[i][j].deltas.length - 1)..0]
          item = @$undoStack[i][j]
          delta = item.deltas[k]
          if item is 'jim:insert:start' or item is 'jim:insert:afterSwitch'
            return string: stringParts.join(''), contiguous: true
          else if isContiguousInsert delta
            stringParts.unshift delta.text
            startPosition = [delta.range.start.row, delta.range.start.column]
          else
            return string: stringParts.join(''), contiguous: false
    string: stringParts.join(''), contiguous: true

require('pilot/dom').importCssString """
  .jim-normal-mode div.ace_cursor
  , .jim-visual-mode div.ace_cursor {
    border: 0;
    background-color: #91FF00;
    opacity: 0.5;
  }
  .jim-visual-linewise-mode .ace_marker-layer .ace_selection {
    left: 0 !important;
    width: 100% !important;
  }
"""

isCharacterKey = (hashId, keyCode) -> hashId is 0 and not keyCode

Jim.aceInit = (editor) ->
  editor.setKeyboardHandler
    handleKeyboard: (data, hashId, keyString, keyCode) ->
      if keyCode is 27 # esc
        jim.onEscape()
      else if isCharacterKey hashId, keyCode
        if jim.afterInsertSwitch
          if jim.mode.name is 'insert'
            jim.adaptor.markUndoPoint 'jim:insert:afterSwitch'
          jim.afterInsertSwitch = false

        if jim.mode.name is 'normal' and not jim.adaptor.emptySelection()
          # if a selection has been made with the mouse since the last
          # keypress in normal mode, switch to visual mode
          jim.setMode 'visual'

        if keyString.length > 1
          #TODO handle this better, we're dropping keypresses here
          keyString = keyString.charAt 0

        passKeypressThrough = jim.onKeypress keyString

        if not passKeypressThrough
          # this will stop the event
          command: {exec: (->)}

  undoManager = new JimUndoManager()
  editor.session.setUndoManager undoManager

  adaptor = new Adaptor editor
  jim = new Jim adaptor

  # to initialize the editor class names
  adaptor.onModeChange null, name: 'normal'

  jim
