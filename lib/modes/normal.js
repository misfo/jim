(function() {
  define(function(require, exports, module) {
    var motions, regex;
    motions = require('jim/motions');
    regex = RegExp("^([iaoOIAC])|([vV])|(?:([1-9]\\d*)?(?:([DpPsxXu])|([cdy]{2})|(?:([cdy])?([1-9]\\d*)?(" + motions.regex.source + ")?))?)$");
    return {
      execute: function() {
        var additionalLines, after, command, continueBuffering, count, countMatch, deleteMotion, fullMatch, insertSwitch, linewiseCommand, match, motion, motionCount, motionCountMatch, motionObj, operator, row, startingPosition, text, timesLeft, visualSwitch, _ref;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], insertSwitch = match[1], visualSwitch = match[2], countMatch = match[3], command = match[4], linewiseCommand = match[5], operator = match[6], motionCountMatch = match[7], motion = match[8];
        count = parseInt(countMatch) || null;
        motionCount = parseInt(motionCountMatch) || null;
        continueBuffering = false;
        if (insertSwitch) {
          switch (insertSwitch) {
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
              row = this.adaptor.row() + (insertSwitch === 'o' ? 1 : 0);
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
        } else if (motion) {
          motionObj = motions[motion];
          if (count || motionCount) {
            motionCount = (count || 1) * (motionCount || 1);
          }
          switch (operator) {
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
            case 'D':
              motions['$']["delete"](this, count);
              break;
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
        } else if (linewiseCommand) {
          startingPosition = this.adaptor.position();
          this.adaptor.setSelectionAnchor();
          additionalLines = (count || 1) - 1;
          if (additionalLines) {
            motions['j'].move(this, additionalLines);
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
              (_ref = this.adaptor).moveTo.apply(_ref, startingPosition);
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
