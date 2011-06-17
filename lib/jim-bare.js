var Jim, aceAdaptor, jim, modes;
modes = {
  normal: {
    regex: /^([i])|(?:(\d*)(?:([hjkl])|(G))?)/,
    parse: function(buffer) {
      var args, changeToMode, fullMatch, go, insertTransition, match, method, movement, numberPrefix;
      match = buffer.match(this.regex);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {
          method: 'doNothing'
        };
      }
      console.log('parse match', match);
      fullMatch = match[0], insertTransition = match[1], numberPrefix = match[2], movement = match[3], go = match[4];
      method = 'doNothing';
      args = {};
      changeToMode = null;
      if (insertTransition) {
        changeToMode = 'insert';
      } else if (movement) {
        if (numberPrefix) {
          args.times = parseInt(numberPrefix);
        }
        method = (function() {
          switch (movement) {
            case "h":
              return 'navigateLeft';
            case "j":
              return 'navigateDown';
            case "k":
              return 'navigateUp';
            case "l":
              return 'navigateRight';
          }
        })();
      } else if (go) {
        if (numberPrefix) {
          args.lineNumber = parseInt(numberPrefix);
        }
        method = numberPrefix ? 'gotoLine' : 'navigateFileEnd';
      } else {
        return 'continueBuffering';
      }
      return {
        method: method,
        args: args,
        changeToMode: changeToMode
      };
    }
  },
  insert: {
    parse: function() {}
  }
};
Jim = (function() {
  function Jim() {
    this.buffer = '';
    this.setMode('normal');
  }
  Jim.prototype.setMode = function(modeName) {
    console.log('setMode', modeName);
    this.buffer = '';
    return this.mode = modes[modeName];
  };
  Jim.prototype.keypress = function(key) {
    var result;
    if (key === "esc") {
      this.setMode('normal');
      return;
    }
    this.buffer += key;
    console.log('@buffer', this.buffer);
    result = this.mode.parse(this.buffer);
    if (result === 'continueBuffering') {
      return {
        method: 'doNothing'
      };
    } else {
      this.buffer = '';
      return result;
    }
  };
  return Jim;
})();
jim = new Jim();
aceAdaptor = {
  doNothing: function() {},
  gotoLine: function(env, args, request) {
    return env.editor.gotoLine(args.lineNumber);
  },
  navigateUp: function(env, args, request) {
    return env.editor.navigateUp(args.times);
  },
  navigateDown: function(env, args, request) {
    return env.editor.navigateDown(args.times);
  },
  navigateLeft: function(env, args, request) {
    return env.editor.navigateLeft(args.times);
  },
  navigateRight: function(env, args, request) {
    return env.editor.navigateRight(args.times);
  },
  navigateFileEnd: function(env, args, request) {
    return env.editor.navigateFileEnd();
  },
  handleKeyboard: function(data, hashId, key) {
    var result;
    if (hashId !== 0 && (key === "" || key === String.fromCharCode(0))) {
      return;
    }
    if (hashId & 4 && key.match(/^[a-z]$/)) {
      key = key.toUpperCase();
    }
    result = jim.keypress(key);
    if (result != null) {
      if (result.changeToMode != null) {
        jim.setMode(result.changeToMode);
      }
      return {
        command: {
          exec: this[result.method]
        },
        args: result.args
      };
    }
  }
};
define(function(require, exports, module) {
  exports.Vim = aceAdaptor;
  return console.log('exports.Vim', exports.Vim);
});
