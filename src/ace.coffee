# All of Jim's Ace-specific code is in here.  The idea is that an `Adaptor` for
# another editor could be written that implemented the same methods and presto!
# Jim works in that editor, too!  It's probably not that simple, but we'll find
# out... patches welcome :)

{UndoManager} = require 'ace/undomanager'
Jim           = require './jim'

# Ace's editor adaptor
# --------------------
#
# Each instance of `Jim` has an instance of an `Adaptor` on which it invokes
# methods to move the cursor, change some text, etc.
class Adaptor
  # Constuct an `Adaptor` with instance of Ace's `Editor`
  constructor: (@editor) ->

  # Return true if the cursor is on or beyond the last character of the line. If
  # `beyond` is true, return true only if the cursor is beyond the last char.
  atLineEnd = (editor, beyond) ->
    selectionLead = editor.selection.getSelectionLead()
    lineLength = editor.selection.doc.getLine(selectionLead.row).length
    selectionLead.column >= lineLength - (if beyond then 0 else 1)

  beyondLineEnd = (editor) -> atLineEnd(editor, true)

  # Whenever Jim's mode changes, update the editor's `className` and push a
  # "bookmark" onto the undo stack, if needed (explained below).
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

  # Vim's undo is particularly useful because it's idea of an atomic edit is
  # clear to the user.  One `Command` is undone each time `u` is pressed.  That
  # means all text entered between hitting `i` and hitting `<esc>` is undone as
  # one atomic edit.
  #
  # To match Vim's undo granularity, Jim pushes "bookmarks" onto the undo stack
  # to indicate when an insert starts or ends, for example.  This helps us avoid
  # having to record all keystrokes made while in insert or replace mode.
  markUndoPoint: (markName) ->
    @editor.session.getUndoManager().execute args: [markName, @editor.session]

  # Turns overwrite mode on or off (used for Jim's replace mode).
  setOverwriteMode: (active) -> @editor.setOverwrite active

  # Clears the selection, optionally positioning the cursor at its beginning.
  clearSelection: (beginning) ->
    if beginning and not @editor.selection.isBackwards()
      {row, column} = @editor.selection.getSelectionAnchor()
      @editor.navigateTo row, column
    else
      @editor.clearSelection()

  # Undo the last `Command`.
  undo: ->
    undoManager = @editor.session.getUndoManager()
    undoManager.jimUndo()
    @editor.clearSelection()

  # Get information about the last insert `Command`. See
  # `JimUndoManager::lastInsert`.
  lastInsert: -> @editor.session.getUndoManager().lastInsert()

  # Define methods for getting the cursor's position in the document.
  column:   -> @editor.selection.selectionLead.column
  row:      -> @editor.selection.selectionLead.row
  position: -> [@row(), @column()]

  # Return the first row that is fully visible in the viewport.
  firstFullyVisibleRow: -> @editor.renderer.getFirstFullyVisibleRow()

  # Return the last row in the document that is fully visible in the viewport.
  lastFullyVisibleRow:  ->
    lastVisibleRow = @editor.renderer.getLastFullyVisibleRow()
    Math.min @lastRow(), lastVisibleRow

  # Before we act on a non-backwards selection, Jim's block cursor is not
  # considered by Ace to be part of the selection.  Make the cursor part of the
  # selection before we act on it.
  includeCursorInSelection: ->
    if not @editor.selection.isBackwards()
      @editor.selection.selectRight() unless beyondLineEnd(@editor)

  # Insert a new line at a zero-based row number.
  insertNewLine: (row) ->
    @editor.session.doc.insertNewLine row: row, column: 0

  # Move the anchor by `columnOffset` columns, which can be negative.
  adjustAnchor: (columnOffset) ->
    {row, column} = @editor.selection.getSelectionAnchor()
    @editor.selection.setSelectionAnchor row, column + columnOffset

  # Is the anchor ahead of the cursor?
  isSelectionBackwards: -> @editor.selection.isBackwards()

  # Return the last zero-based row number.
  lastRow: -> @editor.session.getDocument().getLength() - 1

  # Return the text that's on `lineNumber` or the current line.
  lineText: (lineNumber) -> @editor.selection.doc.getLine lineNumber ? @row()

  # Make a linewise selection `lines` long if specified or make the current
  # selection linewise by pushing the lead and the anchor to the ends of their
  # lines.
  makeLinewise: (lines) ->
    {selectionAnchor: {row: anchorRow}, selectionLead: {row: leadRow}} = @editor.selection
    [firstRow, lastRow] = if lines?
      [leadRow, leadRow + (lines - 1)]
    else
      [Math.min(anchorRow, leadRow), Math.max(anchorRow, leadRow)]
    @editor.selection.setSelectionAnchor firstRow, 0
    @editor.selection.moveCursorTo lastRow + 1, 0

  # Define basic directional movements. These won't clear the selection.
  moveUp:   -> @editor.selection.moveCursorBy -1, 0
  moveDown: -> @editor.selection.moveCursorBy 1, 0
  moveLeft: ->
    if @editor.selection.selectionLead.getPosition().column > 0
      @editor.selection.moveCursorLeft()
  moveRight: (beyond) ->
    dontMove = if beyond then beyondLineEnd(@editor) else atLineEnd(@editor)
    @editor.selection.moveCursorRight() unless dontMove

  # Move to a zero-based `row` and `column`.
  moveTo: (row, column) -> @editor.moveCursorTo row, column

  # Put the cursor on the last column of the line.
  moveToLineEnd: ->
    {row, column} = @editor.selection.selectionLead
    position = @editor.session.getDocumentLastRowColumnPosition row, column
    @moveTo position.row, position.column - 1
  moveToEndOfPreviousLine: ->
    previousRow = @row() - 1
    previousRowLength = @editor.session.doc.getLine(previousRow).length
    @editor.selection.moveCursorTo previousRow, previousRowLength

  # Move to first or last line.
  navigateFileEnd:   -> @editor.navigateFileEnd()
  navigateLineStart: -> @editor.navigateLineStart()

  # Move the cursor to the fist char of the matching search or don't move at
  # all.
  search: (backwards, needle, wholeWord) ->
    @editor.$search.set {backwards, needle, wholeWord}

    # Move the cursor right so that it won't match what's already under the
    # cursor.  Move the cursor back afterwards if nothing's found.
    @editor.selection.moveCursorRight() unless backwards

    if range = @editor.$search.find @editor.session
      @moveTo range.start.row, range.start.column
    else if not backwards
      @editor.selection.moveCursorLeft()

  # Delete selected text and return it as a string.
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

  # Insert `text` before or after the cursor.
  insert: (text, after) ->
    @editor.selection.moveCursorRight() if after and not beyondLineEnd(@editor)
    @editor.insert text if text

  emptySelection: -> @editor.selection.isEmpty()

  selectionText: -> @editor.getCopyText()

  # Set the selection anchor to the cusor's current position.
  setSelectionAnchor: ->
    lead = @editor.selection.selectionLead
    @editor.selection.setSelectionAnchor lead.row, lead.column

  # Jim's linewise selections are really just regular selections with a CSS
  # width of `100%`.  Before a visual command is exececuted the selection is
  # actually made linewise.  Because of this, it only matters what line the
  # anchor is on.  Therefore, we "hide" the anchor at the end of the line
  # where Jim's cursor won't go so that Ace doesn't remove the selection
  # elements from the DOM (which happens when the cursor and the anchor are
  # in the same place).  It's a wierd hack, but it works.  There was a
  # [github issue](https://github.com/misfo/jim/issues/5) for this.
  setLinewiseSelectionAnchor: ->
    {selection} = @editor
    {row, column} = selection[if selection.isEmpty() then 'selectionLead' else 'selectionAnchor']
    lastColumn = @editor.session.getDocumentLastRowColumnPosition row, column
    selection.setSelectionAnchor row, lastColumn
    [row, column]


  # Select the line ending at the end of the current line and any whitespace at
  # the beginning of the next line if `andFollowingWhitespace` is specified.
  # This is used for the line joining commands `gJ` and `J`.
  selectLineEnding: (andFollowingWhitespace) ->
    @editor.selection.moveCursorLineEnd()
    @editor.selection.selectRight()
    if andFollowingWhitespace
      firstNonBlank = /\S/.exec(@lineText())?.index or 0
      @moveTo @row(), firstNonBlank

  # Return the first and the last line that are part of the current selection.
  selectionRowRange: ->
    [cursorRow, cursorColumn] = @position()
    {row: anchorRow} = @editor.selection.getSelectionAnchor()
    [Math.min(cursorRow, anchorRow), Math.max(cursorRow, anchorRow)]

  # Return the number of chars selected if the selection is one row. If the
  # selection is multiple rows, return the number of line endings selected
  # and the number of chars selected on the last row of the selection.
  characterwiseSelectionSize: ->
    {selectionAnchor, selectionLead} = @editor.selection
    rowsDown = selectionLead.row - selectionAnchor.row
    if rowsDown is 0
      chars: Math.abs(selectionAnchor.column - selectionLead.column)
    else
      lineEndings: Math.abs(rowsDown)
      trailingChars: (if rowsDown > 0 then selectionLead else selectionAnchor).column + 1


# Jim's undo manager
# ------------------
#
# Ace's `UndoManager` is extended to handle undoing and repeating switches to
# insert and replace mode.
class JimUndoManager extends UndoManager
  # Override Ace's default `undo` so that the default undo button and keyboard
  # shortcut will skip over Jim's bookmarks and behave as they usually do.
  undo: ->
    @silentUndo() if @isJimMark @lastOnUndoStack()
    super

  # Is this a bookmark we pushed onto the stack or an actual Ace undo entry?
  isJimMark: (entry) ->
    typeof entry is 'string' and /^jim:/.test entry

  lastOnUndoStack: -> @$undoStack[@$undoStack.length-1]

  # Pop the item off the stack without doing anything with it.
  silentUndo: ->
    deltas = @$undoStack.pop()
    @$redoStack.push deltas if deltas

  matchingMark:
    'jim:insert:end':  'jim:insert:start'
    'jim:replace:end': 'jim:replace:start'

  # If the last command was an insert or a replace ensure that all undo items
  # associated with that command are undone.  If not, just do a regular ace
  # undo.
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

  # If the last command was an insert, return all text that was inserted taking
  # backspaces into account.
  #
  # If the cursor moved partway through the insert (with arrow keys or with the
  # mouse), then only the last peice of contiguously inserted text is returned
  # and `contiguous` is returned as `false`.  This is to match Vim's behavior
  # when repeating non-contiguous inserts.
  lastInsert: ->
    return '' if @lastOnUndoStack() isnt 'jim:insert:end'

    cursorPosInsert = null
    cursorPosRemove = null
    action = null
    stringParts = []
    removedParts = []
    isContiguous = (delta) ->
      return false unless /(insert|remove)/.test delta.action
      if not action or action is delta.action
        if delta.action is 'insertText'
          not cursorPosInsert or delta.range.isEnd cursorPosInsert...
        else
          not cursorPosRemove or delta.range.isStart cursorPosRemove...
      else
        if delta.action is 'insertText' and cursorPosInsert?
          delta.range.end.row is cursorPosInsert[0]
        else if delta.action is 'removeText' and cursorPosRemove?
          delta.range.end.row is cursorPosRemove[0]
        else
          true

    for i in [(@$undoStack.length - 2)..0]
      break if typeof @$undoStack[i] is 'string'
      for j in [(@$undoStack[i].length - 1)..0]
        for k in [(@$undoStack[i][j].deltas.length - 1)..0]
          delta = @$undoStack[i][j].deltas[k]
          if isContiguous(delta)
            action = delta.action
            if action is 'removeText'
              cursorPosRemove = [delta.range.end.row, delta.range.end.column]
              for text in delta.text.split('')
                removedParts.push text

            if action is 'insertText'
              cursorPosInsert = [delta.range.start.row, delta.range.start.column]
              continue if removedParts.length and delta.text is removedParts.pop()
              for text in [(delta.text.length - 1)..0]
                stringParts.unshift delta.text[text]
          else
            return string: stringParts.join(''), contiguous: false
    string: stringParts.join(''), contiguous: true


# Cursor and selection styles
# ---------------------------
#
# Make Ace's cursor be block-style when Jim is in normal mode and make
# selections span the editor's entire width when in linewise visual mode.
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


# Hooking into Ace
# ----------------

# Is the keyboard event a printable character key?
isCharacterKey = (hashId, keyCode) -> hashId is 0 and not keyCode

# Is keyboard string a match for following regex?
#
# * Arrow keys (up, down, left, right)
# * Space keys (space, backspace)
# * Delete
isSelectiveKeys = (keyString) ->
  ///
  (up|down|left|right # Arrow keys
  |(back)?space       # Space keys
  |delete)            # Delete
  ///.test keyString

# Set up Jim to handle the Ace `editor`'s keyboard events.
Jim.aceInit = (editor) ->
  editor.setKeyboardHandler
    handleKeyboard: (data, hashId, keyString, keyCode) ->
      if keyCode is 27 or (hashId is 1 and keyString is '[') # `esc` or `ctrl-[`
        jim.onEscape()
      else if isCharacterKey(hashId, keyCode) or isSelectiveKeys keyString
        # We've made some deletion as part of a change operation already and
        # we're about to start the actual insert.  Mark this moment in the undo
        # stack.
        if jim.afterInsertSwitch
          if jim.mode.name is 'insert'
            jim.adaptor.markUndoPoint 'jim:insert:afterSwitch'
          jim.afterInsertSwitch = false

        if jim.mode.name is 'normal' and not jim.adaptor.emptySelection()
          # If a selection has been made with the mouse since the last
          # keypress in normal mode, switch to visual mode.
          jim.setMode 'visual'

        if keyString.length > 1 and not isSelectiveKeys keyString
          #TODO handle this better, we're dropping keypresses here
          keyString = keyString.charAt 0

        passKeypressThrough = jim.onKeypress keyString

        if not passKeypressThrough
          # Prevent Ace's default handling of the event.
          command: {exec: (->)}

  undoManager = new JimUndoManager()
  editor.session.setUndoManager undoManager

  adaptor = new Adaptor editor
  jim = new Jim adaptor

  # Initialize the editor element's `className`s.
  adaptor.onModeChange null, name: 'normal'

  # Return `jim` in case embedders wanna inspect its state or give it a high
  # five.
  jim
