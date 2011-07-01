(function() {
  define(function(require, exports, module) {
    var Jim, actions, adaptor, isntCharacterKey, jim;
    Jim = require('jim/jim');
    jim = new Jim();
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
      navigateBackWORD: function(env, args) {
        var column, lastWORD, leftOfCursor, line, match, row;
        row = env.editor.selection.selectionLead.row;
        column = env.editor.selection.selectionLead.column;
        line = env.editor.selection.doc.getLine(row);
        leftOfCursor = line.substring(0, column);
        lastWORD = /\S+\s*$/;
        match = lastWORD.exec(leftOfCursor);
        if (match) {
          column = match.index;
        } else {
          while (true) {
            line = env.editor.selection.doc.getLine(--row);
            if (!/^\s+$/.test(line)) {
              break;
            }
          }
          match = lastWORD.exec(line);
          column = (match != null ? match.index : void 0) || 0;
        }
        env.editor.moveCursorTo(row, column);
        if ((args != null ? args.times : void 0) > 1) {
          args.times--;
          return actions.navigateBackWORD(env, args);
        }
      },
      navigateNextWORD: function(env, args) {
        var bigWORD, column, line, nextLineMatch, nextMatch, rightOfCursor, row, thisMatch;
        row = env.editor.selection.selectionLead.row;
        column = env.editor.selection.selectionLead.column;
        line = env.editor.selection.doc.getLine(row);
        rightOfCursor = line.substring(column);
        bigWORD = /\S+/g;
        thisMatch = bigWORD.exec(rightOfCursor);
        if ((thisMatch != null ? thisMatch.index : void 0) > 0) {
          column += thisMatch.index;
        } else if (!thisMatch || !(nextMatch = bigWORD.exec(rightOfCursor))) {
          line = env.editor.selection.doc.getLine(++row);
          nextLineMatch = bigWORD.exec(line);
          column = (nextLineMatch != null ? nextLineMatch.index : void 0) || 0;
        } else {
          column += nextMatch.index;
        }
        env.editor.moveCursorTo(row, column);
        if ((args != null ? args.times : void 0) > 1) {
          args.times--;
          return actions.navigateNextWORD(env, args);
        }
      },
      navigateWORDEnd: function(env, args) {
        var bigWORD, column, firstMatchOnSubsequentLine, line, nextMatch, rightOfCursor, row, thisMatch;
        row = env.editor.selection.selectionLead.row;
        column = env.editor.selection.selectionLead.column;
        line = env.editor.selection.doc.getLine(row);
        rightOfCursor = line.substring(column);
        bigWORD = /\S+/g;
        if (column >= line.length - 1) {
          while (true) {
            line = env.editor.selection.doc.getLine(++row);
            firstMatchOnSubsequentLine = bigWORD.exec(line);
            if (firstMatchOnSubsequentLine) {
              column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1;
              break;
            } else if (row === env.editor.session.getDocument().getLength() - 1) {
              return;
            }
          }
        } else {
          thisMatch = bigWORD.exec(rightOfCursor);
          if (thisMatch.index > 1 || thisMatch[0].length > 1) {
            column += thisMatch[0].length + thisMatch.index - 1;
          } else {
            nextMatch = bigWORD.exec(rightOfCursor);
            column += nextMatch.index + nextMatch[0].length - 1;
          }
        }
        env.editor.moveCursorTo(row, column);
        if ((args != null ? args.times : void 0) > 1) {
          args.times--;
          return actions.navigateWORDEnd(env, args);
        }
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
