(function() {
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([iaoOIAC])|([vV])|(D)|(?:([cdy])?([1-9]\\d*)?(?:(" + motions.regex.source + ")|([[pPsxXu]))?)$");
    return {
      execute: function() {
        var after, continueBuffering, count, countMatch, deleteCommand, deleteMotion, fullMatch, match, motion, motionObj, multipliableCommand, row, text, timesLeft, visualTransition;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], this.insertTransition = match[1], visualTransition = match[2], deleteCommand = match[3], this.operator = match[4], countMatch = match[5], motion = match[6], multipliableCommand = match[7];
        count = parseInt(countMatch) || null;
        continueBuffering = false;
        if (this.insertTransition) {
          switch (this.insertTransition) {
            case 'a':
              this.adaptor.moveRight(true);
              break;
            case 'A':
              motions['$'].move(this);
              this.adaptor.moveRight(true);
              break;
            case 'C':
              motions['$'].change(this);
              break;
            case 'o':
            case 'O':
              row = this.adaptor.row() + (this.insertTransition === 'o' ? 1 : 0);
              this.adaptor.insertNewLine(row);
              this.adaptor.moveTo(row, 0);
              break;
            case 'I':
              this.adaptor.navigateLineStart();
          }
          this.setMode('insert');
        } else if (visualTransition) {
          this.adaptor.setSelectionAnchor();
          if (visualTransition === 'V') {
            this.setMode('visual:linewise');
          } else {
            this.setMode('visual:characterwise');
          }
        } else if (deleteCommand) {
          motions['$']["delete"](this);
        } else if (motion) {
          motionObj = motions[motion];
          switch (this.operator) {
            case 'c':
              motionObj.change(this, count);
              break;
            case 'd':
              motionObj["delete"](this, count);
              break;
            case 'y':
              motionObj.yank(this, count);
              break;
            default:
              motionObj.move(this, count);
          }
        } else if (multipliableCommand) {
          switch (multipliableCommand) {
            case "p":
            case "P":
              text = new Array((count || 1) + 1).join(this.registers['"']);
              after = multipliableCommand === "p";
              this.adaptor.insert(text, after);
              break;
            case 's':
              motions['l'].change(this, count);
              break;
            case "x":
            case "X":
              deleteMotion = multipliableCommand === 'X' ? 'h' : 'l';
              motions[deleteMotion]["delete"](this, count);
              break;
            case "u":
              timesLeft = count != null ? count : 1;
              while (timesLeft--) {
                this.adaptor.undo();
              }
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
