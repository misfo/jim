jim = new Jim()

aceAdaptor =
  onEscape: (env, args) -> env.editor.clearSelection()

  undo: (env, args) ->
    undoManager = env.editor.session.getUndoManager()
    console.log 'undoManager', undoManager
    undoManager.undo(true) for i in [1..(args?.times or 1)]

  gotoLine: (env, args) -> env.editor.gotoLine args.lineNumber

  navigateUp:    (env, args) -> env.editor.navigateUp args.times
  navigateDown:  (env, args) -> env.editor.navigateDown args.times
  navigateLeft:  (env, args) -> env.editor.navigateLeft args.times
  navigateRight: (env, args) -> env.editor.navigateRight args.times

  navigateBackWORD: (env, args) ->
    row = env.editor.selection.selectionLead.row
    column = env.editor.selection.selectionLead.column
    line = env.editor.selection.doc.getLine row
    leftOfCursor = line.substring 0, column

    lastWORD = /\S+\s*$/
    match = lastWORD.exec leftOfCursor
    if match
      column = match.index
    else
      # there are no WORDs left of the cursor
      # go to the last word on the previous line
      loop
        # Vim skips lines that are only whitespace
        # (but not completely empty lines)
        line = env.editor.selection.doc.getLine --row
        break unless /^\s+$/.test line
      match = lastWORD.exec line
      column = match?.index or 0

    env.editor.moveCursorTo row, column
    if args?.times > 1
      args.times--
      aceAdaptor.navigateBackWORD env, args

  navigateNextWORD: (env, args) ->
    row = env.editor.selection.selectionLead.row
    column = env.editor.selection.selectionLead.column
    line = env.editor.selection.doc.getLine row
    rightOfCursor = line.substring column

    bigWORD = /\S+/g

    thisMatch = bigWORD.exec rightOfCursor
    if thisMatch?.index > 0
      # we've found the next beginning of a WORD, go to it
      column += thisMatch.index
    else if not thisMatch or not nextMatch = bigWORD.exec rightOfCursor
      # the next WORD isn't on this line, find it on the next
      line = env.editor.selection.doc.getLine ++row
      nextLineMatch = bigWORD.exec line
      column = nextLineMatch?.index or 0
    else
      # we're on top of part of a WORD, go to the next one
      column += nextMatch.index

    env.editor.moveCursorTo row, column
    if args?.times > 1
      args.times--
      aceAdaptor.navigateNextWORD env, args

  navigateWORDEnd: (env, args) ->
    row = env.editor.selection.selectionLead.row
    column = env.editor.selection.selectionLead.column
    line = env.editor.selection.doc.getLine row
    rightOfCursor = line.substring column

    bigWORD = /\S+/g
    if column >= line.length - 1
      loop
        line = env.editor.selection.doc.getLine ++row
        firstMatchOnSubsequentLine = bigWORD.exec line
        if firstMatchOnSubsequentLine
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1
          break
        else if row is env.editor.session.getDocument().getLength() - 1
          # there are no more non-blank characters, don't move the cursor
          return
    else
      thisMatch = bigWORD.exec rightOfCursor
      if thisMatch.index > 1 or thisMatch[0].length > 1
        # go to the end of the WORD we're on top of
        # or the next WORD if we're in whitespace
        column += thisMatch[0].length + thisMatch.index - 1
      else
        # go to the end of the next WORD
        nextMatch = bigWORD.exec rightOfCursor
        column += nextMatch.index + nextMatch[0].length - 1

    env.editor.moveCursorTo row, column
    if args?.times > 1
      args.times--
      aceAdaptor.navigateWORDEnd env, args

  navigateFileEnd:   (env, args) -> env.editor.navigateFileEnd()
  navigateLineEnd:   (env, args) -> env.editor.navigateLineEnd()
  navigateLineStart: (env, args) -> env.editor.navigateLineStart()

  deleteLeft: (env, args) ->
    aceAdaptor.selectLeft env, args
    aceAdaptor.deleteSelection env, args
  deleteRight: (env, args) ->
    aceAdaptor.selectRight env, args
    aceAdaptor.deleteSelection env, args
  deleteToLineEnd: (env, args) ->
    env.editor.selection.selectLineEnd()
    aceAdaptor.deleteSelection env, args
  deleteSelection: (env, args) ->
    jim.registers[args.register] = env.editor.getCopyText()
    env.editor.session.remove env.editor.getSelectionRange()

  paste: (env, args) ->
    #TODO use args.times, p with no buffer shouldn't move cursor
    aceAdaptor.navigateRight(env, args)
    aceAdaptor.pasteBefore(env, args)
  pasteBefore: (env, args) ->
    #TODO use args.times
    text = jim.registers[args.register]
    env.editor.insert text if text

  selectUp: (env, args) ->
    env.editor.selection.selectUp() for i in [1..(args.times or 1)]
  selectDown: (env, args) ->
    env.editor.selection.selectDown() for i in [1..(args.times or 1)]
  selectLeft: (env, args) ->
    env.editor.selection.selectLeft() for i in [1..(args.times or 1)]
  selectRight: (env, args) ->
    env.editor.selection.selectRight() for i in [1..(args.times or 1)]
  selectLine: (env, args) ->
    env.editor.selection.selectLine()

  selectBackWORD: (env, args) -> aceAdaptor.navigateBackWORD(env, args)
  selectWORDEnd:  (env, args) -> aceAdaptor.navigateWORDEnd(env, args)
  selectNextWORD: (env, args) -> aceAdaptor.navigateNextWORD(env, args)


  yankSelection: (env, args) ->
    jim.registers[args.register] = env.editor.getCopyText()
    if env.editor.selection.isBackwards()
      env.editor.clearSelection()
    else
      {start} = env.editor.getSelectionRange()
      env.editor.navigateTo start.row, start.column


  isntCharacterKey: (hashId, key) ->
    hashId isnt 0 and (key is "" or key is String.fromCharCode 0)

  handleKeyboard: (data, hashId, key) ->
    noop = ->
    if key is "esc"
      jim.onEscape()
      result = action: 'onEscape'
    else if @isntCharacterKey(hashId, key)
      # do nothing if it's just a modifier key
      return
    else if key.length > 1
      #TODO handle this better, we're dropping keypresses here
      key = key.charAt 0

    key = key.toUpperCase() if hashId & 4 and key.match /^[a-z]$/
    result ?= jim.onKeypress key
    if result?
      jim.setMode result.changeToMode if result.changeToMode?
      command:
        exec: this[result.action] or noop
      args: result.args

define (require, exports, module) ->
  require('pilot/dom').importCssString """
    .jim-normal-mode div.ace_cursor {
      border: 0;
      background-color: #91FF00;
      opacity: 0.5;
    }
  """

  console.log 'defining startup'
  startup = (data, reason) ->
    {editor} = data.env
    if not editor
      setTimeout startup, 0, data, reason
      return
    console.log 'executing startup'
    editor.setKeyboardHandler aceAdaptor

    jim.onModeChange = (prevMode) ->
      if @modeName is 'normal'
        editor.setStyle 'jim-normal-mode'
      else
        editor.unsetStyle 'jim-normal-mode'

    jim.onModeChange()
  exports.startup = startup

  exports.Jim = Jim
  return
