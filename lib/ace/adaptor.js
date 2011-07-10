(function() {
  define(function(require, exports, module) {
    var Adaptor, atLineEnd, beyondLineEnd, fixSelection;
    atLineEnd = function(editor, beyond) {
      var lineLength, selectionLead;
      selectionLead = editor.selection.getSelectionLead();
      lineLength = editor.selection.doc.getLine(selectionLead.row).length;
      return selectionLead.column >= lineLength - (beyond ? 0 : 1);
    };
    beyondLineEnd = function(editor) {
      return atLineEnd(editor, true);
    };
    fixSelection = function(exclusive, linewise) {
      var anchorRow, leadRow, _ref;
      if (linewise) {
        _ref = this.editor.selection, anchorRow = _ref.selectionAnchor.row, leadRow = _ref.selectionLead.row;
        this.editor.selection.setSelectionAnchor(Math.min(anchorRow, leadRow), 0);
        return this.editor.selection.moveCursorTo(Math.max(anchorRow, leadRow) + 1, 0);
      } else if (!exclusive && !this.editor.selection.isBackwards()) {
        if (!beyondLineEnd(this.editor)) {
          return this.editor.selection.selectRight();
        }
      }
    };
    return Adaptor = (function() {
      function Adaptor(editor) {
        this.editor = editor;
      }
      Adaptor.prototype.clearSelection = function() {
        return this.editor.clearSelection();
      };
      Adaptor.prototype.undo = function() {
        var undoManager;
        undoManager = this.editor.session.getUndoManager();
        undoManager.jimUndo();
        return this.editor.clearSelection();
      };
      Adaptor.prototype.column = function() {
        return this.editor.selection.selectionLead.column;
      };
      Adaptor.prototype.row = function() {
        return this.editor.selection.selectionLead.row;
      };
      Adaptor.prototype.position = function() {
        return [this.row(), this.column()];
      };
      Adaptor.prototype.lastRow = function() {
        return this.editor.session.getDocument().getLength() - 1;
      };
      Adaptor.prototype.goToLine = function(lineNumber) {
        return this.editor.gotoLine(lineNumber);
      };
      Adaptor.prototype.lineText = function(lineNumber) {
        return this.editor.selection.doc.getLine(lineNumber != null ? lineNumber : this.row());
      };
      Adaptor.prototype.moveUp = function() {
        return this.editor.selection.moveCursorBy(-1, 0);
      };
      Adaptor.prototype.moveDown = function() {
        return this.editor.selection.moveCursorBy(1, 0);
      };
      Adaptor.prototype.moveLeft = function() {
        if (this.editor.selection.selectionLead.getPosition().column > 0) {
          return this.editor.selection.moveCursorLeft();
        }
      };
      Adaptor.prototype.moveRight = function() {
        if (!atLineEnd(this.editor)) {
          return this.editor.selection.moveCursorRight();
        }
      };
      Adaptor.prototype.moveTo = function(row, column) {
        return this.editor.moveCursorTo(row, column);
      };
      Adaptor.prototype.navigateFileEnd = function() {
        return this.editor.navigateFileEnd();
      };
      Adaptor.prototype.navigateLineEnd = function() {
        return this.editor.navigateLineEnd();
      };
      Adaptor.prototype.navigateLineStart = function() {
        return this.editor.navigateLineStart();
      };
      Adaptor.prototype.deleteSelection = function(exclusive, linewise, operator) {
        var yank;
        fixSelection.call(this, exclusive, linewise);
        if (linewise && operator === 'c') {
          this.editor.selection.moveCursorLeft();
        }
        yank = this.editor.getCopyText();
        this.editor.session.remove(this.editor.getSelectionRange());
        this.editor.clearSelection();
        return yank;
      };
      Adaptor.prototype.insert = function(text, after) {
        if (after && !beyondLineEnd(this.editor)) {
          this.editor.selection.moveCursorRight();
        }
        if (text) {
          return this.editor.insert(text);
        }
      };
      Adaptor.prototype.selectLine = function() {
        return this.editor.selection.selectLine();
      };
      Adaptor.prototype.selectToLineEnd = function() {
        return this.editor.selection.selectLineEnd();
      };
      Adaptor.prototype.emptySelection = function() {
        return this.editor.selection.isEmpty();
      };
      Adaptor.prototype.selectionText = function(exclusive, linewise) {
        fixSelection.call(this, exclusive, linewise);
        return this.editor.getCopyText();
      };
      Adaptor.prototype.setSelectionAnchor = function() {
        var lead;
        lead = this.editor.selection.selectionLead;
        return this.editor.selection.setSelectionAnchor(lead.row, lead.column);
      };
      return Adaptor;
    })();
  });
}).call(this);
