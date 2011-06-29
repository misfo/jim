define (require, exports, module) ->
  {adaptor, jim} = require 'jim/ace/adaptor'
  JimUndoManager = require 'jim/ace/jim_undo_manager'

  require('pilot/dom').importCssString """
    .jim-normal-mode div.ace_cursor {
      border: 0;
      background-color: #91FF00;
      opacity: 0.5;
    }
  """

  startup = (data, reason) ->
    {editor} = data.env
    if not editor
      setTimeout startup, 0, data, reason
      return
    console.log 'executing startup'
    editor.setKeyboardHandler adaptor
    undoManager = new JimUndoManager()
    editor.session.setUndoManager undoManager

    # this is executed before the action is
    jim.onModeChange = (prevMode) ->
      if @modeName is 'normal'
        editor.setStyle 'jim-normal-mode'
      else
        editor.unsetStyle 'jim-normal-mode'

      if @modeName is 'insert'
        undoManager.markInsertStartPoint(editor.session)
      else if prevMode is 'insert'
        undoManager.markInsertEndPoint(editor.session)

    jim.onModeChange()
  exports.startup = startup

  return
