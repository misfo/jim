(function() {
  define(function(require, exports, module) {
    var JimUndoManager, adaptor, jim, startup, _ref;
    _ref = require('jim/ace/adaptor'), adaptor = _ref.adaptor, jim = _ref.jim;
    JimUndoManager = require('jim/ace/jim_undo_manager');
    require('pilot/dom').importCssString(".jim-normal-mode div.ace_cursor {\n  border: 0;\n  background-color: #91FF00;\n  opacity: 0.5;\n}");
    startup = function(data, reason) {
      var editor, undoManager;
      editor = data.env.editor;
      if (!editor) {
        setTimeout(startup, 0, data, reason);
        return;
      }
      console.log('executing startup');
      editor.setKeyboardHandler(adaptor);
      undoManager = new JimUndoManager();
      editor.session.setUndoManager(undoManager);
      jim.onModeChange = function(prevMode) {
        if (this.modeName === 'normal') {
          editor.setStyle('jim-normal-mode');
        } else {
          editor.unsetStyle('jim-normal-mode');
        }
        if (this.modeName === 'insert') {
          return undoManager.markInsertStartPoint(editor.session);
        } else if (prevMode === 'insert') {
          return undoManager.markInsertEndPoint(editor.session);
        }
      };
      return jim.onModeChange();
    };
    exports.startup = startup;
  });
}).call(this);
