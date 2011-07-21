(function() {
  var __slice = Array.prototype.slice;
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([vV])|(?:([1-9]\\d*)?(?:([iaoOIAC])|([DpPsxXu])|(?:r([\\s\\S])?)|(cc|dd|yy)|(?:([cdy])?(" + motions.regex.source + ")?))?)$");
    return {
      execute: function() {
        var additionalLines, after, beforeLineEnding, column, command, continueBuffering, count, countMatch, deleteMotion, fullMatch, insertSwitch, lastRow, lineEnding, linewiseCommand, linewiseRegister, match, motionMatch, operator, registerValue, replacementChar, replacementText, row, startingPosition, text, timesLeft, visualSwitch, wholeString, _ref, _ref2;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], visualSwitch = match[1], countMatch = match[2], insertSwitch = match[3], command = match[4], replacementChar = match[5], linewiseCommand = match[6], operator = match[7], motionMatch = 9 <= match.length ? __slice.call(match, 8) : [];
        count = parseInt(countMatch) || null;
        continueBuffering = false;
        if (insertSwitch) {
          switch (insertSwitch) {
            case 'a':
              this.adaptor.moveRight(true);
              break;
            case 'A':
              motions.move(this, '$');
              this.adaptor.moveRight(true);
              break;
            case 'C':
              motions.execute(this, 'c', '$', count);
              break;
            case 'o':
            case 'O':
              row = this.adaptor.row() + (insertSwitch === 'o' ? 1 : 0);
              this.adaptor.insertNewLine(row);
              this.adaptor.moveTo(row, 0);
              break;
            case 'I':
              motions.move(this, '^');
          }
          this.setMode('insert');
        } else if (visualSwitch) {
          this.adaptor.setSelectionAnchor();
          if (visualSwitch === 'V') {
            this.setMode('visual:linewise');
          } else {
            this.setMode('visual:characterwise');
          }
        } else if (motionMatch[0]) {
          continueBuffering = motions.execute(this, operator, motionMatch, count);
        } else if (command) {
          switch (command) {
            case 'D':
              motions.execute(this, 'd', '$', count);
              break;
            case 'p':
            case 'P':
              if (registerValue = this.registers['"']) {
                text = new Array((count || 1) + 1).join(registerValue);
                after = command === "p";
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
                  this.adaptor.moveTo(row, 0);
                } else {
                  this.adaptor.insert(text, after);
                }
              }
              break;
            case 's':
              motions.execute(this, 'c', 'l', count);
              break;
            case "x":
            case "X":
              deleteMotion = command === 'X' ? 'h' : 'l';
              motions.execute(this, 'd', deleteMotion, count);
              break;
            case "u":
              timesLeft = count != null ? count : 1;
              while (timesLeft--) {
                this.adaptor.undo();
              }
          }
        } else if (replacementChar) {
          this.adaptor.setSelectionAnchor();
          motions.move(this, 'l', count || 1);
          this.adaptor.deleteSelection();
          replacementText = /^\r?\n$/.test(replacementChar) ? replacementChar : new Array((count || 1) + 1).join(replacementChar);
          this.adaptor.insert(replacementText);
          motions.move(this, 'h');
        } else if (linewiseCommand) {
          startingPosition = this.adaptor.position();
          this.adaptor.setSelectionAnchor();
          additionalLines = (count || 1) - 1;
          if (additionalLines) {
            motions.move(this, 'j', additionalLines);
          }
          this.adaptor.makeLinewise();
          switch (linewiseCommand) {
            case 'cc':
              this.adaptor.moveToEndOfPreviousLine();
              this.deleteSelection();
              this.setMode('insert');
              break;
            case 'dd':
              this.deleteSelection();
              this.moveToFirstNonBlank();
              break;
            case 'yy':
              this.yankSelection();
              (_ref2 = this.adaptor).moveTo.apply(_ref2, startingPosition);
          }
        } else {
          continueBuffering = true;
        }
        if (!continueBuffering) {
          return this.clearBuffer();
        }
      }
    };
  });
}).call(this);
