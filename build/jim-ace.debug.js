/**
 * Jim v0.2.0-pre
 * https://github.com/misfo/jim
 *
 * Copyright 2011, Trent Ogren
 * Released under the MIT License
 */
this.Jim = (function() {
  function require(path) { return path[0] === '.' ? require[path] : window.require(path); }
  
require['./helpers'] = (function() {
  var exports = {}, module = {};
  exports.Command = (function() {
  function Command(count) {
    this.count = count != null ? count : 1;
  }
  Command.prototype.isRepeatable = true;
  Command.prototype.isComplete = function() {
    if (this.constructor.followedBy) {
      return this.followedBy;
    } else {
      return true;
    }
  };
  return Command;
})();
exports.repeatCountTimes = function(func) {
  return function(jim) {
    var timesLeft, _results;
    timesLeft = this.count;
    _results = [];
    while (timesLeft--) {
      _results.push(func.call(this, jim));
    }
    return _results;
  };
};
  return module.exports || exports;
})();

require['./motions'] = (function() {
  var exports = {}, module = {};
  var Command, GoToLine, GoToLineOrEnd, GoToNextChar, GoToPreviousChar, GoUpToNextChar, GoUpToPreviousChar, LinewiseCommandMotion, Motion, MoveBackBigWord, MoveBackWord, MoveDown, MoveLeft, MoveRight, MoveToBigWordEnd, MoveToEndOfLine, MoveToFirstNonBlank, MoveToNextBigWord, MoveToNextWord, MoveToWordEnd, MoveUp, NearestWordSearch, NearestWordSearchBackwards, Search, SearchBackwards, WORDRegex, defaultMappings, lastWORDRegex, lastWordRegex, map, repeatCountTimes, wordRegex, _ref;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
_ref = require('./helpers'), Command = _ref.Command, repeatCountTimes = _ref.repeatCountTimes;
WORDRegex = function() {
  return /\S+/g;
};
wordRegex = function() {
  return /(\w+)|([^\w\s]+)/g;
};
lastWORDRegex = RegExp("" + (WORDRegex().source) + "\\s*$");
lastWordRegex = RegExp("(" + (wordRegex().source) + ")\\s*$");
defaultMappings = {};
map = function(keys, motionClass) {
  return defaultMappings[keys] = motionClass;
};
Motion = (function() {
  __extends(Motion, Command);
  function Motion(count) {
    this.count = count != null ? count : 1;
  }
  Motion.prototype.isRepeatable = false;
  Motion.prototype.linewise = false;
  Motion.prototype.exclusive = false;
  Motion.prototype.visualExec = function(jim) {
    return this.exec(jim);
  };
  return Motion;
})();
LinewiseCommandMotion = (function() {
  __extends(LinewiseCommandMotion, Motion);
  function LinewiseCommandMotion() {
    LinewiseCommandMotion.__super__.constructor.apply(this, arguments);
  }
  LinewiseCommandMotion.prototype.linewise = true;
  LinewiseCommandMotion.prototype.exec = function(jim) {
    var additionalLines;
    if (additionalLines = this.count - 1) {
      return new MoveDown(additionalLines).exec(jim);
    }
  };
  return LinewiseCommandMotion;
})();
map('h', MoveLeft = (function() {
  __extends(MoveLeft, Motion);
  function MoveLeft() {
    MoveLeft.__super__.constructor.apply(this, arguments);
  }
  MoveLeft.prototype.exclusive = true;
  MoveLeft.prototype.exec = repeatCountTimes(function(jim) {
    return jim.adaptor.moveLeft();
  });
  return MoveLeft;
})());
map('j', MoveDown = (function() {
  __extends(MoveDown, Motion);
  function MoveDown() {
    MoveDown.__super__.constructor.apply(this, arguments);
  }
  MoveDown.prototype.linewise = true;
  MoveDown.prototype.exec = repeatCountTimes(function(jim) {
    return jim.adaptor.moveDown();
  });
  return MoveDown;
})());
map('k', MoveUp = (function() {
  __extends(MoveUp, Motion);
  function MoveUp() {
    MoveUp.__super__.constructor.apply(this, arguments);
  }
  MoveUp.prototype.linewise = true;
  MoveUp.prototype.exec = repeatCountTimes(function(jim) {
    return jim.adaptor.moveUp();
  });
  return MoveUp;
})());
map('l', MoveRight = (function() {
  __extends(MoveRight, Motion);
  function MoveRight() {
    MoveRight.__super__.constructor.apply(this, arguments);
  }
  MoveRight.prototype.exclusive = true;
  MoveRight.prototype.exec = repeatCountTimes(function(jim) {
    return jim.adaptor.moveRight(this.operation != null);
  });
  return MoveRight;
})());
map('e', MoveToWordEnd = (function() {
  __extends(MoveToWordEnd, Motion);
  function MoveToWordEnd() {
    MoveToWordEnd.__super__.constructor.apply(this, arguments);
  }
  MoveToWordEnd.prototype.exec = repeatCountTimes(function(jim) {
    var column, firstMatchOnSubsequentLine, line, nextMatch, regex, rightOfCursor, row, thisMatch, _ref2;
    regex = this.bigWord ? WORDRegex() : wordRegex();
    line = jim.adaptor.lineText();
    _ref2 = jim.adaptor.position(), row = _ref2[0], column = _ref2[1];
    rightOfCursor = line.substring(column);
    if (column >= line.length - 1) {
      while (true) {
        line = jim.adaptor.lineText(++row);
        firstMatchOnSubsequentLine = regex.exec(line);
        if (firstMatchOnSubsequentLine) {
          column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1;
          break;
        } else if (row === jim.adaptor.lastRow()) {
          return;
        }
      }
    } else {
      thisMatch = regex.exec(rightOfCursor);
      if (thisMatch.index > 1 || thisMatch[0].length > 1) {
        column += thisMatch[0].length + thisMatch.index - 1;
      } else {
        nextMatch = regex.exec(rightOfCursor);
        column += nextMatch.index + nextMatch[0].length - 1;
      }
    }
    return jim.adaptor.moveTo(row, column);
  });
  return MoveToWordEnd;
})());
map('E', MoveToBigWordEnd = (function() {
  __extends(MoveToBigWordEnd, MoveToWordEnd);
  function MoveToBigWordEnd() {
    MoveToBigWordEnd.__super__.constructor.apply(this, arguments);
  }
  MoveToBigWordEnd.prototype.bigWord = true;
  return MoveToBigWordEnd;
})());
map('w', MoveToNextWord = (function() {
  __extends(MoveToNextWord, Motion);
  function MoveToNextWord() {
    MoveToNextWord.__super__.constructor.apply(this, arguments);
  }
  MoveToNextWord.prototype.exclusive = true;
  MoveToNextWord.prototype.exec = function(jim) {
    var column, lastMotion, line, nextLineMatch, nextMatch, regex, rightOfCursor, row, thisMatch, timesLeft, _ref2, _ref3, _results;
    timesLeft = this.count;
    _results = [];
    while (timesLeft--) {
      regex = this.bigWord ? WORDRegex() : wordRegex();
      line = jim.adaptor.lineText();
      _ref2 = jim.adaptor.position(), row = _ref2[0], column = _ref2[1];
      rightOfCursor = line.substring(column);
      thisMatch = regex.exec(rightOfCursor);
      if (!thisMatch || !(nextMatch = regex.exec(rightOfCursor))) {
        if (timesLeft === 0 && this.operation) {
          column = line.length;
        } else {
          line = jim.adaptor.lineText(++row);
          nextLineMatch = regex.exec(line);
          column = (nextLineMatch != null ? nextLineMatch.index : void 0) || 0;
        }
      } else if (timesLeft === 0 && ((_ref3 = this.operation) != null ? _ref3.switchToMode : void 0) === 'insert') {
        lastMotion = new MoveToWordEnd();
        lastMotion.bigWord = this.bigWord;
        lastMotion.exec(jim);
        this.exclusive = false;
        return;
      } else if ((thisMatch != null ? thisMatch.index : void 0) > 0) {
        column += thisMatch.index;
      } else {
        column += nextMatch.index;
      }
      _results.push(jim.adaptor.moveTo(row, column));
    }
    return _results;
  };
  return MoveToNextWord;
})());
map('W', MoveToNextBigWord = (function() {
  __extends(MoveToNextBigWord, MoveToNextWord);
  function MoveToNextBigWord() {
    MoveToNextBigWord.__super__.constructor.apply(this, arguments);
  }
  MoveToNextBigWord.prototype.bigWord = true;
  return MoveToNextBigWord;
})());
map('b', MoveBackWord = (function() {
  __extends(MoveBackWord, Motion);
  function MoveBackWord() {
    MoveBackWord.__super__.constructor.apply(this, arguments);
  }
  MoveBackWord.prototype.exclusive = true;
  MoveBackWord.prototype.exec = repeatCountTimes(function(jim) {
    var column, leftOfCursor, line, match, regex, row, _ref2;
    regex = this.bigWord ? lastWORDRegex : lastWordRegex;
    line = jim.adaptor.lineText();
    _ref2 = jim.adaptor.position(), row = _ref2[0], column = _ref2[1];
    leftOfCursor = line.substring(0, column);
    match = regex.exec(leftOfCursor);
    if (match) {
      column = match.index;
    } else {
      row--;
      while (/^\s+$/.test(line = jim.adaptor.lineText(row))) {
        row--;
      }
      match = regex.exec(line);
      column = (match != null ? match.index : void 0) || 0;
    }
    return jim.adaptor.moveTo(row, column);
  });
  return MoveBackWord;
})());
map('B', MoveBackBigWord = (function() {
  __extends(MoveBackBigWord, MoveBackWord);
  function MoveBackBigWord() {
    MoveBackBigWord.__super__.constructor.apply(this, arguments);
  }
  MoveBackBigWord.prototype.bigWord = true;
  return MoveBackBigWord;
})());
map('0', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    return jim.adaptor.moveTo(jim.adaptor.row(), 0);
  };
  return _Class;
})());
map('^', MoveToFirstNonBlank = (function() {
  __extends(MoveToFirstNonBlank, Motion);
  function MoveToFirstNonBlank() {
    MoveToFirstNonBlank.__super__.constructor.apply(this, arguments);
  }
  MoveToFirstNonBlank.prototype.exec = function(jim) {
    var column, line, row, _ref2;
    row = jim.adaptor.row();
    line = jim.adaptor.lineText(row);
    column = ((_ref2 = /\S/.exec(line)) != null ? _ref2.index : void 0) || 0;
    return jim.adaptor.moveTo(row, column);
  };
  return MoveToFirstNonBlank;
})());
map('$', MoveToEndOfLine = (function() {
  __extends(MoveToEndOfLine, Motion);
  function MoveToEndOfLine() {
    MoveToEndOfLine.__super__.constructor.apply(this, arguments);
  }
  MoveToEndOfLine.prototype.exec = function(jim) {
    var additionalLines;
    additionalLines = this.count - 1;
    if (additionalLines) {
      new MoveDown(additionalLines).exec(jim);
    }
    return jim.adaptor.moveToLineEnd();
  };
  return MoveToEndOfLine;
})());
map('gg', GoToLine = (function() {
  __extends(GoToLine, Motion);
  function GoToLine() {
    GoToLine.__super__.constructor.apply(this, arguments);
  }
  GoToLine.prototype.linewise = true;
  GoToLine.prototype.exec = function(jim) {
    var lineText, rowNumber;
    rowNumber = this.count - 1;
    lineText = jim.adaptor.lineText(rowNumber);
    jim.adaptor.moveTo(rowNumber, 0);
    return new MoveToFirstNonBlank().exec(jim);
  };
  return GoToLine;
})());
map('G', GoToLineOrEnd = (function() {
  __extends(GoToLineOrEnd, GoToLine);
  function GoToLineOrEnd(count) {
    this.count = count;
  }
  GoToLineOrEnd.prototype.exec = function(jim) {
    this.count || (this.count = jim.adaptor.lastRow() + 1);
    return GoToLineOrEnd.__super__.exec.apply(this, arguments);
  };
  return GoToLineOrEnd;
})());
map('H', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.linewise = true;
  _Class.prototype.exec = function(jim) {
    var line;
    line = jim.adaptor.firstFullyVisibleRow() + this.count;
    return new GoToLineOrEnd(line).exec(jim);
  };
  return _Class;
})());
map('M', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.linewise = true;
  _Class.prototype.exec = function(jim) {
    var lines, linesFromTop, topRow;
    topRow = jim.adaptor.firstFullyVisibleRow();
    lines = jim.adaptor.lastFullyVisibleRow() - topRow;
    linesFromTop = Math.floor(lines / 2);
    return new GoToLineOrEnd(topRow + 1 + linesFromTop).exec(jim);
  };
  return _Class;
})());
map('L', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.linewise = true;
  _Class.prototype.exec = function(jim) {
    var line;
    line = jim.adaptor.lastFullyVisibleRow() + 2 - this.count;
    return new GoToLineOrEnd(line).exec(jim);
  };
  return _Class;
})());
map('/', Search = (function() {
  __extends(Search, Motion);
  function Search() {
    Search.__super__.constructor.apply(this, arguments);
  }
  Search.prototype.exclusive = true;
  Search.prototype.getSearch = function() {
    return {
      pattern: prompt("Find:"),
      backwards: this.backwards
    };
  };
  Search.prototype.exec = function(jim) {
    var finder, timesLeft, _results;
    jim.search = this.getSearch(jim);
    timesLeft = this.count;
    finder = this.backwards ? 'findPrevious' : 'findNext';
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor[finder](jim.search.pattern, jim.search.wholeWord));
    }
    return _results;
  };
  return Search;
})());
map('?', SearchBackwards = (function() {
  __extends(SearchBackwards, Search);
  function SearchBackwards() {
    SearchBackwards.__super__.constructor.apply(this, arguments);
  }
  SearchBackwards.prototype.backwards = true;
  return SearchBackwards;
})());
map('*', NearestWordSearch = (function() {
  var wordCursorIsOn;
  __extends(NearestWordSearch, Search);
  function NearestWordSearch() {
    NearestWordSearch.__super__.constructor.apply(this, arguments);
  }
  NearestWordSearch.prototype.getSearch = function(jim) {
    var charsAhead, pattern, wholeWord, _ref2;
    _ref2 = wordCursorIsOn(jim.adaptor.lineText(), jim.adaptor.column()), pattern = _ref2[0], charsAhead = _ref2[1];
    if (charsAhead) {
      new MoveRight(charsAhead).exec(jim);
    }
    console.log('pattern', pattern);
    wholeWord = /^\w/.test(pattern);
    return {
      pattern: pattern,
      wholeWord: wholeWord,
      backwards: this.backwards
    };
  };
  wordCursorIsOn = function(line, column) {
    var charsAhead, leftMatch, leftOfCursor, nextWord, rightMatch, rightOfCursor;
    leftOfCursor = line.substring(0, column);
    rightOfCursor = line.substring(column);
    charsAhead = null;
    if (/\W/.test(line[column])) {
      leftMatch = [''];
      nextWord = /\w+/.exec(rightOfCursor);
      rightMatch = !nextWord ? /[^\w\s]+/.exec(rightOfCursor) : nextWord;
      charsAhead = rightMatch.index;
    } else {
      leftMatch = /\w*$/.exec(leftOfCursor);
      rightMatch = /^\w*/.exec(rightOfCursor);
    }
    return [leftMatch[0] + rightMatch[0], charsAhead];
  };
  return NearestWordSearch;
})());
map('#', NearestWordSearchBackwards = (function() {
  __extends(NearestWordSearchBackwards, NearestWordSearch);
  function NearestWordSearchBackwards() {
    NearestWordSearchBackwards.__super__.constructor.apply(this, arguments);
  }
  NearestWordSearchBackwards.prototype.backwards = true;
  return NearestWordSearchBackwards;
})());
map('n', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    var func, timesLeft, _results;
    if (!jim.search) {
      return;
    }
    timesLeft = this.count;
    func = jim.search.backwards ? 'findPrevious' : 'findNext';
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor[func](jim.search.pattern, jim.search.wholeWord));
    }
    return _results;
  };
  return _Class;
})());
map('N', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    var func, timesLeft, _results;
    if (!jim.search) {
      return;
    }
    timesLeft = this.count;
    func = jim.search.backwards ? 'findNext' : 'findPrevious';
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor[func](jim.search.pattern, jim.search.wholeWord));
    }
    return _results;
  };
  return _Class;
})());
map('f', GoToNextChar = (function() {
  __extends(GoToNextChar, Motion);
  function GoToNextChar() {
    GoToNextChar.__super__.constructor.apply(this, arguments);
  }
  GoToNextChar.followedBy = /./;
  GoToNextChar.prototype.exec = function(jim) {
    var column, columnsRight, rightOfCursor, row, timesLeft, _ref2, _ref3;
    timesLeft = (_ref2 = this.count) != null ? _ref2 : 1;
    _ref3 = jim.adaptor.position(), row = _ref3[0], column = _ref3[1];
    rightOfCursor = jim.adaptor.lineText().substring(column + 1);
    columnsRight = 0;
    while (timesLeft--) {
      columnsRight = rightOfCursor.indexOf(this.followedBy, columnsRight) + 1;
    }
    if (columnsRight) {
      if (this.beforeChar) {
        columnsRight--;
      }
      return jim.adaptor.moveTo(row, column + columnsRight);
    }
  };
  return GoToNextChar;
})());
map('t', GoUpToNextChar = (function() {
  __extends(GoUpToNextChar, GoToNextChar);
  function GoUpToNextChar() {
    GoUpToNextChar.__super__.constructor.apply(this, arguments);
  }
  GoUpToNextChar.prototype.beforeChar = true;
  return GoUpToNextChar;
})());
map('F', GoToPreviousChar = (function() {
  __extends(GoToPreviousChar, Motion);
  function GoToPreviousChar() {
    GoToPreviousChar.__super__.constructor.apply(this, arguments);
  }
  GoToPreviousChar.followedBy = /./;
  GoToPreviousChar.prototype.exec = function(jim) {
    var column, leftOfCursor, row, targetColumn, timesLeft, _ref2, _ref3;
    timesLeft = (_ref2 = this.count) != null ? _ref2 : 1;
    _ref3 = jim.adaptor.position(), row = _ref3[0], column = _ref3[1];
    leftOfCursor = jim.adaptor.lineText().substring(0, column);
    targetColumn = column;
    while (timesLeft--) {
      targetColumn = leftOfCursor.lastIndexOf(this.followedBy, targetColumn - 1);
    }
    if ((0 <= targetColumn && targetColumn < column)) {
      if (this.beforeChar) {
        targetColumn++;
      }
      return jim.adaptor.moveTo(row, targetColumn);
    }
  };
  return GoToPreviousChar;
})());
map('T', GoUpToPreviousChar = (function() {
  __extends(GoUpToPreviousChar, GoToPreviousChar);
  function GoUpToPreviousChar() {
    GoUpToPreviousChar.__super__.constructor.apply(this, arguments);
  }
  GoUpToPreviousChar.prototype.beforeChar = true;
  return GoUpToPreviousChar;
})());
module.exports = {
  GoToLine: GoToLine,
  MoveDown: MoveDown,
  MoveLeft: MoveLeft,
  MoveRight: MoveRight,
  MoveToEndOfLine: MoveToEndOfLine,
  MoveToFirstNonBlank: MoveToFirstNonBlank,
  LinewiseCommandMotion: LinewiseCommandMotion,
  MoveToNextBigWord: MoveToNextBigWord,
  MoveToNextWord: MoveToNextWord,
  MoveToBigWordEnd: MoveToBigWordEnd,
  MoveToWordEnd: MoveToWordEnd,
  defaultMappings: defaultMappings
};
  return module.exports || exports;
})();

require['./operators'] = (function() {
  var exports = {}, module = {};
  var Change, Command, Delete, GoToLine, Indent, MoveToBigWordEnd, MoveToFirstNonBlank, MoveToNextBigWord, MoveToNextWord, MoveToWordEnd, Operation, Outdent, Yank, defaultMappings, map, _ref;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
Command = require('./helpers').Command;
_ref = require('./motions'), GoToLine = _ref.GoToLine, MoveToFirstNonBlank = _ref.MoveToFirstNonBlank, MoveToNextBigWord = _ref.MoveToNextBigWord, MoveToNextWord = _ref.MoveToNextWord, MoveToBigWordEnd = _ref.MoveToBigWordEnd, MoveToWordEnd = _ref.MoveToWordEnd;
defaultMappings = {};
map = function(keys, operatorClass) {
  return defaultMappings[keys] = operatorClass;
};
Operation = (function() {
  __extends(Operation, Command);
  function Operation(count, motion) {
    this.count = count != null ? count : 1;
    this.motion = motion;
    if (this.motion) {
      this.motion.operation = this;
    }
  }
  Operation.prototype.isOperation = true;
  Operation.prototype.isComplete = function() {
    var _ref2;
    return (_ref2 = this.motion) != null ? _ref2.isComplete() : void 0;
  };
  Operation.prototype.switchToMode = 'normal';
  Operation.prototype.exec = function(jim) {
    var _ref2;
    this.startingPosition = jim.adaptor.position();
    jim.adaptor.setSelectionAnchor();
    if (this.count !== 1) {
      this.motion.count *= this.count;
      this.count = 1;
    }
    if ((_ref2 = this.linewise) == null) {
      this.linewise = this.motion.linewise;
    }
    this.motion.exec(jim);
    return this.visualExec(jim);
  };
  Operation.prototype.visualExec = function(jim) {
    var _ref2;
    if (this.linewise) {
      jim.adaptor.makeLinewise();
    } else if (!((_ref2 = this.motion) != null ? _ref2.exclusive : void 0)) {
      jim.adaptor.includeCursorInSelection();
    }
    this.operate(jim);
    if (this.repeatableInsert) {
      return jim.adaptor.insert(this.repeatableInsert.string);
    } else {
      if (this.switchToMode === 'insert') {
        jim.afterInsertSwitch = true;
      }
      if (this.switchToMode) {
        return jim.setMode(this.switchToMode);
      }
    }
  };
  return Operation;
})();
map('c', Change = (function() {
  __extends(Change, Operation);
  function Change() {
    Change.__super__.constructor.apply(this, arguments);
  }
  Change.prototype.operate = function(jim) {
    var _ref2;
    if (this.linewise) {
      jim.adaptor.moveToEndOfPreviousLine();
    }
    return jim.deleteSelection((_ref2 = this.motion) != null ? _ref2.exclusive : void 0, this.linewise);
  };
  Change.prototype.switchToMode = 'insert';
  return Change;
})());
map('d', Delete = (function() {
  __extends(Delete, Operation);
  function Delete() {
    Delete.__super__.constructor.apply(this, arguments);
  }
  Delete.prototype.operate = function(jim) {
    var _ref2;
    jim.deleteSelection((_ref2 = this.motion) != null ? _ref2.exclusive : void 0, this.linewise);
    if (this.linewise) {
      return new MoveToFirstNonBlank().exec(jim);
    }
  };
  return Delete;
})());
map('y', Yank = (function() {
  __extends(Yank, Operation);
  function Yank() {
    Yank.__super__.constructor.apply(this, arguments);
  }
  Yank.prototype.operate = function(jim) {
    var _ref2, _ref3;
    jim.yankSelection((_ref2 = this.motion) != null ? _ref2.exclusive : void 0, this.linewise);
    if (this.startingPosition) {
      return (_ref3 = jim.adaptor).moveTo.apply(_ref3, this.startingPosition);
    }
  };
  return Yank;
})());
map('>', Indent = (function() {
  __extends(Indent, Operation);
  function Indent() {
    Indent.__super__.constructor.apply(this, arguments);
  }
  Indent.prototype.operate = function(jim) {
    var maxRow, minRow, _ref2;
    _ref2 = jim.adaptor.selectionRowRange(), minRow = _ref2[0], maxRow = _ref2[1];
    jim.adaptor.indentSelection();
    return new GoToLine(minRow + 1).exec(jim);
  };
  return Indent;
})());
map('<', Outdent = (function() {
  __extends(Outdent, Operation);
  function Outdent() {
    Outdent.__super__.constructor.apply(this, arguments);
  }
  Outdent.prototype.operate = function(jim) {
    var maxRow, minRow, _ref2;
    _ref2 = jim.adaptor.selectionRowRange(), minRow = _ref2[0], maxRow = _ref2[1];
    jim.adaptor.outdentSelection();
    return new GoToLine(minRow + 1).exec(jim);
  };
  return Outdent;
})());
module.exports = {
  Change: Change,
  Delete: Delete,
  defaultMappings: defaultMappings
};
  return module.exports || exports;
})();

require['./commands'] = (function() {
  var exports = {}, module = {};
  var Change, ChangeChar, ChangeToEndOfLine, Command, Delete, DeleteChar, DeleteToEndOfLine, GoToLine, Insert, InsertAfter, InsertAtEndOfLine, InsertBeforeFirstNonBlank, JoinLines, JoinLinesNormalizingWhitespace, ModeSwitch, MoveDown, MoveLeft, MoveRight, MoveToEndOfLine, MoveToFirstNonBlank, OpenLine, OpenLineAbove, Paste, RepeatCommand, ReplaceSwitch, Undo, VisualLinewiseSwitch, VisualSwitch, defaultMappings, map, repeatCountTimes, _ref, _ref2, _ref3;
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
map('v', VisualSwitch = (function() {
  __extends(VisualSwitch, Command);
  function VisualSwitch() {
    VisualSwitch.__super__.constructor.apply(this, arguments);
  }
  VisualSwitch.prototype.isRepeatable = false;
  VisualSwitch.prototype.exec = function(jim) {
    var anchor;
    anchor = jim.adaptor.position();
    jim.adaptor.setSelectionAnchor();
    return jim.setMode('visual', {
      anchor: anchor
    });
  };
  VisualSwitch.prototype.visualExec = function(jim) {
    var _ref4;
    if (jim.mode.linewise) {
      jim.setMode('visual', {
        linewise: false
      });
      return (_ref4 = jim.adaptor.editor.selection).setSelectionAnchor.apply(_ref4, jim.mode.anchor);
    } else {
      return jim.onEscape();
    }
  };
  return VisualSwitch;
})());
map('V', VisualLinewiseSwitch = (function() {
  __extends(VisualLinewiseSwitch, Command);
  function VisualLinewiseSwitch() {
    VisualLinewiseSwitch.__super__.constructor.apply(this, arguments);
  }
  VisualLinewiseSwitch.prototype.isRepeatable = false;
  VisualLinewiseSwitch.prototype.exec = function(jim) {
    var anchor;
    anchor = jim.adaptor.setLinewiseSelectionAnchor();
    return jim.setMode('visual', {
      linewise: true,
      anchor: anchor
    });
  };
  VisualLinewiseSwitch.prototype.visualExec = function(jim) {
    var anchor, modeState;
    if (jim.mode.linewise) {
      return jim.onEscape();
    } else {
      modeState = {
        linewise: true
      };
      anchor = jim.adaptor.setLinewiseSelectionAnchor();
      if (!jim.mode.anchor) {
        modeState.anchor = anchor;
      }
      return jim.setMode('visual', modeState);
    }
  };
  return VisualLinewiseSwitch;
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
    if (jim.mode.linewise) {
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
  return module.exports || exports;
})();

require['./keymap'] = (function() {
  var exports = {}, module = {};
  var Keymap;
var __hasProp = Object.prototype.hasOwnProperty;
Keymap = (function() {
  var buildPartialCommandRegex;
  Keymap.getDefault = function() {
    var commandClass, keymap, keys, motionClass, operationClass, _ref, _ref2, _ref3;
    keymap = new Keymap;
    _ref = require('./commands').defaultMappings;
    for (keys in _ref) {
      if (!__hasProp.call(_ref, keys)) continue;
      commandClass = _ref[keys];
      keymap.mapCommand(keys, commandClass);
    }
    _ref2 = require('./operators').defaultMappings;
    for (keys in _ref2) {
      if (!__hasProp.call(_ref2, keys)) continue;
      operationClass = _ref2[keys];
      keymap.mapOperator(keys, operationClass);
    }
    _ref3 = require('./motions').defaultMappings;
    for (keys in _ref3) {
      if (!__hasProp.call(_ref3, keys)) continue;
      motionClass = _ref3[keys];
      keymap.mapMotion(keys, motionClass);
    }
    return keymap;
  };
  function Keymap() {
    this.commands = {};
    this.motions = {};
    this.visualCommands = {};
    this.partialCommands = {};
    this.partialMotions = {};
    this.partialVisualCommands = {};
  }
  Keymap.prototype.mapCommand = function(keys, commandClass) {
    if (commandClass.prototype.exec) {
      this.commands[keys] = commandClass;
      if (keys.length === 2) {
        this.partialCommands[keys[0]] = true;
      }
    }
    if (commandClass.prototype.visualExec) {
      this.visualCommands[keys] = commandClass;
      if (keys.length === 2) {
        return this.partialVisualCommands[keys[0]] = true;
      }
    }
  };
  Keymap.prototype.mapMotion = function(keys, motionClass) {
    this.commands[keys] = motionClass;
    this.motions[keys] = motionClass;
    this.visualCommands[keys] = motionClass;
    if (keys.length === 2) {
      this.partialMotions[keys[0]] = true;
      this.partialCommands[keys[0]] = true;
      return this.partialVisualCommands[keys[0]] = true;
    }
  };
  Keymap.prototype.mapOperator = function(keys, operatorClass) {
    this.commands[keys] = operatorClass;
    this.visualCommands[keys] = operatorClass;
    if (keys.length === 2) {
      this.partialCommands[keys[0]] = true;
      return this.partialVisualCommands[keys[0]] = true;
    }
  };
  buildPartialCommandRegex = function(partialCommands) {
    var char, nothing;
    return RegExp("^([1-9]\\d*)?([" + (((function() {
      var _results;
      _results = [];
      for (char in partialCommands) {
        if (!__hasProp.call(partialCommands, char)) continue;
        nothing = partialCommands[char];
        _results.push(char);
      }
      return _results;
    })()).join('')) + "]?([\\s\\S]*))?$");
  };
  Keymap.prototype.commandFor = function(commandPart) {
    var beyondPartial, command, commandClass, count, _ref;
    this.partialCommandRegex || (this.partialCommandRegex = buildPartialCommandRegex(this.partialCommands));
    _ref = commandPart.match(this.partialCommandRegex), commandPart = _ref[0], count = _ref[1], command = _ref[2], beyondPartial = _ref[3];
    if (beyondPartial) {
      if (commandClass = this.commands[command]) {
        return new commandClass(parseInt(count) || null);
      } else {
        return false;
      }
    } else {
      return true;
    }
  };
  Keymap.prototype.motionFor = function(commandPart, operatorPending) {
    var LinewiseCommandMotion, beyondPartial, count, motion, motionClass, _ref;
    this.partialMotionRegex || (this.partialMotionRegex = buildPartialCommandRegex(this.partialMotions));
    _ref = commandPart.match(this.partialCommandRegex), commandPart = _ref[0], count = _ref[1], motion = _ref[2], beyondPartial = _ref[3];
    if (beyondPartial) {
      if (motion === operatorPending) {
        LinewiseCommandMotion = require('./motions').LinewiseCommandMotion;
        return new LinewiseCommandMotion(parseInt(count) || null);
      } else if (motionClass = this.motions[motion]) {
        return new motionClass(parseInt(count) || null);
      } else {
        return false;
      }
    } else {
      return true;
    }
  };
  Keymap.prototype.visualCommandFor = function(commandPart) {
    var beyondPartial, command, commandClass, count, _ref;
    this.partialVisualCommandRegex || (this.partialVisualCommandRegex = buildPartialCommandRegex(this.partialVisualCommands));
    _ref = commandPart.match(this.partialVisualCommandRegex), commandPart = _ref[0], count = _ref[1], command = _ref[2], beyondPartial = _ref[3];
    if (beyondPartial) {
      if (commandClass = this.visualCommands[command]) {
        return new commandClass(parseInt(count) || null);
      } else {
        return false;
      }
    } else {
      return true;
    }
  };
  return Keymap;
})();
module.exports = Keymap;
  return module.exports || exports;
})();

require['./modes'] = (function() {
  var exports = {}, module = {};
  var MoveDown, MoveLeft, invalidCommand, _ref;
_ref = require('./motions'), MoveLeft = _ref.MoveLeft, MoveDown = _ref.MoveDown;
invalidCommand = function(type) {
  if (type == null) {
    type = 'command';
  }
  console.log("invalid " + type + ": " + this.commandPart);
  return this.onEscape();
};
exports.normal = {
  onKeypress: function(keys) {
    var command, motion, regex, _ref2, _ref3;
    this.commandPart = (this.commandPart || '') + keys;
    if (!this.command) {
      command = this.keymap.commandFor(this.commandPart);
      if (command === false) {
        invalidCommand.call(this);
      } else if (command !== true) {
        if (command.isOperation) {
          this.operatorPending = this.commandPart.match(/[^\d]+$/)[0];
        }
        this.command = command;
        this.commandPart = '';
      }
    } else if (this.command.constructor.followedBy) {
      if (this.command.constructor.followedBy.test(this.commandPart)) {
        this.command.followedBy = this.commandPart;
      } else {
        console.log("" + this.command + " didn't expect to be followed by \"" + this.commandPart + "\"");
      }
      this.commandPart = '';
    } else if (this.command.isOperation) {
      if (regex = (_ref2 = this.command.motion) != null ? _ref2.constructor.followedBy : void 0) {
        if (regex.test(this.commandPart)) {
          this.command.motion.followedBy = this.commandPart;
        } else {
          console.log("" + this.command + " didn't expect to be followed by \"" + this.commandPart + "\"");
        }
      } else {
        motion = this.keymap.motionFor(this.commandPart, this.operatorPending);
        if (motion === false) {
          invalidCommand.call(this, 'motion');
        } else if (motion !== true) {
          motion.operation = this.command;
          this.command.motion = motion;
          this.operatorPending = null;
          this.commandPart = '';
        }
      }
    }
    if ((_ref3 = this.command) != null ? _ref3.isComplete() : void 0) {
      this.command.exec(this);
      if (this.command.isRepeatable) {
        this.lastCommand = this.command;
      }
      return this.command = null;
    }
  }
};
exports.visual = {
  onKeypress: function(newKeys) {
    var command, maxRow, minRow, wasBackwards, _ref2, _ref3, _ref4;
    this.commandPart = (this.commandPart || '') + newKeys;
    if (!this.command) {
      command = this.keymap.visualCommandFor(this.commandPart);
      if (command === false) {
        invalidCommand.call(this);
      } else if (command !== true) {
        this.command = command;
        this.commandPart = '';
      }
    } else if (this.command.constructor.followedBy) {
      if (this.command.constructor.followedBy.test(this.commandPart)) {
        this.command.followedBy = this.commandPart;
      } else {
        console.log("" + this.command + " didn't expect to be followed by \"" + this.commandPart + "\"");
      }
      this.commandPart = '';
    }
    wasBackwards = this.adaptor.isSelectionBackwards();
    if (((_ref2 = this.command) != null ? _ref2.isOperation : void 0) || ((_ref3 = this.command) != null ? _ref3.isComplete() : void 0)) {
      if (this.command.isRepeatable) {
        this.command.selectionSize = this.mode.name === 'visual' && this.mode.linewise ? ((_ref4 = this.adaptor.selectionRowRange(), minRow = _ref4[0], maxRow = _ref4[1], _ref4), {
          lines: (maxRow - minRow) + 1
        }) : this.adaptor.characterwiseSelectionSize();
        this.command.linewise = this.mode.linewise;
        this.lastCommand = this.command;
      }
      this.command.visualExec(this);
      this.command = null;
    }
    if (this.mode.name === 'visual' && !this.mode.linewise) {
      if (wasBackwards) {
        if (!this.adaptor.isSelectionBackwards()) {
          return this.adaptor.adjustAnchor(-1);
        }
      } else {
        if (this.adaptor.isSelectionBackwards()) {
          return this.adaptor.adjustAnchor(1);
        }
      }
    }
  }
};
exports.insert = {
  onKeypress: function() {
    return true;
  }
};
exports.replace = {
  onKeypress: function() {
    return true;
  }
};
  return module.exports || exports;
})();

require['./jim'] = (function() {
  var exports = {}, module = {};
  var GoToLine, Jim, Keymap;
var __hasProp = Object.prototype.hasOwnProperty;
Keymap = require('./keymap');
GoToLine = require('./motions').GoToLine;
Jim = (function() {
  Jim.VERSION = '0.2.0-pre';
  function Jim(adaptor) {
    this.adaptor = adaptor;
    this.command = null;
    this.registers = {};
    this.keymap = Keymap.getDefault();
    this.setMode('normal');
  }
  Jim.prototype.modes = require('./modes');
  Jim.prototype.setMode = function(modeName, modeState) {
    var key, prevMode, value;
    if (this.debugMode) {
      console.log('setMode', modeName, modeState);
    }
    prevMode = this.mode;
    if (modeName === (prevMode != null ? prevMode.name : void 0)) {
      if (!modeState) {
        return;
      }
      for (key in modeState) {
        if (!__hasProp.call(modeState, key)) continue;
        value = modeState[key];
        this.mode[key] = value;
      }
    } else {
      this.mode = modeState || {};
      this.mode.name = modeName;
    }
    switch (prevMode != null ? prevMode.name : void 0) {
      case 'insert':
        this.adaptor.moveLeft();
        break;
      case 'replace':
        this.adaptor.setOverwriteMode(false);
    }
    return typeof this.onModeChange === "function" ? this.onModeChange(prevMode) : void 0;
  };
  Jim.prototype.onEscape = function() {
    this.setMode('normal');
    this.command = null;
    this.commandPart = '';
    return this.adaptor.clearSelection();
  };
  Jim.prototype.onKeypress = function(keys) {
    return this.modes[this.mode.name].onKeypress.call(this, keys);
  };
  Jim.prototype.deleteSelection = function(exclusive, linewise) {
    return this.registers['"'] = this.adaptor.deleteSelection(exclusive, linewise);
  };
  Jim.prototype.yankSelection = function(exclusive, linewise) {
    this.registers['"'] = this.adaptor.selectionText(exclusive, linewise);
    return this.adaptor.clearSelection(true);
  };
  return Jim;
})();
module.exports = Jim;
  return module.exports || exports;
})();

require['./ace'] = (function() {
  var exports = {}, module = {};
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
  function Adaptor(editor) {
    this.editor = editor;
  }
  atLineEnd = function(editor, beyond) {
    var lineLength, selectionLead;
    selectionLead = editor.selection.getSelectionLead();
    lineLength = editor.selection.doc.getLine(selectionLead.row).length;
    return selectionLead.column >= lineLength - (beyond ? 0 : 1);
  };
  beyondLineEnd = function(editor) {
    return atLineEnd(editor, true);
  };
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
    var lastVisibleRow, totalLines;
    totalLines = this.editor.selection.doc.$lines.length;
    lastVisibleRow = this.editor.renderer.getLastFullyVisibleRow();
    if (totalLines < lastVisibleRow) {
      return totalLines;
    } else {
      return lastVisibleRow;
    }
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
    var column, lastColumn, row, selection, _ref;
    selection = this.editor.selection;
    _ref = selection[selection.isEmpty() ? 'selectionLead' : 'selectionAnchor'], row = _ref.row, column = _ref.column;
    lastColumn = this.editor.session.getDocumentLastRowColumnPosition(row, column);
    selection.setSelectionAnchor(row, lastColumn);
    return [row, column];
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
require('pilot/dom').importCssString(".jim-normal-mode div.ace_cursor\n, .jim-visual-mode div.ace_cursor {\n  border: 0;\n  background-color: #91FF00;\n  opacity: 0.5;\n}\n.jim-visual-linewise-mode .ace_marker-layer .ace_selection {\n  left: 0 !important;\n  width: 100% !important;\n}");
isCharacterKey = function(hashId, keyCode) {
  return hashId === 0 && !keyCode;
};
Jim.aceInit = function(editor) {
  var adaptor, jim, undoManager;
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
          jim.setMode('visual');
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
    var mode, _i, _len, _ref;
    _ref = ['insert', 'normal', 'visual'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      mode = _ref[_i];
      editor[mode === this.mode.name ? 'setStyle' : 'unsetStyle']("jim-" + mode + "-mode");
    }
    editor[this.mode.name === 'visual' && this.mode.linewise ? 'setStyle' : 'unsetStyle']('jim-visual-linewise-mode');
    if (this.mode.name === 'insert') {
      undoManager.markUndoPoint(editor.session, 'jim:insert:start');
    } else if ((prevMode != null ? prevMode.name : void 0) === 'insert') {
      undoManager.markUndoPoint(editor.session, 'jim:insert:end');
      this.lastCommand.repeatableInsert = this.adaptor.lastInsert();
    }
    if (this.mode.name === 'replace') {
      return undoManager.markUndoPoint(editor.session, 'jim:replace:start');
    } else if ((prevMode != null ? prevMode.name : void 0) === 'replace') {
      return undoManager.markUndoPoint(editor.session, 'jim:replace:end');
    }
  };
  jim.onModeChange();
  return jim;
};
  return module.exports || exports;
})();

  return require['./jim'];
})()