(function() {
  var __hasProp = Object.prototype.hasOwnProperty;
  define(function(require, exports, module) {
    var WORDRegex, k, keymap, lastWORDRegex, lastWordRegex, moveBackWord, moveNextWord, moveWordEnd, v, wordRegex;
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
    keymap = {
      h: {
        exclusive: true,
        func: function() {
          return this.adaptor.moveLeft();
        }
      },
      j: {
        linewise: true,
        func: function() {
          return this.adaptor.moveDown();
        }
      },
      k: {
        linewise: true,
        func: function() {
          return this.adaptor.moveUp();
        }
      },
      l: {
        exclusive: true,
        func: function() {
          return this.adaptor.moveRight();
        }
      },
      W: {
        exclusive: true,
        func: function() {
          return moveNextWord.call(this, WORDRegex());
        }
      },
      E: {
        func: function() {
          return moveWordEnd.call(this, WORDRegex());
        }
      },
      B: {
        exclusive: true,
        func: function() {
          return moveBackWord.call(this, lastWORDRegex);
        }
      },
      w: {
        exclusive: true,
        func: function() {
          return moveNextWord.call(this, wordRegex());
        }
      },
      e: {
        func: function() {
          return moveWordEnd.call(this, wordRegex());
        }
      },
      b: {
        exclusive: true,
        func: function() {
          return moveBackWord.call(this, lastWordRegex);
        }
      }
    };
    return {
      regex: RegExp("[" + (((function() {
        var _results;
        _results = [];
        for (k in keymap) {
          if (!__hasProp.call(keymap, k)) continue;
          v = keymap[k];
          _results.push(k);
        }
        return _results;
      })()).join('')) + "]"),
      execute: function(operator, count, motion) {
        var exclusive, func, linewise, _ref;
        if (operator === 'c') {
          switch (motion) {
            case 'W':
              motion = 'E';
              break;
            case 'w':
              motion = 'e';
          }
        }
        _ref = keymap[motion], func = _ref.func, exclusive = _ref.exclusive, linewise = _ref.linewise;
        if (operator) {
          this.adaptor.setSelectionAnchor();
        }
        this.times(count, func);
        switch (operator) {
          case 'c':
          case 'd':
            this.deleteSelection(exclusive, linewise, operator);
            if (operator === 'c') {
              return this.setMode('insert');
            }
            break;
          case 'y':
            return this.yankSelection(exclusive, linewise);
        }
      }
    };
  });
}).call(this);
