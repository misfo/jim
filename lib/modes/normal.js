(function() {
  define(function(require, exports, module) {
    var motions;
    motions = require('jim/motions');
    return {
      regex: RegExp("^([iIAC])|([vV])|(D)|(?:(\\d*)(?:(" + motions.regex.source + ")|([[pPxXu])|(G))?)"),
      parse: function(buffer) {
        var deleteCommand, fullMatch, go, insertTransition, match, motion, multipliableCommand, numberPrefix, result, visualTransition;
        match = buffer.match(this.regex);
        if (!(match != null) || match[0] === "") {
          console.log("unrecognized command: " + buffer);
          return {};
        }
        console.log('normal parse match', match);
        fullMatch = match[0], insertTransition = match[1], visualTransition = match[2], deleteCommand = match[3], numberPrefix = match[4], motion = match[5], multipliableCommand = match[6], go = match[7];
        if (numberPrefix) {
          numberPrefix = parseInt(numberPrefix);
        }
        result = {};
        if (insertTransition) {
          switch (insertTransition) {
            case "A":
              result.action = 'navigateLineEnd';
              break;
            case "C":
              result.action = 'deleteToLineEnd';
              break;
            case "I":
              result.action = 'navigateLineStart';
          }
          result.changeToMode = 'insert';
        } else if (visualTransition) {
          result = visualTransition === 'V' ? {
            action: 'selectLine',
            changeToMode: 'visual:linewise'
          } : {
            action: 'selectRight',
            changeToMode: 'visual:characterwise'
          };
        } else if (deleteCommand) {
          switch (deleteCommand) {
            case "D":
              result.action = 'deleteToLineEnd';
          }
        } else if (motion) {
          if (numberPrefix) {
            result.args = {
              times: numberPrefix
            };
          }
          result.action = "navigate" + motions.map[motion];
        } else if (multipliableCommand) {
          result.action = (function() {
            switch (multipliableCommand) {
              case "p":
                return 'paste';
              case "P":
                return 'pasteBefore';
              case "x":
                return 'deleteRight';
              case "X":
                return 'deleteLeft';
              case "u":
                return 'undo';
            }
          })();
          result.args = {
            register: '"'
          };
          if (numberPrefix) {
            result.args.times = numberPrefix;
          }
        } else if (go) {
          if (numberPrefix) {
            result.args = {
              lineNumber: numberPrefix
            };
          }
          result.action = numberPrefix ? 'gotoLine' : 'navigateFileEnd';
        } else {
          return 'continueBuffering';
        }
        return result;
      }
    };
  });
}).call(this);
