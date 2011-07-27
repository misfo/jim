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
      __extends(JimUndoManager, UndoManager);
      function JimUndoManager() {
        JimUndoManager.__super__.constructor.apply(this, arguments);
      }
      JimUndoManager.prototype.undo = function(dontSelect) {
        if (this.isJimMark(this.lastOnUndoStack())) {
          this.silentUndo();
        }
        return JimUndoManager.__super__.undo.call(this, dontSelect);
      };
      JimUndoManager.prototype.isJimMark = function(entry) {
        return typeof entry === 'string' && (matchingMark[entry] != null);
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
        jimInsertEnd: 'jimInsertStart',
        jimReplaceEnd: 'jimReplaceStart'
      };
      JimUndoManager.prototype.jimUndo = function() {
        var i, lastDeltasOnStack, startIndex, startMark, _ref, _ref2;
        lastDeltasOnStack = this.lastOnUndoStack();
        if (typeof lastDeltasOnStack === 'string' && (startMark = this.matchingMark[lastDeltasOnStack])) {
          startIndex = null;
          for (i = _ref = this.$undoStack.length - 1; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
            if (this.$undoStack[i] === startMark) {
              startIndex = i;
              break;
            }
          }
          if (startIndex != null) {
            this.silentUndo();
            for (i = _ref2 = this.$undoStack.length - 1; _ref2 <= startIndex ? i < startIndex : i > startIndex; _ref2 <= startIndex ? i++ : i--) {
              this.undo();
            }
            return this.silentUndo();
          } else {
            return console.log("found a \"" + lastDeltasOnStack + "\" on the undoStack, but no \"" + startMark + "\"");
          }
        } else {
          return this.undo();
        }
      };
      JimUndoManager.prototype.lastRepeatableInsertString = function() {
        var delta, i, isContiguousInsert, j, k, startPosition, stringParts, _ref, _ref2, _ref3;
        if (this.lastOnUndoStack() !== 'jimInsertEnd') {
          return '';
        }
        console.log('@$undoStack', this.$undoStack);
        startPosition = null;
        stringParts = [];
        isContiguousInsert = function(delta) {
          var _ref;
          if (delta.action !== 'insertText') {
            return false;
          }
          return !startPosition || (_ref = delta.range).isEnd.apply(_ref, startPosition);
        };
        for (i = _ref = this.$undoStack.length - 2; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
          if (typeof this.$undoStack[i] === 'string') {
            break;
          }
          for (j = _ref2 = this.$undoStack[i].length - 1; _ref2 <= 0 ? j <= 0 : j >= 0; _ref2 <= 0 ? j++ : j--) {
            for (k = _ref3 = this.$undoStack[i][j].deltas.length - 1; _ref3 <= 0 ? k <= 0 : k >= 0; _ref3 <= 0 ? k++ : k--) {
              delta = this.$undoStack[i][j].deltas[k];
              if (isContiguousInsert(delta)) {
                stringParts.unshift(delta.text);
                startPosition = [delta.range.start.row, delta.range.start.column];
              } else {
                return stringParts.join('');
              }
            }
          }
        }
        return stringParts.join('');
      };
      return JimUndoManager;
    })();
  });
}).call(this);
