define (require, exports, module) ->
  Jim = require 'jim/jim'

  jim = new Jim()

  atLineEnd = (editor, beyond) ->
    selectionLead = editor.selection.getSelectionLead()
    lineLength = editor.selection.doc.getLine(selectionLead.row).length
    selectionLead.column >= lineLength - (if beyond then 0 else 1)

  beyondLineEnd = (editor) -> atLineEnd(editor, true)

  # a variation on Ace's $moveSelection in selection.js
  moveSelection = (motionAction, env, args) ->
    if env.editor.selection.isEmpty()
      lead = env.editor.selection.selectionLead
      env.editor.selection.setSelectionAnchor lead.row, lead.column
    motionAction(env, args)

  ## these return a new regex each time so that we always get a fresh lastIndex
  # a string of non-whitespace characters
  WORDRegex = -> /\S+/g 
  # a string of word characters (i.e. [A-Za-z0-9_]) OR a string of non-whitespace non-word characters (i.e. special chars)
  wordRegex = -> /(\w+)|([^\w\s]+)/g

  # used to find the last instance of the above regexes (there may be a better way of doing this...)
  lastWORDRegex = ///#{WORDRegex().source}\s*$///
  lastWordRegex = ///(#{wordRegex().source})\s*$///

  navigateWordEnd = (editor, bigWORD, times) ->
    row = editor.selection.selectionLead.row
    column = editor.selection.selectionLead.column
    line = editor.selection.doc.getLine row
    rightOfCursor = line.substring column

    regex = if bigWORD then WORDRegex() else wordRegex()
    if column >= line.length - 1
      loop
        line = editor.selection.doc.getLine ++row
        firstMatchOnSubsequentLine = regex.exec line
        if firstMatchOnSubsequentLine
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1
          break
        else if row is editor.session.getDocument().getLength() - 1
          # there are no more non-blank characters, don't move the cursor
          return
    else
      thisMatch = regex.exec rightOfCursor
      if thisMatch.index > 1 or thisMatch[0].length > 1
        # go to the end of the WORD we're on top of
        # or the next WORD if we're in whitespace
        column += thisMatch[0].length + thisMatch.index - 1
      else
        # go to the end of the next WORD
        nextMatch = regex.exec rightOfCursor
        column += nextMatch.index + nextMatch[0].length - 1

    editor.moveCursorTo row, column
    if times > 1
      navigateWordEnd editor, bigWORD, times - 1

  navigateNextWord = (editor, bigWORD, times) ->
    row = editor.selection.selectionLead.row
    column = editor.selection.selectionLead.column
    line = editor.selection.doc.getLine row
    rightOfCursor = line.substring column

    regex = if bigWORD then WORDRegex() else wordRegex()

    thisMatch = regex.exec rightOfCursor
    if thisMatch?.index > 0
      # We've found the next beginning of the next match and it's not already
      # under the cursor. Go to it
      column += thisMatch.index
    else if not thisMatch or not nextMatch = regex.exec rightOfCursor
      # the next match isn't on this line, find it on the next
      line = editor.selection.doc.getLine ++row
      nextLineMatch = regex.exec line
      column = nextLineMatch?.index or 0
    else
      # we're on top of part of a WORD, go to the next one
      column += nextMatch.index

    editor.moveCursorTo row, column
    if times > 1
      navigateNextWord editor, bigWORD, times - 1

  navigateBackWord = (editor, bigWORD, times) ->
    row = editor.selection.selectionLead.row
    column = editor.selection.selectionLead.column
    line = editor.selection.doc.getLine row
    leftOfCursor = line.substring 0, column

    regex = if bigWORD then lastWORDRegex else lastWordRegex
    match = regex.exec leftOfCursor
    if match
      column = match.index
    else
      # there are no matches left of the cursor
      # go to the last word on the previous line
      loop
        # Vim skips lines that are only whitespace
        # (but not completely empty lines)
        line = editor.selection.doc.getLine --row
        break unless /^\s+$/.test line
      match = regex.exec line
      column = match?.index or 0

    editor.moveCursorTo row, column
    if times > 1
      navigateBackWord editor, bigWORD, times - 1


  actions =
    onEscape: (env, args) -> env.editor.clearSelection()

    undo: (env, args) ->
      undoManager = env.editor.session.getUndoManager()
      undoManager.jimUndo() for i in [1..(args?.times or 1)]
      env.editor.clearSelection()

    gotoLine: (env, args) -> env.editor.gotoLine args.lineNumber

    navigateUp:    (env, args) -> env.editor.navigateUp args.times
    navigateDown:  (env, args) -> env.editor.navigateDown args.times
    navigateLeft:  (env, args) ->
      times = args.times ? 1
      while times-- and env.editor.selection.selectionLead.getPosition().column > 0
        env.editor.selection.moveCursorLeft()
    navigateRight: (env, args) ->
      times = args.times ? 1
      while times-- and not atLineEnd(env.editor)
        env.editor.selection.moveCursorRight()

    navigateBackWord: (env, args) -> navigateBackWord env.editor, false, args.times ? 1
    navigateBackWORD: (env, args) -> navigateBackWord env.editor, true, args.times ? 1

    navigateNextWord: (env, args) -> navigateNextWord env.editor, false, args.times ? 1
    navigateNextWORD: (env, args) -> navigateNextWord env.editor, true, args.times ? 1

    navigateWordEnd: (env, args) -> navigateWordEnd env.editor, false, args.times ? 1
    navigateWORDEnd: (env, args) -> navigateWordEnd env.editor, true, args.times ? 1

    navigateFileEnd:   (env, args) -> env.editor.navigateFileEnd()
    navigateLineEnd:   (env, args) -> env.editor.navigateLineEnd()
    navigateLineStart: (env, args) -> env.editor.navigateLineStart()

    deleteLeft: (env, args) ->
      actions.selectLeft env, args
      actions.deleteSelection env, args unless env.editor.selection.isEmpty()
    deleteRight: (env, args) ->
      actions.deleteSelection env, args
    deleteToLineEnd: (env, args) ->
      env.editor.selection.selectLineEnd()
      actions.deleteSelection env, args
    deleteSelection: (env, args) ->
      if env.editor.selection.isEmpty() or not env.editor.selection.isBackwards()
        # the block cursor should be part of the selection
        env.editor.selection.selectRight() unless beyondLineEnd(env.editor)
      jim.registers[args.register] = env.editor.getCopyText()
      env.editor.session.remove env.editor.getSelectionRange()
      env.editor.clearSelection()

    paste: (env, args) ->
      #TODO use args.times, p with no buffer shouldn't move cursor
      actions.navigateRight(env, args)
      actions.pasteBefore(env, args)
    pasteBefore: (env, args) ->
      #TODO use args.times
      text = jim.registers[args.register]
      env.editor.insert text if text

    selectUp: (env, args) ->
      env.editor.selection.selectUp() for i in [1..(args.times or 1)]
    selectDown: (env, args) ->
      env.editor.selection.selectDown() for i in [1..(args.times or 1)]
    selectLeft: (env, args) -> moveSelection actions.navigateLeft, env, args
    selectRight: (env, args) -> moveSelection actions.navigateRight, env, args
    selectLine: (env, args) ->
      env.editor.selection.selectLine()

    selectBackWORD: (env, args) -> moveSelection actions.navigateBackWORD, env, args
    selectWORDEnd:  (env, args) -> moveSelection actions.navigateWORDEnd, env, args
    selectNextWORD: (env, args) -> moveSelection actions.navigateNextWORD, env, args

    selectBackWord: (env, args) -> moveSelection actions.navigateBackWord, env, args
    selectWordEnd:  (env, args) -> moveSelection actions.navigateWordEnd, env, args
    selectNextWord: (env, args) -> moveSelection actions.navigateNextWord, env, args


    yankSelection: (env, args) ->
      jim.registers[args.register] = env.editor.getCopyText()
      if env.editor.selection.isBackwards()
        env.editor.clearSelection()
      else
        {start} = env.editor.getSelectionRange()
        env.editor.moveCursorTo start.row, start.column


  isntCharacterKey = (hashId, key) ->
    hashId isnt 0 and (key is "" or key is String.fromCharCode 0)

  adaptor =
    handleKeyboard: (data, hashId, key) ->
      noop = ->
      if key is "esc"
        jim.onEscape()
        result = action: 'onEscape'
      else if isntCharacterKey(hashId, key)
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
          exec: actions[result.action] or noop
        args: result.args

  exports.adaptor = adaptor
  # yuck?
  exports.jim = jim

  return
