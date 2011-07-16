(function() {
  var __slice = Array.prototype.slice;
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([1-9]\\d*)?(?:(" + motions.regex.source + ")|([ydc]))?$");
    return {
      execute: function() {
        var continueBuffering, count, countMatch, fullMatch, match, motionMatch, operator, wasBackwards, _i;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], countMatch = match[1], motionMatch = 4 <= match.length ? __slice.call(match, 2, _i = match.length - 1) : (_i = 2, []), operator = match[_i++];
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
