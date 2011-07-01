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
      JimUndoManager.prototype.isJimMark = function(entry, markName) {
        var deltas;
        deltas = entry != null ? entry.deltas : void 0;
        if (typeof deltas !== 'string') {
          return false;
        }
        if (markName) {
          return deltas === markName;
        } else {
          return /^jim/.test(deltas);
        }
      };
      JimUndoManager.prototype.lastOnUndoStack = function() {
        return this.$undoStack[this.$undoStack.length - 1];
      };
      JimUndoManager.prototype.markInsertStartPoint = function(doc) {
        var options;
        options = {
          args: [
            {
              group: 'doc',
              deltas: 'jimInsertStart'
            }, doc
          ]
        };
        return this.execute(options);
      };
      JimUndoManager.prototype.markInsertEndPoint = function(doc) {
        var options;
        options = {
          args: [
            {
              group: 'doc',
              deltas: 'jimInsertEnd'
            }, doc
          ]
        };
        return this.execute(options);
      };
      JimUndoManager.prototype.silentUndo = function() {
        var deltas;
        deltas = this.$undoStack.pop();
        if (deltas) {
          return this.$redoStack.push(deltas);
        }
      };
      JimUndoManager.prototype.jimUndo = function() {
        var i, startIndex, _ref, _ref2;
        if (this.isJimMark(this.lastOnUndoStack(), 'jimInsertEnd')) {
          startIndex = null;
          for (i = _ref = this.$undoStack.length - 1; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
            if (this.isJimMark(this.$undoStack[i], 'jimInsertStart')) {
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
            return console.log("found a jimInsertEnd on the undoStack, but no jimInsertStart'");
          }
        } else {
          return this.undo();
        }
      };
      return JimUndoManager;
    })();
  });
}).call(this);
