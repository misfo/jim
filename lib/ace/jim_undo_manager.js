(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  define(function(require, exports, module) {
    var JimUndoManager, UndoManager;
    UndoManager = require('ace/undomanager').UndoManager;
    return JimUndoManager = (function() {
      var InsertedText;
      __extends(JimUndoManager, UndoManager);
      function JimUndoManager() {
        JimUndoManager.__super__.constructor.apply(this, arguments);
      }
      JimUndoManager.prototype.undo = function() {
        if (this.isJimMark(this.lastOnUndoStack())) {
          this.silentUndo();
        }
        return JimUndoManager.__super__.undo.apply(this, arguments);
      };
      JimUndoManager.prototype.isJimMark = function(entry) {
        return typeof entry === 'string' && /^jim:/.test(entry);
      };
      JimUndoManager.prototype.lastOnUndoStack = function() {
        return this.$undoStack[this.$undoStack.length - 1];
      };
      JimUndoManager.prototype.markUndoPoint = function(doc, markName) {
        return this.execute({
          args: [markName, doc]
        });
      };
      JimUndoManager.prototype.silentUndo = function() {
        var deltas;
        deltas = this.$undoStack.pop();
        if (deltas) {
          return this.$redoStack.push(deltas);
        }
      };
      JimUndoManager.prototype.matchingMark = {
        'jim:insert:end': 'jim:insert:start',
        'jim:replace:end': 'jim:replace:start'
      };
      JimUndoManager.prototype.jimUndo = function() {
        var i, lastDeltasOnStack, startIndex, startMark, _ref;
        lastDeltasOnStack = this.lastOnUndoStack();
        if (typeof lastDeltasOnStack === 'string' && (startMark = this.matchingMark[lastDeltasOnStack])) {
          startIndex = null;
          for (i = _ref = this.$undoStack.length - 1; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
            if (this.$undoStack[i] === startMark) {
              startIndex = i;
              break;
            }
          }
          if (!(startIndex != null)) {
            console.log("found a \"" + lastDeltasOnStack + "\" on the undoStack, but no \"" + startMark + "\"");
            return;
          }
          this.silentUndo();
          while (this.$undoStack.length > startIndex + 1) {
            if (this.isJimMark(this.lastOnUndoStack())) {
              this.silentUndo();
            } else {
              this.undo();
            }
          }
          return this.silentUndo();
        } else {
          return this.undo();
        }
      };
      InsertedText = (function() {
        InsertedText.fromUndoStack = function(undoStack) {
          var continueLooping, i, insertedText, j, k, _ref, _ref2, _ref3, _results;
          insertedText = new InsertedText;
          _results = [];
          for (i = _ref = undoStack.length - 2; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
            if (typeof undoStack[i] === 'string') {
              insertedText.addBookmark(undoStack[i]);
              return insertedText;
            }
            for (j = _ref2 = undoStack[i].length - 1; _ref2 <= 0 ? j <= 0 : j >= 0; _ref2 <= 0 ? j++ : j--) {
              for (k = _ref3 = undoStack[i][j].deltas.length - 1; _ref3 <= 0 ? k <= 0 : k >= 0; _ref3 <= 0 ? k++ : k--) {
                continueLooping = insertedText.addDelta(undoStack[i][j].deltas[k]);
                if (!continueLooping) {
                  return insertedText;
                }
              }
            }
          }
          return _results;
        };
        function InsertedText() {
          this.contiguous = false;
          this.textParts = [];
        }
        InsertedText.prototype.addBookmark = function(bookmark) {
          if (bookmark === 'jim:insert:afterSwitch') {
            return this.contiguous = true;
          }
        };
        InsertedText.prototype.isContiguousInsert = function(delta) {
          var _ref;
          if (delta.action !== 'insertText') {
            return false;
          }
          return !this.lastStartPosition || (_ref = delta.range).isEnd.apply(_ref, this.lastStartPosition);
        };
        InsertedText.prototype.addDelta = function(delta) {
          if (this.isContiguousInsert(delta)) {
            this.textParts.unshift(delta.text);
            this.lastStartPosition = [delta.range.start.row, delta.range.start.column];
            return true;
          }
        };
        InsertedText.prototype.text = function() {
          return this.textParts.join('');
        };
        return InsertedText;
      })();
      JimUndoManager.prototype.lastInsert = function() {
        var insertedText;
        if (this.lastOnUndoStack() !== 'jim:insert:end') {
          return {
            string: '',
            contiguous: false
          };
        }
        insertedText = InsertedText.fromUndoStack(this.$undoStack);
        return {
          string: insertedText.text(),
          contiguous: insertedText.contiguous
        };
      };
      return JimUndoManager;
    }).call(this);
  });
}).call(this);
