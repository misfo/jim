define(function(require, exports, module) {
  var JimUndoManager;
  return JimUndoManager = (function() {
    function JimUndoManager(options) {
      this.reset();
    }
    JimUndoManager.prototype.execute = function(options) {
      var deltas;
      deltas = options.args[0];
      this.$doc = options.args[1];
      this.$undoStack.push(deltas);
      return this.$redoStack = [];
    };
    JimUndoManager.prototype.undo = function(dontSelect) {
      var deltas, undoSelectionRange;
      deltas = this.$undoStack.pop();
      if (this.isJimMark(deltas)) {
        return;
      }
      undoSelectionRange = null;
      if (deltas) {
        undoSelectionRange = this.$doc.undoChanges(deltas, dontSelect);
        this.$redoStack.push(deltas);
      }
      return undoSelectionRange;
    };
    JimUndoManager.prototype.redo = function(dontSelect) {
      var deltas, redoSelectionRange;
      deltas = this.$redoStack.pop();
      redoSelectionRange = null;
      if (deltas) {
        redoSelectionRange = this.$doc.redoChanges(deltas, dontSelect);
        this.$undoStack.push(deltas);
      }
      return redoSelectionRange;
    };
    JimUndoManager.prototype.reset = function() {
      this.$undoStack = [];
      return this.$redoStack = [];
    };
    JimUndoManager.prototype.hasUndo = function() {
      return this.$undoStack.length > 0;
    };
    JimUndoManager.prototype.hasRedo = function() {
      return this.$redoStack.length > 0;
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
    JimUndoManager.prototype.jimUndo = function() {
      var deltas, i, startIndex, _ref, _ref2, _results;
      deltas = this.$undoStack[this.$undoStack.length - 1];
      if (this.isJimMark(deltas, 'jimInsertEnd')) {
        startIndex = null;
        for (i = _ref = this.$undoStack.length - 1; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
          if (this.isJimMark(this.$undoStack[i], 'jimInsertStart')) {
            startIndex = i;
            break;
          }
        }
        if (startIndex != null) {
          _results = [];
          for (i = _ref2 = this.$undoStack.length - 1; _ref2 <= startIndex ? i <= startIndex : i >= startIndex; _ref2 <= startIndex ? i++ : i--) {
            _results.push(this.undo());
          }
          return _results;
        } else {
          return this.undo();
        }
      } else {
        return this.undo();
      }
    };
    return JimUndoManager;
  })();
});