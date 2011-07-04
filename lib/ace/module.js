(function() {
  define(function(require, exports, module) {
    var JimUndoManager, adaptor, jim, startup, _ref;
    _ref = require('jim/ace/adaptor'), adaptor = _ref.adaptor, jim = _ref.jim;
    JimUndoManager = require('jim/ace/jim_undo_manager');
    require('pilot/dom').importCssString(".jim-normal-mode div.ace_cursor, .jim-visual-mode div.ace_cursor {\n  border: 0;\n  background-color: #91FF00;\n  opacity: 0.5;\n}");
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
        var mode, _i, _len, _ref2;
        _ref2 = ['insert', 'normal', 'visual'];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          mode = _ref2[_i];
          if (RegExp("^" + mode).test(this.modeName)) {
            editor.setStyle("jim-" + mode + "-mode");
          } else {
            editor.unsetStyle("jim-" + mode + "-mode");
          }
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
