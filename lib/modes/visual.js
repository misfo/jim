(function() {
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([1-9]\\d*)?(?:(" + motions.regex.source + ")|([ydc]))?$");
    return {
      execute: function() {
        var continueBuffering, count, countMatch, fullMatch, match, motion, operator, wasBackwards;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], countMatch = match[1], motion = match[2], operator = match[3];
        count = parseInt(countMatch) || null;
        continueBuffering = false;
        if (motion) {
          wasBackwards = this.adaptor.isSelectionBackwards();
          motions[motion].move(this, count);
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
          }
          switch (operator) {
            case 'c':
            case 'd':
              if (this.modeName !== 'visual:linewise') {
                this.adaptor.includeCursorInSelection();
              }
              this.deleteSelection();
              this.setMode(operator === 'c' ? 'insert' : 'normal');
              break;
            case 'y':
              this.adaptor.includeCursorInSelection();
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
