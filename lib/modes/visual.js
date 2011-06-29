define(function(require, exports, module) {
  var motions;
  motions = require('jim/motions');
  return {
    regex: RegExp("^(\\d*)(?:(" + motions.regex.source + ")|([ydc]))?"),
    parse: function(buffer) {
      var fullMatch, match, motion, numberPrefix, operator, result;
      match = buffer.match(this.regex);
      console.log('visual parse match', match);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {};
      }
      fullMatch = match[0], numberPrefix = match[1], motion = match[2], operator = match[3];
      numberPrefix = parseInt(numberPrefix) || null;
      result = {};
      if (motion) {
        result.action = "select" + motions.map[motion];
        if (numberPrefix) {
          result.args = {
            times: numberPrefix
          };
        }
      } else if (operator) {
        switch (operator) {
          case 'c':
            result = {
              action: 'deleteSelection',
              changeToMode: 'insert'
            };
            break;
          case 'd':
            result = {
              action: 'deleteSelection',
              changeToMode: 'normal'
            };
            break;
          case 'y':
            result = {
              action: 'yankSelection',
              changeToMode: 'normal'
            };
        }
        result.args = {
          register: '"'
        };
      } else {
        result = 'continueBuffering';
      }
      return result;
    }
  };
});