(function() {
  var __hasProp = Object.prototype.hasOwnProperty;
  define(function(require, exports, module) {
    var Motion, WORDRegex, lastColumnWithChar, lastWORDRegex, lastWordRegex, moveBackWord, moveNextWord, moveWordEnd, nextColumnWithChar, simpleMotions, toCharMotions, util, wordRegex;
    util = require('jim/util');
    WORDRegex = function() {
      return /\S+/g;
    };
    wordRegex = function() {
      return /(\w+)|([^\w\s]+)/g;
    };
    lastWORDRegex = RegExp("" + (WORDRegex().source) + "\\s*$");
    lastWordRegex = RegExp("(" + (wordRegex().source) + ")\\s*$");
    moveWordEnd = function(regex) {
      var column, firstMatchOnSubsequentLine, line, nextMatch, rightOfCursor, row, thisMatch, _ref;
      line = this.adaptor.lineText();
      _ref = this.adaptor.position(), row = _ref[0], column = _ref[1];
      rightOfCursor = line.substring(column);
      if (column >= line.length - 1) {
        while (true) {
          line = this.adaptor.lineText(++row);
          firstMatchOnSubsequentLine = regex.exec(line);
          if (firstMatchOnSubsequentLine) {
            column = firstMatchOnSubsequentLine[0].length + firstMatchOnSubsequentLine.index - 1;
            break;
          } else if (row === this.adaptor.lastRow()) {
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
      return this.adaptor.moveTo(row, column);
    };
    moveNextWord = function(regex) {
      var column, line, nextLineMatch, nextMatch, rightOfCursor, row, thisMatch, _ref;
      line = this.adaptor.lineText();
      _ref = this.adaptor.position(), row = _ref[0], column = _ref[1];
      rightOfCursor = line.substring(column);
      thisMatch = regex.exec(rightOfCursor);
      if ((thisMatch != null ? thisMatch.index : void 0) > 0) {
        column += thisMatch.index;
      } else if (!thisMatch || !(nextMatch = regex.exec(rightOfCursor))) {
        line = this.adaptor.lineText(++row);
        nextLineMatch = regex.exec(line);
        column = (nextLineMatch != null ? nextLineMatch.index : void 0) || 0;
      } else {
        column += nextMatch.index;
      }
      return this.adaptor.moveTo(row, column);
    };
    moveBackWord = function(regex) {
      var column, leftOfCursor, line, match, row, _ref;
      line = this.adaptor.lineText();
      _ref = this.adaptor.position(), row = _ref[0], column = _ref[1];
      leftOfCursor = line.substring(0, column);
      match = regex.exec(leftOfCursor);
      if (match) {
        column = match.index;
      } else {
        while (true) {
          line = this.adaptor.lineText(--row);
          if (!/^\s+$/.test(line)) {
            break;
          }
        }
        match = regex.exec(line);
        column = (match != null ? match.index : void 0) || 0;
      }
      return this.adaptor.moveTo(row, column);
    };
    nextColumnWithChar = function(char, count) {
      var column, columnsRight, rightOfCursor, row, timesLeft, _ref;
      timesLeft = count != null ? count : 1;
      _ref = this.adaptor.position(), row = _ref[0], column = _ref[1];
      rightOfCursor = this.adaptor.lineText().substring(column + 1);
      columnsRight = 0;
      while (timesLeft--) {
        columnsRight = rightOfCursor.indexOf(char, columnsRight) + 1;
      }
      if (columnsRight) {
        return [row, column + columnsRight];
      }
    };
    lastColumnWithChar = function(char, count) {
      var column, leftOfCursor, row, targetColumn, timesLeft, _ref;
      timesLeft = count != null ? count : 1;
      _ref = this.adaptor.position(), row = _ref[0], column = _ref[1];
      leftOfCursor = this.adaptor.lineText().substring(0, column);
      targetColumn = column;
      while (timesLeft--) {
        targetColumn = leftOfCursor.lastIndexOf(char, targetColumn - 1);
      }
      if ((0 <= targetColumn && targetColumn < column)) {
        return [row, targetColumn];
      }
    };
    Motion = (function() {
      var adjustSelection;
      function Motion(props) {
        var key, value, _ref, _ref2;
        for (key in props) {
          if (!__hasProp.call(props, key)) continue;
          value = props[key];
          this[key] = value;
        }
                if ((_ref = this.linewise) != null) {
          _ref;
        } else {
          this.linewise = false;
        };
                if ((_ref2 = this.exclusive) != null) {
          _ref2;
        } else {
          this.exclusive = false;
        };
      }
      Motion.prototype.move = function(jim, count, options, operation) {
        var timesLeft, _results;
        timesLeft = count != null ? count : 1;
        _results = [];
        while (timesLeft--) {
          _results.push(this.moveOnce.call(jim, options, operation));
        }
        return _results;
      };
      Motion.prototype.change = function(jim, count, options) {
        this["delete"](jim, count, options, 'change');
        return jim.setMode('insert');
      };
      Motion.prototype["delete"] = function(jim, count, options, operation) {
        jim.adaptor.setSelectionAnchor();
        this.move(jim, count, options, operation != null ? operation : 'delete');
        adjustSelection.call(this, jim);
        if (operation === 'change' && this.linewise) {
          jim.adaptor.moveToEndOfPreviousLine();
        }
        return jim.deleteSelection(this.exclusive, this.linewise);
      };
      Motion.prototype.yank = function(jim, count, options) {
        jim.adaptor.setSelectionAnchor();
        this.move(jim, count, options, 'yank');
        adjustSelection.call(this, jim);
        return jim.yankSelection(this.exclusive, this.linewise);
      };
      Motion.prototype.indent = function(jim, count, options) {
        jim.adaptor.setSelectionAnchor();
        this.move(jim, count, options, 'indent');
        adjustSelection.call(this, jim);
        return jim.indentSelection();
      };
      Motion.prototype.outdent = function(jim, count, options) {
        jim.adaptor.setSelectionAnchor();
        this.move(jim, count, options, 'outdent');
        adjustSelection.call(this, jim);
        return jim.outdentSelection();
      };
      adjustSelection = function(jim) {
        if (this.linewise) {
          return jim.adaptor.makeLinewise();
        } else if (!this.exclusive) {
          return jim.adaptor.includeCursorInSelection();
        }
      };
      return Motion;
    })();
    simpleMotions = {
      h: new Motion({
        exclusive: true,
        moveOnce: function() {
          return this.adaptor.moveLeft();
        }
      }),
      j: new Motion({
        linewise: true,
        moveOnce: function() {
          return this.adaptor.moveDown();
        }
      }),
      k: new Motion({
        linewise: true,
        moveOnce: function() {
          return this.adaptor.moveUp();
        }
      }),
      l: new Motion({
        exclusive: true,
        moveOnce: function(options, operation) {
          return this.adaptor.moveRight(operation != null);
        }
      }),
      W: new Motion({
        exclusive: true,
        moveOnce: function() {
          return moveNextWord.call(this, WORDRegex());
        },
        change: function(jim, count) {
          return simpleMotions['E'].change(jim, count);
        }
      }),
      E: new Motion({
        moveOnce: function() {
          return moveWordEnd.call(this, WORDRegex());
        }
      }),
      B: new Motion({
        exclusive: true,
        moveOnce: function() {
          return moveBackWord.call(this, lastWORDRegex);
        }
      }),
      w: new Motion({
        exclusive: true,
        moveOnce: function() {
          return moveNextWord.call(this, wordRegex());
        },
        change: function(jim, count) {
          return simpleMotions['e'].change(jim, count);
        }
      }),
      e: new Motion({
        moveOnce: function() {
          return moveWordEnd.call(this, wordRegex());
        }
      }),
      b: new Motion({
        exclusive: true,
        moveOnce: function() {
          return moveBackWord.call(this, lastWordRegex);
        }
      }),
      0: new Motion({
        exclusive: true,
        move: function(jim) {
          return jim.adaptor.moveTo(jim.adaptor.row(), 0);
        }
      }),
      '^': new Motion({
        move: function(jim) {
          return jim.moveToFirstNonBlank();
        }
      }),
      $: new Motion({
        move: function(jim, count) {
          var additionalLines;
          additionalLines = (count != null ? count : 1) - 1;
          if (additionalLines) {
            simpleMotions['j'].move(jim, additionalLines);
          }
          return jim.adaptor.moveToLineEnd();
        }
      }),
      G: new Motion({
        linewise: true,
        move: function(jim, count) {
          var column, lineNumber, lineText, _ref;
          lineNumber = count != null ? count : jim.adaptor.lastRow() + 1;
          lineText = jim.adaptor.lineText(lineNumber - 1);
          column = ((_ref = /\S/.exec(lineText)) != null ? _ref.index : void 0) || 0;
          return jim.adaptor.moveTo(lineNumber - 1, column);
        }
      }),
      gg: new Motion({
        linewise: true,
        move: function(jim, count) {
          return simpleMotions['G'].move(jim, count != null ? count : 1);
        }
      }),
      H: new Motion({
        linewise: true,
        move: function(jim, count) {
          var line;
          line = jim.adaptor.firstFullyVisibleRow() + (count != null ? count : 1);
          return simpleMotions['G'].move(jim, line);
        }
      }),
      M: new Motion({
        linewise: true,
        move: function(jim, count) {
          var lines, linesFromTop, topRow;
          topRow = jim.adaptor.firstFullyVisibleRow();
          lines = jim.adaptor.lastFullyVisibleRow() - topRow;
          linesFromTop = lines / 2;
          return simpleMotions['G'].move(jim, topRow + 1 + linesFromTop);
        }
      }),
      L: new Motion({
        linewise: true,
        move: function(jim, count) {
          var line;
          line = jim.adaptor.lastFullyVisibleRow() + 2 - (count != null ? count : 1);
          return simpleMotions['G'].move(jim, line);
        }
      }),
      '/': new Motion({
        exclusive: true,
        move: function(jim, count) {
          var pattern, timesLeft, _results;
          timesLeft = count != null ? count : 1;
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
        }
      }),
      '?': new Motion({
        exclusive: true,
        move: function(jim, count) {
          var pattern, timesLeft, _results;
          timesLeft = count != null ? count : 1;
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
        }
      }),
      n: new Motion({
        exclusive: true,
        move: function(jim, count) {
          var func, timesLeft, _results;
          if (!jim.search) {
            return;
          }
          timesLeft = count != null ? count : 1;
          func = jim.search.backwards ? 'findPrevious' : 'findNext';
          _results = [];
          while (timesLeft--) {
            _results.push(jim.adaptor[func](jim.search.pattern));
          }
          return _results;
        }
      }),
      N: new Motion({
        exclusive: true,
        move: function(jim, count) {
          var func, timesLeft, _results;
          if (!jim.search) {
            return;
          }
          timesLeft = count != null ? count : 1;
          func = jim.search.backwards ? 'findNext' : 'findPrevious';
          _results = [];
          while (timesLeft--) {
            _results.push(jim.adaptor[func](jim.search.pattern));
          }
          return _results;
        }
      })
    };
    toCharMotions = {
      f: new Motion({
        move: function(jim, count, options) {
          var position, _ref;
          position = nextColumnWithChar.call(jim, options.char, count);
          if (position) {
            return (_ref = jim.adaptor).moveTo.apply(_ref, position);
          }
        }
      }),
      F: new Motion({
        move: function(jim, count, options) {
          var position, _ref;
          position = lastColumnWithChar.call(jim, options.char, count);
          if (position) {
            return (_ref = jim.adaptor).moveTo.apply(_ref, position);
          }
        }
      }),
      t: new Motion({
        move: function(jim, count, options) {
          var position;
          position = nextColumnWithChar.call(jim, options.char, count);
          if (position) {
            return jim.adaptor.moveTo(position[0], position[1] - 1);
          }
        }
      }),
      T: new Motion({
        move: function(jim, count, options) {
          var position;
          position = lastColumnWithChar.call(jim, options.char, count);
          if (position) {
            return jim.adaptor.moveTo(position[0], position[1] + 1);
          }
        }
      })
    };
    return {
      regex: RegExp("([1-9]\\d*)?(?:(" + (util.propertyNameRegex(simpleMotions).source) + ")|([fFtT])(.)?)"),
      move: function(jim, keys, operatorCount) {
        return this.execute(jim, null, keys, operatorCount);
      },
      execute: function(jim, operator, matchOrKeys, operatorCount) {
        var char, count, fullMatch, motion, motionToChar, options, simpleMatch;
        if (typeof matchOrKeys === 'string') {
          simpleMatch = matchOrKeys;
        } else {
          fullMatch = matchOrKeys[0], count = matchOrKeys[1], simpleMatch = matchOrKeys[2], motionToChar = matchOrKeys[3], char = matchOrKeys[4];
        }
        if (simpleMatch) {
          motion = simpleMotions[simpleMatch];
        } else if (char) {
          motion = toCharMotions[motionToChar];
          options = {
            char: char
          };
        }
        if (motion) {
          if (count || operatorCount) {
            count = (parseInt(count) || 1) * (operatorCount || 1);
          }
          switch (operator) {
            case 'c':
              motion.change(jim, count, options);
              break;
            case 'd':
              motion["delete"](jim, count, options);
              break;
            case 'y':
              motion.yank(jim, count, options);
              break;
            case '>':
              motion.indent(jim, count, options);
              break;
            case '<':
              motion.outdent(jim, count, options);
              break;
            default:
              motion.move(jim, count, options);
          }
          return false;
        } else {
          return !!fullMatch;
        }
      }
    };
  });
}).call(this);
