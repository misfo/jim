define(function(require, exports, module) {

var Command, GoToLine, GoToLineOrEnd, GoToNextChar, GoToPreviousChar, GoUpToNextChar, GoUpToPreviousChar, LinewiseCommandMotion, Motion, MoveBackBigWord, MoveBackWord, MoveDown, MoveLeft, MoveRight, MoveToBigWordEnd, MoveToEndOfLine, MoveToFirstNonBlank, MoveToNextBigWord, MoveToNextWord, MoveToWordEnd, MoveUp, WORDRegex, defaultMappings, lastWORDRegex, lastWordRegex, map, repeatCountTimes, wordCursorIsOn, wordRegex, _ref;
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
wordCursorIsOn = function(line, column) {
  var leftMatch, leftOfCursor, rightMatch, rightOfCursor;
  leftOfCursor = line.substring(0, column);
  rightOfCursor = line.substring(column);
  leftMatch = /(\w|\d)*$/.exec(leftOfCursor);
  rightMatch = /^(\w|\d)*/.exec(rightOfCursor);
  return leftMatch[0] + rightMatch[0];
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
  MoveToNextWord.prototype.exec = repeatCountTimes(function(jim) {
    var column, line, nextLineMatch, nextMatch, regex, rightOfCursor, row, thisMatch, _ref2;
    regex = this.bigWord ? WORDRegex() : wordRegex();
    line = jim.adaptor.lineText();
    _ref2 = jim.adaptor.position(), row = _ref2[0], column = _ref2[1];
    rightOfCursor = line.substring(column);
    thisMatch = regex.exec(rightOfCursor);
    if ((thisMatch != null ? thisMatch.index : void 0) > 0) {
      column += thisMatch.index;
    } else if (!thisMatch || !(nextMatch = regex.exec(rightOfCursor))) {
      line = jim.adaptor.lineText(++row);
      nextLineMatch = regex.exec(line);
      column = (nextLineMatch != null ? nextLineMatch.index : void 0) || 0;
    } else {
      column += nextMatch.index;
    }
    return jim.adaptor.moveTo(row, column);
  });
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
    return literalMotions['G'].move(jim, line);
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
    linesFromTop = lines / 2;
    return literalMotions['G'].move(jim, topRow + 1 + linesFromTop);
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
    return literalMotions['G'].move(jim, line);
  };
  return _Class;
})());
map('/', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    var pattern, timesLeft, _results;
    timesLeft = this.count;
    pattern = prompt("Find:");
    jim.search = {
      pattern: pattern,
      backwards: false
    };
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor.findNext(pattern));
    }
    return _results;
  };
  return _Class;
})());
map('?', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    var pattern, timesLeft, _results;
    timesLeft = this.count;
    pattern = prompt("Find:");
    jim.search = {
      pattern: pattern,
      backwards: true
    };
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor.findPrevious(pattern));
    }
    return _results;
  };
  return _Class;
})());
map('*', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    var adaptor, pattern, timesLeft, _results;
    timesLeft = this.count;
    adaptor = jim.adaptor;
    pattern = wordCursorIsOn(adaptor.lineText(), adaptor.column());
    jim.search = {
      pattern: pattern,
      backwards: false
    };
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor.findNext(pattern));
    }
    return _results;
  };
  return _Class;
})());
map('#', (function() {
  __extends(_Class, Motion);
  function _Class() {
    _Class.__super__.constructor.apply(this, arguments);
  }
  _Class.prototype.exclusive = true;
  _Class.prototype.exec = function(jim) {
    var adaptor, pattern, timesLeft, _results;
    timesLeft = this.count;
    adaptor = jim.adaptor;
    pattern = wordCursorIsOn(adaptor.lineText(), adaptor.column());
    jim.search = {
      pattern: pattern,
      backwards: true
    };
    _results = [];
    while (timesLeft--) {
      _results.push(jim.adaptor.findPrevious(pattern));
    }
    return _results;
  };
  return _Class;
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
      _results.push(jim.adaptor[func](jim.search.pattern));
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
      _results.push(jim.adaptor[func](jim.search.pattern));
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

});