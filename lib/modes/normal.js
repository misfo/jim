(function() {
  define(function(require, exports, module) {
    var motions, regex, repeatText;
    motions = require('jim/motions');
    regex = RegExp("^([iIAC])|([vV])|(D)|(?:([cdy])?(\\d*)(?:(" + motions.regex.source + ")|([[pPxXu])|(G))?)");
    repeatText = function(number, string) {
      if (!(number != null) || number === "") {
        number = 1;
      }
      return new Array(number + 1).join(string);
    };
    return {
      execute: function() {
        var after, continueBuffering, deleteCommand, deleteMotion, fullMatch, go, insertTransition, match, motion, multipliableCommand, numberPrefix, text, visualTransition;
        match = this.buffer.match(regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + this.buffer);
          this.onEscape();
          return;
        }
        fullMatch = match[0], insertTransition = match[1], visualTransition = match[2], deleteCommand = match[3], this.operator = match[4], numberPrefix = match[5], motion = match[6], multipliableCommand = match[7], go = match[8];
        if (numberPrefix) {
          numberPrefix = parseInt(numberPrefix);
        }
        continueBuffering = false;
        if (insertTransition) {
          switch (insertTransition) {
            case "A":
              this.adaptor.navigateLineEnd();
              break;
            case "C":
              this.adaptor.selectToLineEnd();
              this.deleteSelection();
              break;
            case "I":
              this.adaptor.navigateLineStart();
          }
          this.setMode('insert');
        } else if (visualTransition) {
          if (visualTransition === 'V') {
            this.adaptor.selectLine();
            this.setMode('visual:linewise');
          } else {
            this.adaptor.setSelectionAnchor();
            this.setMode('visual:characterwise');
          }
        } else if (deleteCommand) {
          this.adaptor.selectToLineEnd();
          this.deleteSelection();
        } else if (motion) {
          motions.execute.call(this, this.operator, numberPrefix, motion);
        } else if (multipliableCommand) {
          switch (multipliableCommand) {
            case "p":
            case "P":
              text = repeatText(numberPrefix, this.registers['"']);
              after = multipliableCommand === "p";
              this.adaptor.insert(text, after);
              break;
            case "x":
            case "X":
              deleteMotion = multipliableCommand === 'X' ? 'h' : 'l';
              motions.execute.call(this, 'd', numberPrefix, deleteMotion);
              break;
            case "u":
              this.times(numberPrefix, function() {
                return this.adaptor.undo();
              });
          }
        } else if (go) {
          if (numberPrefix) {
            this.adaptor.goToLine(numberPrefix);
          } else {
            this.adaptor.navigateFileEnd();
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
