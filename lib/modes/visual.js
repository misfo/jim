(function() {
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^(\\d*)(?:(" + motions.regex.source + ")|([ydc]))?");
    return {
      execute: function() {
        var continueBuffering, fullMatch, match, motion, numberPrefix, operator;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], numberPrefix = match[1], motion = match[2], operator = match[3];
        if (numberPrefix) {
          numberPrefix = parseInt(numberPrefix);
        }
        continueBuffering = false;
        if (motion) {
          motions.execute.call(this, '', numberPrefix, motion);
        } else if (operator) {
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
