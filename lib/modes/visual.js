(function() {
  var __slice = Array.prototype.slice;
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([1-9]\\d*)?(?:([pP])|(?:(" + motions.regex.source + ")|([ydc])))?$");
    return {
      execute: function() {
        var command, continueBuffering, count, countMatch, fullMatch, match, motionMatch, operator, registerValue, textToPaste, wasBackwards, _i;
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
          }
        } else if (operator) {
          if (this.modeName === 'visual:linewise') {
            this.adaptor.makeLinewise();
          } else {
            this.adaptor.includeCursorInSelection();
          }
          switch (operator) {
            case 'c':
            case 'd':
              this.deleteSelection();
              this.setMode(operator === 'c' ? 'insert' : 'normal');
              break;
            case 'y':
              this.yankSelection();
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
