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
    var Change, ChangeChar, ChangeToEndOfLine, Command, Delete, DeleteChar, GoToLine, Insert, InsertAfter, InsertAtEndOfLine, InsertBeforeFirstNonBlank, JoinLines, JoinLinesNormalizingWhitespace, ModeSwitch, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank, OpenLine, OpenLineAbove, Paste, ReplaceSwitch, Undo, defaultMappings, map, _ref, _ref2;
    Command = require('jim/helpers').Command;
    _ref = require('jim/operators'), Change = _ref.Change, Delete = _ref.Delete;
    _ref2 = require('jim/motions'), GoToLine = _ref2.GoToLine, MoveDown = _ref2.MoveDown, MoveLeft = _ref2.MoveLeft, MoveRight = _ref2.MoveRight, MoveToEndOfLine = _ref2.MoveToEndOfLine, MoveToFirstNonBlank = _ref2.MoveToFirstNonBlank;
    defaultMappings = {};
    map = function(keys, commandClass) {
      return defaultMappings[keys] = commandClass;
    };
    ModeSwitch = (function() {
      __extends(ModeSwitch, Command);
      function ModeSwitch() {
        ModeSwitch.__super__.constructor.apply(this, arguments);
      }
      ModeSwitch.prototype.exec = function(jim) {
        if (typeof this.beforeSwitch === "function") {
          this.beforeSwitch(jim);
        }
        return jim.setMode(this.switchToMode);
      };
      return ModeSwitch;
    })();
    map('v', (function() {
      __extends(_Class, ModeSwitch);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.isRepeatable = false;
      _Class.prototype.beforeSwitch = function(jim) {
        return jim.adaptor.setSelectionAnchor();
      };
      _Class.prototype.switchToMode = 'visual:characterwise';
      return _Class;
    })());
    map('V', (function() {
      __extends(_Class, ModeSwitch);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.isRepeatable = false;
      _Class.prototype.beforeSwitch = function(jim) {
        return jim.adaptor.setLinewiseSelectionAnchor();
      };
      _Class.prototype.switchToMode = 'visual:linewise';
      return _Class;
    })());
    map('i', Insert = (function() {
      __extends(Insert, ModeSwitch);
      function Insert() {
        Insert.__super__.constructor.apply(this, arguments);
      }
      Insert.prototype.switchToMode = 'insert';
      Insert.prototype.exec = function(jim) {
        var string;
        if (typeof this.beforeSwitch === "function") {
          this.beforeSwitch(jim);
        }
        if (string = this.repeatableInsertString) {
          return jim.adaptor.insert(string);
        } else {
          return jim.setMode(this.switchToMode);
        }
      };
      return Insert;
    })());
    map('a', InsertAfter = (function() {
      __extends(InsertAfter, Insert);
      function InsertAfter() {
        InsertAfter.__super__.constructor.apply(this, arguments);
      }
      InsertAfter.prototype.beforeSwitch = function(jim) {
        return jim.adaptor.moveRight(true);
      };
      return InsertAfter;
    })());
    map('A', InsertAtEndOfLine = (function() {
      __extends(InsertAtEndOfLine, Insert);
      function InsertAtEndOfLine() {
        InsertAtEndOfLine.__super__.constructor.apply(this, arguments);
      }
      InsertAtEndOfLine.prototype.beforeSwitch = function(jim) {
        new MoveToEndOfLine().exec(jim);
        return jim.adaptor.moveRight(true);
      };
      return InsertAtEndOfLine;
    })());
    map('C', ChangeToEndOfLine = (function() {
      __extends(ChangeToEndOfLine, Insert);
      function ChangeToEndOfLine() {
        ChangeToEndOfLine.__super__.constructor.apply(this, arguments);
      }
      ChangeToEndOfLine.prototype.beforeSwitch = function(jim) {
        return new Change(1, new MoveToEndOfLine(this.count)).exec(jim);
      };
      return ChangeToEndOfLine;
    })());
    map('I', InsertBeforeFirstNonBlank = (function() {
      __extends(InsertBeforeFirstNonBlank, Insert);
      function InsertBeforeFirstNonBlank() {
        InsertBeforeFirstNonBlank.__super__.constructor.apply(this, arguments);
      }
      InsertBeforeFirstNonBlank.prototype.beforeSwitch = function(jim) {
        return new MoveToFirstNonBlank().exec(jim);
      };
      return InsertBeforeFirstNonBlank;
    })());
    map('o', OpenLine = (function() {
      __extends(OpenLine, Insert);
      function OpenLine() {
        OpenLine.__super__.constructor.apply(this, arguments);
      }
      OpenLine.prototype.beforeSwitch = function(jim) {
        var row;
        row = jim.adaptor.row() + (this.above ? 0 : 1);
        jim.adaptor.insertNewLine(row);
        jim.adaptor.moveTo(row, 0);
        return jim.setMode('insert');
      };
      return OpenLine;
    })());
    map('O', OpenLineAbove = (function() {
      __extends(OpenLineAbove, OpenLine);
      function OpenLineAbove() {
        OpenLineAbove.__super__.constructor.apply(this, arguments);
      }
      OpenLineAbove.prototype.above = true;
      return OpenLineAbove;
    })());
    map('s', ChangeChar = (function() {
      __extends(ChangeChar, Insert);
      function ChangeChar() {
        ChangeChar.__super__.constructor.apply(this, arguments);
      }
      ChangeChar.prototype.beforeSwitch = function(jim) {
        return new DeleteChar(this.count).exec(jim);
      };
      return ChangeChar;
    })());
    map('R', ReplaceSwitch = (function() {
      __extends(ReplaceSwitch, ModeSwitch);
      function ReplaceSwitch() {
        ReplaceSwitch.__super__.constructor.apply(this, arguments);
      }
      ReplaceSwitch.prototype.beforeSwitch = function(jim) {
        return jim.adaptor.setOverwriteMode(true);
      };
      ReplaceSwitch.prototype.switchToMode = 'replace';
      return ReplaceSwitch;
    })());
    map('gJ', JoinLines = (function() {
      __extends(JoinLines, Command);
      function JoinLines() {
        JoinLines.__super__.constructor.apply(this, arguments);
      }
      JoinLines.prototype.exec = function(jim) {
        var timesLeft, _results;
        timesLeft = Math.max(this.count, 2) - 1;
        _results = [];
        while (timesLeft--) {
          jim.adaptor.selectLineEnding(this.normalize);
          jim.adaptor.deleteSelection();
          _results.push(this.normalize ? (jim.adaptor.insert(' '), jim.adaptor.moveLeft()) : void 0);
        }
        return _results;
      };
      JoinLines.prototype.visualExec = function(jim) {
        var maxRow, minRow, _ref3;
        _ref3 = jim.adaptor.selectionRowRange(), minRow = _ref3[0], maxRow = _ref3[1];
        jim.adaptor.clearSelection();
        jim.adaptor.moveTo(minRow, 0);
        this.count = maxRow - minRow + 1;
        this.exec(jim);
        return jim.setMode('normal');
      };
      return JoinLines;
    })());
    map('J', JoinLinesNormalizingWhitespace = (function() {
      __extends(JoinLinesNormalizingWhitespace, JoinLines);
      function JoinLinesNormalizingWhitespace() {
        JoinLinesNormalizingWhitespace.__super__.constructor.apply(this, arguments);
      }
      JoinLinesNormalizingWhitespace.prototype.normalize = true;
      return JoinLinesNormalizingWhitespace;
    })());
    map('D', (function() {
      __extends(_Class, Command);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.exec = function(jim) {
        return new Delete(1, new MoveToEndOfLine(this.count)).exec(jim);
      };
      return _Class;
    })());
    map('p', Paste = (function() {
      __extends(Paste, Command);
      function Paste() {
        Paste.__super__.constructor.apply(this, arguments);
      }
      Paste.prototype.exec = function(jim) {
        var beforeLineEnding, column, lastRow, lineEnding, linewiseRegister, registerValue, row, text, wholeString, _ref3;
        if (!(registerValue = jim.registers['"'])) {
          return;
        }
        text = new Array(this.count + 1).join(registerValue);
        linewiseRegister = /\n$/.test(registerValue);
        if (linewiseRegister) {
          row = jim.adaptor.row() + (this.before ? 0 : 1);
          lastRow = jim.adaptor.lastRow();
          if (row > lastRow) {
            _ref3 = /^([\s\S]*)(\r?\n)$/.exec(text), wholeString = _ref3[0], beforeLineEnding = _ref3[1], lineEnding = _ref3[2];
            text = lineEnding + beforeLineEnding;
            column = jim.adaptor.lineText(lastRow).length - 1;
            jim.adaptor.moveTo(row, column);
          } else {
            jim.adaptor.moveTo(row, 0);
          }
          jim.adaptor.insert(text);
          return jim.adaptor.moveTo(row, 0);
        } else {
          return jim.adaptor.insert(text, !this.before);
        }
      };
      Paste.prototype.visualExec = function(jim) {
        var overwrittenText;
        jim.adaptor.includeCursorInSelection();
        overwrittenText = jim.adaptor.deleteSelection();
        this.before = true;
        this.exec(jim);
        jim.registers['"'] = overwrittenText;
        return jim.setMode('normal');
      };
      return Paste;
    })());
    map('P', (function() {
      __extends(_Class, Paste);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.before = true;
      return _Class;
    })());
    map('r', (function() {
      __extends(_Class, Command);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.followedBy = /[\s\S]+/;
      _Class.prototype.exec = function(jim) {
        var replacementText;
        jim.adaptor.setSelectionAnchor();
        new MoveRight(this.count).exec(jim);
        jim.adaptor.deleteSelection();
        replacementText = /^\r?\n$/.test(this.followedBy) ? this.followedBy : new Array(this.count + 1).join(this.followedBy);
        jim.adaptor.insert(replacementText);
        return new MoveLeft().exec(jim);
      };
      return _Class;
    })());
    map('.', (function() {
      __extends(_Class, Command);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.isRepeatable = false;
      _Class.prototype.exec = function(jim) {
        var lastCommand, _ref3;
        lastCommand = jim.lastCommand;
        if (!lastCommand) {
          return;
        }
        if (lastCommand.switchToMode === 'insert') {
                    if ((_ref3 = lastCommand.repeatableInsertString) != null) {
            _ref3;
          } else {
            lastCommand.repeatableInsertString = jim.adaptor.lastRepeatableInsertString();
          };
        }
        return jim.lastCommand.exec(jim);
      };
      return _Class;
    })());
    map('u', Undo = (function() {
      __extends(Undo, Command);
      function Undo() {
        Undo.__super__.constructor.apply(this, arguments);
      }
      Undo.prototype.isRepeatable = false;
      Undo.prototype.exec = function(jim) {
        var timesLeft, _results;
        timesLeft = this.count;
        _results = [];
        while (timesLeft--) {
          _results.push(jim.adaptor.undo());
        }
        return _results;
      };
      return Undo;
    })());
    map('x', DeleteChar = (function() {
      __extends(DeleteChar, Command);
      function DeleteChar() {
        DeleteChar.__super__.constructor.apply(this, arguments);
      }
      DeleteChar.prototype.exec = function(jim) {
        return new Delete(1, new MoveRight(this.count)).exec(jim);
      };
      return DeleteChar;
    })());
    map('X', (function() {
      __extends(_Class, Command);
      function _Class() {
        _Class.__super__.constructor.apply(this, arguments);
      }
      _Class.prototype.exec = function(jim) {
        return new Delete(1, new MoveLeft(this.count)).exec(jim);
      };
      return _Class;
    })());
    return {
      defaultMappings: defaultMappings
    };
  });
}).call(this);
