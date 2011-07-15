(function() {
  var __hasProp = Object.prototype.hasOwnProperty;
  define(function(require, exports, module) {
    var Motion, WORDRegex, k, lastWORDRegex, lastWordRegex, motions, moveBackWord, moveNextWord, moveWordEnd, v, wordRegex;
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
      Motion.prototype.move = function(jim, count, operation) {
        var timesLeft, _results;
        timesLeft = count != null ? count : 1;
        _results = [];
        while (timesLeft--) {
          _results.push(this.moveOnce.call(jim, operation));
        }
        return _results;
      };
      Motion.prototype.change = function(jim, count) {
        this["delete"](jim, count, 'change');
        return jim.setMode('insert');
      };
      Motion.prototype["delete"] = function(jim, count, operation) {
        jim.adaptor.setSelectionAnchor();
        this.move(jim, count, operation != null ? operation : 'delete');
        adjustSelection.call(this, jim);
        if (operation === 'change' && this.linewise) {
          jim.adaptor.moveToEndOfPreviousLine();
        }
        return jim.deleteSelection(this.exclusive, this.linewise);
      };
      Motion.prototype.yank = function(jim, count) {
        jim.adaptor.setSelectionAnchor();
        this.move(jim, count, 'yank');
        adjustSelection.call(this, jim);
        return jim.yankSelection(this.exclusive, this.linewise);
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
    motions = {
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
        moveOnce: function(operation) {
          return this.adaptor.moveRight(operation != null);
        }
      }),
      W: new Motion({
        exclusive: true,
        moveOnce: function() {
          return moveNextWord.call(this, WORDRegex());
        },
        change: function(jim, count) {
          return motions['E'].change(jim, count);
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
          return motions['e'].change(jim, count);
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
            motions['j'].move(jim, additionalLines);
          }
          return jim.adaptor.moveToLineEnd();
        }
      }),
      G: new Motion({
        linewise: true,
        move: function(jim, count) {
          var column, lineNumber, lineText, _ref;
          lineNumber = count != null ? count : jim.adaptor.lastRow();
          lineText = jim.adaptor.lineText(lineNumber - 1);
          column = ((_ref = /\S/.exec(lineText)) != null ? _ref.index : void 0) || 0;
          return jim.adaptor.moveTo(lineNumber - 1, column);
        }
      })
    };
    motions.regex = RegExp("[" + (((function() {
      var _results;
      _results = [];
      for (k in motions) {
        if (!__hasProp.call(motions, k)) continue;
        v = motions[k];
        _results.push(k);
      }
      return _results;
    })()).join('')) + "]");
    return motions;
  });
}).call(this);
