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
        var deltas;
        deltas = entry != null ? entry.deltas : void 0;
        return typeof deltas === 'string' && (matchingMark[deltas] != null);
      };
      JimUndoManager.prototype.lastOnUndoStack = function() {
        return this.$undoStack[this.$undoStack.length - 1];
      };
      JimUndoManager.prototype.markUndoPoint = function(doc, markName) {
        return this.execute({
          args: [
            {
              group: 'doc',
              deltas: markName
            }, doc
          ]
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
        var i, lastDeltasOnStack, startIndex, startMark, _ref, _ref2, _ref3, _ref4;
        lastDeltasOnStack = (_ref = this.lastOnUndoStack()) != null ? _ref.deltas : void 0;
        if (typeof lastDeltasOnStack === 'string' && (startMark = this.matchingMark[lastDeltasOnStack])) {
          startIndex = null;
          for (i = _ref2 = this.$undoStack.length - 1; _ref2 <= 0 ? i <= 0 : i >= 0; _ref2 <= 0 ? i++ : i--) {
            if (((_ref3 = this.$undoStack[i]) != null ? _ref3.deltas : void 0) === startMark) {
              startIndex = i;
              break;
            }
          }
          if (startIndex != null) {
            this.silentUndo();
            for (i = _ref4 = this.$undoStack.length - 1; _ref4 <= startIndex ? i < startIndex : i > startIndex; _ref4 <= startIndex ? i++ : i--) {
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
      return JimUndoManager;
    })();
  });
}).call(this);
