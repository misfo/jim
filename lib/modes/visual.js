(function() {
  var __slice = Array.prototype.slice;
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([1-9]\\d*)?(?:([pPJ]|gJ?)|(?:(" + motions.regex.source + ")|([ydc><])))?$");
    return {
      execute: function() {
        var command, continueBuffering, count, countMatch, fullMatch, match, motionMatch, operator, registerValue, rowEnd, rowStart, textToPaste, wasBackwards, _i, _ref;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], countMatch = match[1], command = match[2], motionMatch = 5 <= match.length ? __slice.call(match, 3, _i = match.length - 1) : (_i = 3, []), operator = match[_i++];
        count = parseInt(countMatch) || null;
        continueBuffering = false;
        if (motionMatch[0]) {
          wasBackwards = this.adaptor.isSelectionBackwards();
          motions.move(this, motionMatch, count);
          if (wasBackwards) {
            if (!this.adaptor.isSelectionBackwards()) {
              this.adaptor.adjustAnchor(-1);
            }
          } else {
            if (this.adaptor.isSelectionBackwards()) {
              this.adaptor.adjustAnchor(1);
            }
          }
        } else if (command) {
          switch (command) {
            case 'J':
            case 'gJ':
              _ref = this.adaptor.selectionRowRange(), rowStart = _ref[0], rowEnd = _ref[1];
              this.joinLines(rowStart, rowEnd - rowStart + 1, command === 'J');
              this.setMode('normal');
              break;
            case 'p':
            case 'P':
              registerValue = this.registers['"'];
              this.adaptor.includeCursorInSelection();
              if (registerValue) {
                textToPaste = new Array((count || 1) + 1).join(registerValue);
                this.deleteSelection();
                this.adaptor.insert(textToPaste);
              } else {
                this.yankSelection();
              }
              this.setMode('normal');
              break;
            default:
              continueBuffering = true;
          }
        } else if (operator) {
          if (this.modeName === 'visual:linewise') {
            this.adaptor.makeLinewise();
          } else {
            this.adaptor.includeCursorInSelection();
          }
          switch (operator) {
            case 'c':
              if (this.modeName === 'visual:linewise') {
                this.adaptor.moveToEndOfPreviousLine();
              }
              this.deleteSelection();
              this.setMode('insert');
              break;
            case 'd':
              this.deleteSelection();
              this.setMode('normal');
              break;
            case 'y':
              this.yankSelection();
              this.setMode('normal');
              break;
            case '>':
              this.indentSelection();
              this.setMode('normal');
              break;
            case '<':
              this.outdentSelection();
              this.setMode('normal');
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
