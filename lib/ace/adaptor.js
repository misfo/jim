(function() {
  define(function(require, exports, module) {
    var Jim, WORDRegex, actions, adaptor, isntCharacterKey, jim, lastWORDRegex, lastWordRegex, navigateBackWord, navigateNextWord, navigateWordEnd, wordRegex;
    Jim = require('jim/jim');
    jim = new Jim();
    WORDRegex = function() {
      return /\S+/g;
    };
    wordRegex = function() {
      return /(\w+)|([^\w\s]+)/g;
    };
    lastWORDRegex = RegExp("" + (WORDRegex().source) + "\\s*$");
    lastWordRegex = RegExp("(" + (wordRegex().source) + ")\\s*$");
    navigateWordEnd = function(editor, bigWORD, times) {
      var column, firstMatchOnSubsequentLine, line, nextMatch, regex, rightOfCursor, row, thisMatch;
      row = editor.selection.selectionLead.row;
      column = editor.selection.selectionLead.column;
      line = editor.selection.doc.getLine(row);
      rightOfCursor = line.substring(column);
      regex = bigWORD ? WORDRegex() : wordRegex();
      if (column >= line.length - 1) {
        while (true) {
          line = editor.selection.doc.getLine(++row);
          firstMatchOnSubsequentLine = regex.exec(line);
          if (firstMatchOnSubsequentLine) {
            column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1;
            break;
          } else if (row === editor.session.getDocument().getLength() - 1) {
            return;
          }
        }
      } else {
        thisMatch = regex.exec(rightOfCursor);
        if (thisMatch.index > 1 || thisMatch[0].length > 1) {
          column += thisMatch[0].length + thisMatch.index - 1;
        } else {
          nextMatch = regex.exec(rightOfCursor);
          column += nextMatch.index + nextMatch[0].length - 1;
        }
      }
      editor.moveCursorTo(row, column);
      if (times > 1) {
        return navigateWordEnd(editor, bigWORD, times - 1);
      }
    };
    navigateNextWord = function(editor, bigWORD, times) {
      var column, line, nextLineMatch, nextMatch, regex, rightOfCursor, row, thisMatch;
      row = editor.selection.selectionLead.row;
      column = editor.selection.selectionLead.column;
      line = editor.selection.doc.getLine(row);
      rightOfCursor = line.substring(column);
      regex = bigWORD ? WORDRegex() : wordRegex();
      thisMatch = regex.exec(rightOfCursor);
      if ((thisMatch != null ? thisMatch.index : void 0) > 0) {
        column += thisMatch.index;
      } else if (!thisMatch || !(nextMatch = regex.exec(rightOfCursor))) {
        line = editor.selection.doc.getLine(++row);
        nextLineMatch = regex.exec(line);
        column = (nextLineMatch != null ? nextLineMatch.index : void 0) || 0;
      } else {
        column += nextMatch.index;
      }
      editor.moveCursorTo(row, column);
      if (times > 1) {
        return navigateNextWord(editor, bigWORD, times - 1);
      }
    };
    navigateBackWord = function(editor, bigWORD, times) {
      var column, leftOfCursor, line, match, regex, row;
      row = editor.selection.selectionLead.row;
      column = editor.selection.selectionLead.column;
      line = editor.selection.doc.getLine(row);
      leftOfCursor = line.substring(0, column);
      regex = bigWORD ? lastWORDRegex : lastWordRegex;
      match = regex.exec(leftOfCursor);
      if (match) {
        column = match.index;
      } else {
        while (true) {
          line = editor.selection.doc.getLine(--row);
          if (!/^\s+$/.test(line)) {
            break;
          }
        }
        match = regex.exec(line);
        column = (match != null ? match.index : void 0) || 0;
      }
      editor.moveCursorTo(row, column);
      if (times > 1) {
        return navigateBackWord(editor, bigWORD, times - 1);
      }
    };
    actions = {
      onEscape: function(env, args) {
        return env.editor.clearSelection();
      },
      undo: function(env, args) {
        var i, undoManager, _ref;
        undoManager = env.editor.session.getUndoManager();
        for (i = 1, _ref = (args != null ? args.times : void 0) || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          undoManager.jimUndo();
        }
        return env.editor.clearSelection();
      },
      gotoLine: function(env, args) {
        return env.editor.gotoLine(args.lineNumber);
      },
      navigateUp: function(env, args) {
        return env.editor.navigateUp(args.times);
      },
      navigateDown: function(env, args) {
        return env.editor.navigateDown(args.times);
      },
      navigateLeft: function(env, args) {
        return env.editor.navigateLeft(args.times);
      },
      navigateRight: function(env, args) {
        return env.editor.navigateRight(args.times);
      },
      navigateBackWord: function(env, args) {
        var _ref;
        return navigateBackWord(env.editor, false, (_ref = args.times) != null ? _ref : 1);
      },
      navigateBackWORD: function(env, args) {
        var _ref;
        return navigateBackWord(env.editor, true, (_ref = args.times) != null ? _ref : 1);
      },
      navigateNextWord: function(env, args) {
        var _ref;
        return navigateNextWord(env.editor, false, (_ref = args.times) != null ? _ref : 1);
      },
      navigateNextWORD: function(env, args) {
        var _ref;
        return navigateNextWord(env.editor, true, (_ref = args.times) != null ? _ref : 1);
      },
      navigateWordEnd: function(env, args) {
        var _ref;
        return navigateWordEnd(env.editor, false, (_ref = args.times) != null ? _ref : 1);
      },
      navigateWORDEnd: function(env, args) {
        var _ref;
        return navigateWordEnd(env.editor, true, (_ref = args.times) != null ? _ref : 1);
      },
      navigateFileEnd: function(env, args) {
        return env.editor.navigateFileEnd();
      },
      navigateLineEnd: function(env, args) {
        return env.editor.navigateLineEnd();
      },
      navigateLineStart: function(env, args) {
        return env.editor.navigateLineStart();
      },
      deleteLeft: function(env, args) {
        actions.selectLeft(env, args);
        return actions.deleteSelection(env, args);
      },
      deleteRight: function(env, args) {
        actions.selectRight(env, args);
        return actions.deleteSelection(env, args);
      },
      deleteToLineEnd: function(env, args) {
        env.editor.selection.selectLineEnd();
        return actions.deleteSelection(env, args);
      },
      deleteSelection: function(env, args) {
        jim.registers[args.register] = env.editor.getCopyText();
        return env.editor.session.remove(env.editor.getSelectionRange());
      },
      paste: function(env, args) {
        actions.navigateRight(env, args);
        return actions.pasteBefore(env, args);
      },
      pasteBefore: function(env, args) {
        var text;
        text = jim.registers[args.register];
        if (text) {
          return env.editor.insert(text);
        }
      },
      selectUp: function(env, args) {
        var i, _ref, _results;
        _results = [];
        for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _results.push(env.editor.selection.selectUp());
        }
        return _results;
      },
      selectDown: function(env, args) {
        var i, _ref, _results;
        _results = [];
        for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _results.push(env.editor.selection.selectDown());
        }
        return _results;
      },
      selectLeft: function(env, args) {
        var i, _ref, _results;
        _results = [];
        for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _results.push(env.editor.selection.selectLeft());
        }
        return _results;
      },
      selectRight: function(env, args) {
        var i, _ref, _results;
        _results = [];
        for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _results.push(env.editor.selection.selectRight());
        }
        return _results;
      },
      selectLine: function(env, args) {
        return env.editor.selection.selectLine();
      },
      selectBackWORD: function(env, args) {
        return actions.navigateBackWORD(env, args);
      },
      selectWORDEnd: function(env, args) {
        return actions.navigateWORDEnd(env, args);
      },
      selectNextWORD: function(env, args) {
        return actions.navigateNextWORD(env, args);
      },
      yankSelection: function(env, args) {
        var start;
        jim.registers[args.register] = env.editor.getCopyText();
        if (env.editor.selection.isBackwards()) {
          return env.editor.clearSelection();
        } else {
          start = env.editor.getSelectionRange().start;
          return env.editor.navigateTo(start.row, start.column);
        }
      }
    };
    isntCharacterKey = function(hashId, key) {
      return hashId !== 0 && (key === "" || key === String.fromCharCode(0));
    };
    adaptor = {
      handleKeyboard: function(data, hashId, key) {
        var noop, result;
        noop = function() {};
        if (key === "esc") {
          jim.onEscape();
          result = {
            action: 'onEscape'
          };
        } else if (isntCharacterKey(hashId, key)) {
          return;
        } else if (key.length > 1) {
          key = key.charAt(0);
        }
        if (hashId & 4 && key.match(/^[a-z]$/)) {
          key = key.toUpperCase();
        }
                if (result != null) {
          result;
        } else {
          result = jim.onKeypress(key);
        };
        if (result != null) {
          if (result.changeToMode != null) {
            jim.setMode(result.changeToMode);
          }
          return {
            command: {
              exec: actions[result.action] || noop
            },
            args: result.args
          };
        }
      }
    };
    exports.adaptor = adaptor;
    exports.jim = jim;
  });
}).call(this);
