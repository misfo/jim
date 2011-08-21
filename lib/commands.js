define(function(require, exports, module) {

var Change, ChangeChar, ChangeToEndOfLine, Command, Delete, DeleteChar, DeleteToEndOfLine, GoToLine, Insert, InsertAfter, InsertAtEndOfLine, InsertBeforeFirstNonBlank, JoinLines, JoinLinesNormalizingWhitespace, ModeSwitch, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank, OpenLine, OpenLineAbove, Paste, RepeatCommand, ReplaceSwitch, Undo, defaultMappings, map, repeatCountTimes, _ref, _ref2, _ref3;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
_ref = require('./helpers'), Command = _ref.Command, repeatCountTimes = _ref.repeatCountTimes;
_ref2 = require('./operators'), Change = _ref2.Change, Delete = _ref2.Delete;
_ref3 = require('./motions'), GoToLine = _ref3.GoToLine, MoveDown = _ref3.MoveDown, MoveLeft = _ref3.MoveLeft, MoveRight = _ref3.MoveRight, MoveToEndOfLine = _ref3.MoveToEndOfLine, MoveToFirstNonBlank = _ref3.MoveToFirstNonBlank;
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
  _Class.prototype.visualExec = function(jim) {
    if (/linewise/.test(jim.modeName)) {
      return jim.setMode('visual:characterwise');
    } else {
      return jim.onEscape();
    }
  };
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
  _Class.prototype.visualExec = function(jim) {
    if (/characterwise/.test(jim.modeName)) {
      return jim.setMode('visual:linewise');
    } else {
      return jim.onEscape();
    }
  };
  return _Class;
})());
map('i', Insert = (function() {
  __extends(Insert, ModeSwitch);
  function Insert() {
    Insert.__super__.constructor.apply(this, arguments);
  }
  Insert.prototype.switchToMode = 'insert';
  Insert.prototype.exec = function(jim) {
    if (typeof this.beforeSwitch === "function") {
      this.beforeSwitch(jim);
    }
    if (this.repeatableInsert) {
      return jim.adaptor.insert(this.repeatableInsert.string);
    } else {
      jim.afterInsertSwitch = true;
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
    return new DeleteToEndOfLine(this.count).exec(jim);
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
    return jim.adaptor.moveTo(row, 0);
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
    var maxRow, minRow, _ref4;
    _ref4 = jim.adaptor.selectionRowRange(), minRow = _ref4[0], maxRow = _ref4[1];
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
map('D', DeleteToEndOfLine = (function() {
  __extends(DeleteToEndOfLine, Command);
  function DeleteToEndOfLine() {
    DeleteToEndOfLine.__super__.constructor.apply(this, arguments);
  }
  DeleteToEndOfLine.prototype.exec = function(jim) {
    return new Delete(1, new MoveToEndOfLine(this.count)).exec(jim);
  };
  return DeleteToEndOfLine;
})());
map('p', Paste = (function() {
  __extends(Paste, Command);
  function Paste() {
    Paste.__super__.constructor.apply(this, arguments);
  }
  Paste.prototype.exec = function(jim) {
    var beforeLineEnding, column, lastRow, lineEnding, linewiseRegister, registerValue, row, text, wholeString, _ref4;
    if (!(registerValue = jim.registers['"'])) {
      return;
    }
    text = new Array(this.count + 1).join(registerValue);
    linewiseRegister = /\n$/.test(registerValue);
    if (linewiseRegister) {
      row = jim.adaptor.row() + (this.before ? 0 : 1);
      lastRow = jim.adaptor.lastRow();
      if (row > lastRow) {
        _ref4 = /^([\s\S]*)(\r?\n)$/.exec(text), wholeString = _ref4[0], beforeLineEnding = _ref4[1], lineEnding = _ref4[2];
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
    if (jim.modeName === 'visual:linewise') {
      jim.adaptor.makeLinewise();
    } else {
      jim.adaptor.includeCursorInSelection();
    }
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
map('.', RepeatCommand = (function() {
  __extends(RepeatCommand, Command);
  function RepeatCommand() {
    RepeatCommand.__super__.constructor.apply(this, arguments);
  }
  RepeatCommand.prototype.isRepeatable = false;
  RepeatCommand.prototype.exec = function(jim) {
    var command, row, selectionSize, string;
    command = jim.lastCommand;
    if (!command) {
      return;
    }
    if (command.switchToMode === 'insert') {
      command.repeatableInsert || (command.repeatableInsert = jim.adaptor.lastInsert());
      console.log('command.repeatableInsert', command.repeatableInsert);
      if (!command.repeatableInsert.contiguous) {
        string = command.repeatableInsert.string;
        command = new Insert();
        command.repeatableInsert = {
          string: string
        };
      }
    }
    if (selectionSize = command.selectionSize) {
      if (selectionSize.lines) {
        jim.adaptor.makeLinewise(selectionSize.lines - 1);
      } else if (selectionSize.chars) {
        jim.adaptor.setSelectionAnchor();
        new MoveRight(selectionSize.chars).exec(jim);
      } else {
        jim.adaptor.setSelectionAnchor();
        row = jim.adaptor.row() + selectionSize.lineEndings;
        jim.adaptor.moveTo(row, selectionSize.trailingChars - 1);
      }
      return command.visualExec(jim);
    } else {
      return command.exec(jim);
    }
  };
  return RepeatCommand;
})());
map('u', Undo = (function() {
  __extends(Undo, Command);
  function Undo() {
    Undo.__super__.constructor.apply(this, arguments);
  }
  Undo.prototype.isRepeatable = false;
  Undo.prototype.exec = repeatCountTimes(function(jim) {
    return jim.adaptor.undo();
  });
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
module.exports = {
  defaultMappings: defaultMappings
};

});