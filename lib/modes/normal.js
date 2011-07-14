(function() {
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([iaoOIAC])|([vV])|(D)|(?:([1-9]\\d*)?(?:([pPsxXu])|(?:([cdy])?([1-9]\\d*)?(" + motions.regex.source + ")?))?)$");
    return {
      execute: function() {
        var after, command, continueBuffering, count, countMatch, deleteCommand, deleteMotion, fullMatch, match, motion, motionCount, motionCountMatch, motionObj, row, text, timesLeft, visualSwitch;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], this.insertSwitch = match[1], visualSwitch = match[2], deleteCommand = match[3], countMatch = match[4], command = match[5], this.operator = match[6], motionCountMatch = match[7], motion = match[8];
        count = parseInt(countMatch) || null;
        motionCount = parseInt(motionCountMatch) || null;
        continueBuffering = false;
        if (this.insertSwitch) {
          switch (this.insertSwitch) {
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
              row = this.adaptor.row() + (this.insertSwitch === 'o' ? 1 : 0);
              this.adaptor.insertNewLine(row);
              this.adaptor.moveTo(row, 0);
              break;
            case 'I':
              this.adaptor.navigateLineStart();
          }
          this.setMode('insert');
        } else if (visualSwitch) {
          this.adaptor.setSelectionAnchor();
          if (visualSwitch === 'V') {
            this.setMode('visual:linewise');
          } else {
            this.setMode('visual:characterwise');
          }
        } else if (deleteCommand) {
          motions['$']["delete"](this);
        } else if (motion) {
          motionObj = motions[motion];
          if (count || motionCount) {
            motionCount = (count || 1) * (motionCount || 1);
          }
          switch (this.operator) {
            case 'c':
              motionObj.change(this, motionCount);
              break;
            case 'd':
              motionObj["delete"](this, motionCount);
              break;
            case 'y':
              motionObj.yank(this, motionCount);
              break;
            default:
              motionObj.move(this, motionCount);
          }
        } else if (command) {
          switch (command) {
            case "p":
            case "P":
              text = new Array((count || 1) + 1).join(this.registers['"']);
              after = command === "p";
              this.adaptor.insert(text, after);
              break;
            case 's':
              motions['l'].change(this, count);
              break;
            case "x":
            case "X":
              deleteMotion = command === 'X' ? 'h' : 'l';
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
