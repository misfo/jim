(function() {
  define(function(require, exports, module) {
    var Adaptor, Jim, JimUndoManager, isCharacterKey, startup;
    Jim = require('jim/jim');
    Adaptor = require('jim/ace/adaptor');
    JimUndoManager = require('jim/ace/jim_undo_manager');
    require('pilot/dom').importCssString(".jim-normal-mode div.ace_cursor, .jim-visual-mode div.ace_cursor {\n  border: 0;\n  background-color: #91FF00;\n  opacity: 0.5;\n}");
    isCharacterKey = function(hashId, keyCode) {
      return hashId === 0 && keyCode === 0;
    };
    startup = function(data, reason) {
      var adaptor, editor, jim, undoManager;
      editor = data.env.editor;
      if (!editor) {
        setTimeout(startup, 0, data, reason);
        return;
      }
      editor.setKeyboardHandler({
        handleKeyboard: function(data, hashId, key, keyCode) {
          var passKeypressThrough;
          if (keyCode === 27) {
            return jim.onEscape();
          } else if (isCharacterKey(hashId, keyCode)) {
            if (key.length > 1) {
              key = key.charAt(0);
            }
            passKeypressThrough = jim.onKeypress(key);
            if (!passKeypressThrough) {
              return {
                command: {
                  exec: (function() {})
                }
              };
            }
          }
        }
      });
      undoManager = new JimUndoManager();
      editor.session.setUndoManager(undoManager);
      adaptor = new Adaptor(editor);
      jim = new Jim(adaptor);
      jim.onModeChange = function(prevMode) {
        var mode, _i, _len, _ref;
        _ref = ['insert', 'normal', 'visual'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          mode = _ref[_i];
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
      jim.onModeChange();
      return jim;
    };
    exports.startup = startup;
  });
}).call(this);
