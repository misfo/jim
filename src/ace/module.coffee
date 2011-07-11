define (require, exports, module) ->
  Jim            = require 'jim/jim'
  Adaptor        = require 'jim/ace/adaptor'
  JimUndoManager = require 'jim/ace/jim_undo_manager'

  require('pilot/dom').importCssString """
    .jim-normal-mode div.ace_cursor, .jim-visual-mode div.ace_cursor {
      border: 0;
      background-color: #91FF00;
      opacity: 0.5;
    }
  """

  isCharacterKey = (hashId, keyCode) -> hashId is 0 and keyCode is 0

  startup = (data, reason) ->
    {editor} = data.env
    if not editor
      setTimeout startup, 0, data, reason
      return

    editor.setKeyboardHandler
      handleKeyboard: (data, hashId, key, keyCode) ->
        if keyCode is 27 # esc
          jim.onEscape()
        else if isCharacterKey(hashId, keyCode)
          if key.length > 1
            #TODO handle this better, we're dropping keypresses here
            key = key.charAt 0

          passKeypressThrough = jim.onKeypress key

          if not passKeypressThrough
            # this will stop the event
            command: {exec: (->)}

    undoManager = new JimUndoManager()
    editor.session.setUndoManager undoManager

    adaptor = new Adaptor editor
    jim = new Jim adaptor

    # this is executed before the action is
    jim.onModeChange = (prevMode) ->
      for mode in ['insert', 'normal', 'visual']
        if ///^#{mode}///.test @modeName
          editor.setStyle "jim-#{mode}-mode"
        else
          editor.unsetStyle "jim-#{mode}-mode"

      if @modeName is 'insert'
        undoManager.markInsertStartPoint(editor.session)
      else if prevMode is 'insert'
        undoManager.markInsertEndPoint(editor.session)

    jim.onModeChange()

    jim
  exports.startup = startup

  return
