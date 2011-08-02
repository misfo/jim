define (require, exports, module) ->
  Jim            = require 'jim/jim'
  Adaptor        = require 'jim/ace/adaptor'
  JimUndoManager = require 'jim/ace/jim_undo_manager'

  require('pilot/dom').importCssString """
    .jim-normal-mode div.ace_cursor
    , .jim-visual-characterwise-mode div.ace_cursor
    , .jim-visual-linewise-mode div.ace_cursor {
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

  startup = (data, reason) ->
    {editor} = data.env
    if not editor
      setTimeout startup, 0, data, reason
      return

    editor.setKeyboardHandler
      handleKeyboard: (data, hashId, keyString, keyCode) ->
        if keyCode is 27 # esc
          jim.onEscape()
        else if isCharacterKey hashId, keyCode
          if jim.modeName is 'normal' and not jim.adaptor.emptySelection()
            # if a selection has been made with the mouse since the last
            # keypress in normal mode, switch to visual mode
            jim.setMode 'visual:characterwise'

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

    # this is executed before the action is
    jim.onModeChange = (prevMode) ->
      for mode in ['insert', 'normal', 'visual:characterwise', 'visual:linewise']
        className = "jim-#{mode.replace(/\W/, '-')}-mode"
        if mode is @modeName
          editor.setStyle className
        else
          editor.unsetStyle className

      if @modeName is 'insert'
        undoManager.markUndoPoint editor.session, 'jimInsertStart'
      else if prevMode is 'insert'
        undoManager.markUndoPoint editor.session, 'jimInsertEnd'

      if @modeName is 'replace'
        undoManager.markUndoPoint editor.session, 'jimReplaceStart'
      else if prevMode is 'replace'
        undoManager.markUndoPoint editor.session, 'jimReplaceEnd'

    jim.onModeChange()

    jim
  exports.startup = startup

  return
