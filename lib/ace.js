define(function(require, exports, module) {

var Adaptor, Jim, JimUndoManager, UndoManager, isCharacterKey;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
UndoManager = require('ace/undomanager').UndoManager;
Jim = require('./jim');
Adaptor = (function() {
  var atLineEnd, beyondLineEnd;
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
    Adaptor.prototype.lastInsert = function() {
      return this.editor.session.getUndoManager().lastInsert();
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
    Adaptor.prototype.makeLinewise = function(lines) {
      var anchorRow, firstRow, lastRow, leadRow, _ref, _ref2;
      _ref = this.editor.selection, anchorRow = _ref.selectionAnchor.row, leadRow = _ref.selectionLead.row;
      _ref2 = lines != null ? [leadRow, leadRow + (lines - 1)] : [Math.min(anchorRow, leadRow), Math.max(anchorRow, leadRow)], firstRow = _ref2[0], lastRow = _ref2[1];
      this.editor.selection.setSelectionAnchor(firstRow, 0);
      return this.editor.selection.moveCursorTo(lastRow + 1, 0);
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
    Adaptor.prototype.findNext = function(pattern, wholeWord) {
      var range;
      this.editor.$search.set({
        needle: pattern,
        backwards: false,
        wholeWord: !!wholeWord
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
    Adaptor.prototype.characterwiseSelectionSize = function() {
      var rowsDown, selectionAnchor, selectionLead, _ref;
      _ref = this.editor.selection, selectionAnchor = _ref.selectionAnchor, selectionLead = _ref.selectionLead;
      rowsDown = selectionLead.row - selectionAnchor.row;
      if (rowsDown === 0) {
        return {
          chars: Math.abs(selectionAnchor.column - selectionLead.column)
        };
      } else {
        return {
          lineEndings: Math.abs(rowsDown),
          trailingChars: (rowsDown > 0 ? selectionLead : selectionAnchor).column + 1
        };
      }
    };
    return Adaptor;
  })();
})();
JimUndoManager = (function() {
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
  JimUndoManager.prototype.lastInsert = function() {
    var delta, i, isContiguousInsert, item, j, k, startPosition, stringParts, _ref, _ref2, _ref3;
    if (this.lastOnUndoStack() !== 'jim:insert:end') {
      return '';
    }
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
          item = this.$undoStack[i][j];
          delta = item.deltas[k];
          if (item === 'jim:insert:start' || item === 'jim:insert:afterSwitch') {
            return {
              string: stringParts.join(''),
              contiguous: true
            };
          } else if (isContiguousInsert(delta)) {
            stringParts.unshift(delta.text);
            startPosition = [delta.range.start.row, delta.range.start.column];
          } else {
            return {
              string: stringParts.join(''),
              contiguous: false
            };
          }
        }
      }
    }
    return {
      string: stringParts.join(''),
      contiguous: true
    };
  };
  return JimUndoManager;
})();
require('pilot/dom').importCssString(".jim-normal-mode div.ace_cursor\n, .jim-visual-characterwise-mode div.ace_cursor\n, .jim-visual-linewise-mode div.ace_cursor {\n  border: 0;\n  background-color: #91FF00;\n  opacity: 0.5;\n}\n.jim-visual-linewise-mode .ace_marker-layer .ace_selection {\n  left: 0 !important;\n  width: 100% !important;\n}");
isCharacterKey = function(hashId, keyCode) {
  return hashId === 0 && !keyCode;
};
exports.startup = function(data, reason) {
  var adaptor, editor, jim, undoManager;
  editor = data.env.editor;
  if (!editor) {
    setTimeout(startup, 0, data, reason);
    return;
  }
  editor.setKeyboardHandler({
    handleKeyboard: function(data, hashId, keyString, keyCode) {
      var passKeypressThrough;
      if (keyCode === 27) {
        return jim.onEscape();
      } else if (isCharacterKey(hashId, keyCode)) {
        if (jim.afterInsertSwitch) {
          if (jim.modeName === 'insert') {
            undoManager.markUndoPoint(editor.session, 'jim:insert:afterSwitch');
          }
          jim.afterInsertSwitch = false;
        }
        if (jim.modeName === 'normal' && !jim.adaptor.emptySelection()) {
          jim.setMode('visual:characterwise');
        }
        if (keyString.length > 1) {
          keyString = keyString.charAt(0);
        }
        passKeypressThrough = jim.onKeypress(keyString);
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
    var className, mode, undoPointName, _i, _len, _ref;
    _ref = ['insert', 'normal', 'visual:characterwise', 'visual:linewise'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      mode = _ref[_i];
      className = "jim-" + (mode.replace(/\W/, '-')) + "-mode";
      if (mode === this.modeName) {
        editor.setStyle(className);
      } else {
        editor.unsetStyle(className);
      }
    }
    undoPointName = null;
    if (this.modeName === 'insert') {
      undoPointName = 'jim:insert:start';
    } else if (prevMode === 'insert') {
      undoPointName = 'jim:insert:end';
    }
    if (this.modeName === 'replace') {
      undoPointName = 'jim:replace:start';
    } else if (prevMode === 'replace') {
      undoPointName = 'jim:replace:end';
    }
    if (undoPointName) {
      return undoManager.markUndoPoint(editor.session, undoPointName);
    }
  };
  jim.onModeChange();
  return jim;
};

});