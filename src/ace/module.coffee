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

  isntCharacterKey = (hashId, key) ->
    hashId isnt 0 and (key is "" or key is String.fromCharCode 0)

  startup = (data, reason) ->
    {editor} = data.env
    if not editor
      setTimeout startup, 0, data, reason
      return

    editor.setKeyboardHandler
      handleKeyboard: (data, hashId, key) ->
        console.log 'handleKeyboard', data, hashId, key
        if key is "esc"
          jim.onEscape()
          return
        else if isntCharacterKey(hashId, key)
          # do nothing if it's just a modifier key
          return
        else if key.length > 1
          #TODO handle this better, we're dropping keypresses here
          key = key.charAt 0

        key = key.toUpperCase() if hashId & 4 and key.match /^[a-z]$/
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
