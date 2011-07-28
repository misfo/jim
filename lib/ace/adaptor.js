(function() {
  define(function(require, exports, module) {
    var Adaptor, atLineEnd, beyondLineEnd;
    atLineEnd = function(editor, beyond) {
      var lineLength, selectionLead;
      selectionLead = editor.selection.getSelectionLead();
      lineLength = editor.selection.doc.getLine(selectionLead.row).length;
      return selectionLead.column >= lineLength - (beyond ? 0 : 1);
    };
    beyondLineEnd = function(editor) {
      return atLineEnd(editor, true);
    };
    return Adaptor = (function() {
      function Adaptor(editor) {
        this.editor = editor;
      }
      Adaptor.prototype.setOverwriteMode = function(active) {
        return this.editor.setOverwrite(active);
      };
      Adaptor.prototype.clearSelection = function(beginning) {
        var column, row, _ref;
        if (beginning && !this.editor.selection.isBackwards()) {
          _ref = this.editor.selection.getSelectionAnchor(), row = _ref.row, column = _ref.column;
          return this.editor.navigateTo(row, column);
        } else {
          return this.editor.clearSelection();
        }
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
      Adaptor.prototype.firstFullyVisibleRow = function() {
        return this.editor.renderer.getFirstFullyVisibleRow();
      };
      Adaptor.prototype.lastFullyVisibleRow = function() {
        return this.editor.renderer.getLastFullyVisibleRow();
      };
      Adaptor.prototype.includeCursorInSelection = function() {
        if (!this.editor.selection.isBackwards()) {
          if (!beyondLineEnd(this.editor)) {
            return this.editor.selection.selectRight();
          }
        }
      };
      Adaptor.prototype.insertNewLine = function(row) {
        return this.editor.session.doc.insertNewLine({
          row: row,
          column: 0
        });
      };
      Adaptor.prototype.adjustAnchor = function(columnOffset) {
        var column, row, _ref;
        _ref = this.editor.selection.getSelectionAnchor(), row = _ref.row, column = _ref.column;
        return this.editor.selection.setSelectionAnchor(row, column + columnOffset);
      };
      Adaptor.prototype.isSelectionBackwards = function() {
        return this.editor.selection.isBackwards();
      };
      Adaptor.prototype.lastRow = function() {
        return this.editor.session.getDocument().getLength() - 1;
      };
      Adaptor.prototype.lineText = function(lineNumber) {
        return this.editor.selection.doc.getLine(lineNumber != null ? lineNumber : this.row());
      };
      Adaptor.prototype.makeLinewise = function() {
        var anchorRow, leadRow, _ref;
        _ref = this.editor.selection, anchorRow = _ref.selectionAnchor.row, leadRow = _ref.selectionLead.row;
        this.editor.selection.setSelectionAnchor(Math.min(anchorRow, leadRow), 0);
        return this.editor.selection.moveCursorTo(Math.max(anchorRow, leadRow) + 1, 0);
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
      Adaptor.prototype.moveRight = function(beyond) {
        var dontMove;
        dontMove = beyond ? beyondLineEnd(this.editor) : atLineEnd(this.editor);
        if (!dontMove) {
          return this.editor.selection.moveCursorRight();
        }
      };
      Adaptor.prototype.moveTo = function(row, column) {
        return this.editor.moveCursorTo(row, column);
      };
      Adaptor.prototype.moveToLineEnd = function() {
        var column, position, row, _ref;
        _ref = this.editor.selection.selectionLead, row = _ref.row, column = _ref.column;
        position = this.editor.session.getDocumentLastRowColumnPosition(row, column);
        return this.moveTo(position.row, position.column - 1);
      };
      Adaptor.prototype.moveToEndOfPreviousLine = function() {
        var previousRow, previousRowLength;
        previousRow = this.row() - 1;
        previousRowLength = this.editor.session.doc.getLine(previousRow).length;
        return this.editor.selection.moveCursorTo(previousRow, previousRowLength);
      };
      Adaptor.prototype.navigateFileEnd = function() {
        return this.editor.navigateFileEnd();
      };
      Adaptor.prototype.navigateLineStart = function() {
        return this.editor.navigateLineStart();
      };
      Adaptor.prototype.findNext = function(pattern) {
        var range;
        this.editor.$search.set({
          needle: pattern,
          backwards: false
        });
        this.editor.selection.moveCursorRight();
        range = this.editor.$search.find(this.editor.session);
        if (range) {
          return this.moveTo(range.start.row, range.start.column);
        } else {
          return this.editor.selection.moveCursorLeft();
        }
      };
      Adaptor.prototype.findPrevious = function(pattern) {
        var range;
        this.editor.$search.set({
          needle: pattern,
          backwards: true
        });
        range = this.editor.$search.find(this.editor.session);
        if (range) {
          return this.moveTo(range.start.row, range.start.column);
        }
      };
      Adaptor.prototype.deleteSelection = function() {
        var yank;
        yank = this.editor.getCopyText();
        this.editor.session.remove(this.editor.getSelectionRange());
        this.editor.clearSelection();
        return yank;
      };
      Adaptor.prototype.indentSelection = function() {
        this.editor.indent();
        return this.clearSelection();
      };
      Adaptor.prototype.outdentSelection = function() {
        this.editor.blockOutdent();
        return this.clearSelection();
      };
      Adaptor.prototype.insert = function(text, after) {
        if (after && !beyondLineEnd(this.editor)) {
          this.editor.selection.moveCursorRight();
        }
        if (text) {
          return this.editor.insert(text);
        }
      };
      Adaptor.prototype.emptySelection = function() {
        return this.editor.selection.isEmpty();
      };
      Adaptor.prototype.selectionText = function() {
        return this.editor.getCopyText();
      };
      Adaptor.prototype.setSelectionAnchor = function() {
        var lead;
        lead = this.editor.selection.selectionLead;
        return this.editor.selection.setSelectionAnchor(lead.row, lead.column);
      };
      Adaptor.prototype.setLinewiseSelectionAnchor = function() {
        var column, lastColumn, row, _ref;
        _ref = this.editor.selection.selectionLead, row = _ref.row, column = _ref.column;
        lastColumn = this.editor.session.getDocumentLastRowColumnPosition(row, column);
        return this.editor.selection.setSelectionAnchor(row, lastColumn);
      };
      Adaptor.prototype.selectLineEnding = function(andFollowingWhitespace) {
        var firstNonBlank, _ref;
        this.editor.selection.moveCursorLineEnd();
        this.editor.selection.selectRight();
        if (andFollowingWhitespace) {
          firstNonBlank = ((_ref = /\S/.exec(this.lineText())) != null ? _ref.index : void 0) || 0;
          return this.moveTo(this.row(), firstNonBlank);
        }
      };
      Adaptor.prototype.selectionRowRange = function() {
        var anchorRow, cursorColumn, cursorRow, _ref;
        _ref = this.position(), cursorRow = _ref[0], cursorColumn = _ref[1];
        anchorRow = this.editor.selection.getSelectionAnchor().row;
        return [Math.min(cursorRow, anchorRow), Math.max(cursorRow, anchorRow)];
      };
      return Adaptor;
    })();
  });
}).call(this);
