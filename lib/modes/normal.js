(function() {
  var __slice = Array.prototype.slice;
  define(function(require, exports, module) {
    var commands, insertInNewLine, isRepeatable, makeLinewiseSelection, motions, paste, regex, util;
    motions = require('jim/motions');
    util = require('jim/util');
    insertInNewLine = function(below) {
      var row;
      row = this.adaptor.row() + (below ? 1 : 0);
      this.adaptor.insertNewLine(row);
      this.adaptor.moveTo(row, 0);
      return this.setMode('insert');
    };
    paste = function(count, after) {
      var beforeLineEnding, column, lastRow, lineEnding, linewiseRegister, registerValue, row, text, wholeString, _ref;
      if (!(registerValue = this.registers['"'])) {
        return;
      }
      text = new Array((count || 1) + 1).join(registerValue);
      linewiseRegister = /\n$/.test(registerValue);
      if (linewiseRegister) {
        row = this.adaptor.row() + (after ? 1 : 0);
        lastRow = this.adaptor.lastRow();
        if (row > lastRow) {
          _ref = /^([\s\S]*)(\r?\n)$/.exec(text), wholeString = _ref[0], beforeLineEnding = _ref[1], lineEnding = _ref[2];
          text = lineEnding + beforeLineEnding;
          column = this.adaptor.lineText(lastRow).length - 1;
          this.adaptor.moveTo(row, column);
        } else {
          this.adaptor.moveTo(row, 0);
        }
        this.adaptor.insert(text);
        return this.adaptor.moveTo(row, 0);
      } else {
        return this.adaptor.insert(text, after);
      }
    };
    makeLinewiseSelection = function(count) {
      var additionalLines, startingPosition;
      startingPosition = this.adaptor.position();
      this.adaptor.setSelectionAnchor();
      additionalLines = (count || 1) - 1;
      if (additionalLines) {
        motions.move(this, 'j', additionalLines);
      }
      return this.adaptor.makeLinewise();
    };
    commands = {
      a: function() {
        this.adaptor.moveRight(true);
        return this.setMode('insert');
      },
      A: function() {
        motions.move(this, '$');
        this.adaptor.moveRight(true);
        return this.setMode('insert');
      },
      C: function(count) {
        motions.execute(this, 'c', '$', count);
        return this.setMode('insert');
      },
      o: function() {
        return insertInNewLine.call(this, true);
      },
      O: function() {
        return insertInNewLine.call(this, false);
      },
      i: function() {
        return this.setMode('insert');
      },
      I: function() {
        motions.move(this, '^');
        return this.setMode('insert');
      },
      R: function() {
        this.adaptor.setOverwriteMode(true);
        return this.setMode('replace');
      },
      '.': function() {
        var insert, string, _base, _ref, _ref2;
        if (!this.lastCommand) {
          return;
        }
        if (this.lastCommand.simple) {
          return this.modes.normal.execute.call(this, this.lastCommand.simple);
        } else if (this.lastCommand.insert) {
                    if ((_ref = (_base = this.lastCommand).string) != null) {
            _ref;
          } else {
            _base.string = this.adaptor.lastRepeatableInsertString();
          };
          console.log('@lastCommand', this.lastCommand);
          _ref2 = this.lastCommand, insert = _ref2.insert, string = _ref2.string;
          this.modes.normal.execute.call(this, insert);
          this.adaptor.insert(string);
          return this.onEscape();
        }
      },
      J: function(count) {
        return this.joinLines(this.adaptor.row(), count || 2, true);
      },
      gJ: function(count) {
        return this.joinLines(this.adaptor.row(), count || 2, false);
      },
      D: function(count) {
        return motions.execute(this, 'd', '$', count);
      },
      p: function(count) {
        return paste.call(this, count, true);
      },
      P: function(count) {
        return paste.call(this, count, false);
      },
      s: function(count) {
        return motions.execute(this, 'c', 'l', count);
      },
      u: function(count) {
        var timesLeft, _results;
        timesLeft = count != null ? count : 1;
        _results = [];
        while (timesLeft--) {
          _results.push(this.adaptor.undo());
        }
        return _results;
      },
      x: function(count) {
        return motions.execute(this, 'd', 'l', count);
      },
      X: function(count) {
        return motions.execute(this, 'd', 'h', count);
      },
      cc: function(count) {
        makeLinewiseSelection.call(this, count);
        this.adaptor.moveToEndOfPreviousLine();
        this.deleteSelection();
        return this.setMode('insert');
      },
      dd: function(count) {
        makeLinewiseSelection.call(this, count);
        this.deleteSelection();
        return this.moveToFirstNonBlank();
      },
      yy: function(count) {
        var startingPosition, _ref;
        startingPosition = this.adaptor.position();
        makeLinewiseSelection.call(this, count);
        this.yankSelection();
        return (_ref = this.adaptor).moveTo.apply(_ref, startingPosition);
      },
      '>>': function(count) {
        var startingRow;
        startingRow = this.adaptor.row();
        makeLinewiseSelection.call(this, count);
        this.adaptor.indentSelection();
        return motions.move(this, 'G', startingRow + 1);
      },
      '<<': function(count) {
        var startingRow;
        startingRow = this.adaptor.row();
        makeLinewiseSelection.call(this, count);
        this.adaptor.outdentSelection();
        return motions.move(this, 'G', startingRow + 1);
      }
    };
    regex = RegExp("^([vV])|(?:([1-9]\\d*)?(?:(" + (util.propertyNameRegex(commands).source) + ")|(?:r([\\s\\S])?)|(?:([cdy><])?(" + motions.regex.source + ")?))?)$");
    isRepeatable = function(commandMatch, operator) {
      if (operator === 'y') {
        return false;
      }
      if (commandMatch === 'yy' || commandMatch === '.' || commandMatch === 'u') {
        return false;
      }
      return !!(commandMatch || operator);
    };
    return {
      execute: function(buffer) {
        var command, commandMatch, continueBuffering, count, countMatch, fullMatch, match, motionMatch, operator, replacementChar, replacementText, visualSwitch;
                if (buffer != null) {
          buffer;
        } else {
          buffer = this.buffer;
        };
        match = buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], visualSwitch = match[1], countMatch = match[2], commandMatch = match[3], replacementChar = match[4], operator = match[5], motionMatch = 7 <= match.length ? __slice.call(match, 6) : [];
        count = parseInt(countMatch) || null;
        continueBuffering = false;
        if (visualSwitch) {
          if (visualSwitch === 'V') {
            this.adaptor.setLinewiseSelectionAnchor();
            this.setMode('visual:linewise');
          } else {
            this.adaptor.setSelectionAnchor();
            this.setMode('visual:characterwise');
          }
        } else if (motionMatch[0]) {
          continueBuffering = motions.execute(this, operator, motionMatch, count);
        } else if (commandMatch && (command = commands[commandMatch])) {
          command.call(this, count);
        } else if (replacementChar) {
          this.adaptor.setSelectionAnchor();
          motions.move(this, 'l', count || 1);
          this.adaptor.deleteSelection();
          replacementText = /^\r?\n$/.test(replacementChar) ? replacementChar : new Array((count || 1) + 1).join(replacementChar);
          this.adaptor.insert(replacementText);
          motions.move(this, 'h');
        } else {
          continueBuffering = true;
        }
        if (!continueBuffering) {
          if (buffer !== '.') {
            switch (this.modeName) {
              case 'normal':
                if (replacementChar || isRepeatable(commandMatch, operator)) {
                  this.lastCommand = {
                    simple: buffer
                  };
                }
                break;
              case 'insert':
                this.lastCommand = {
                  insert: buffer
                };
            }
          }
          return this.clearBuffer();
        }
      }
    };
  });
}).call(this);
