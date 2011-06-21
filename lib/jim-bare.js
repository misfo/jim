var Jim, aceAdaptor, jim, modes;
modes = {
  normal: {
    regex: /^([iIAC])|(D)|(?:(\d*)(?:([hjklxX])|(G))?)/,
    parse: function(buffer) {
      var args, changeToMode, deleteCommand, fullMatch, go, insertTransition, match, method, multipliable, numberPrefix;
      match = buffer.match(this.regex);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {
          method: 'doNothing'
        };
      }
      console.log('parse match', match);
      fullMatch = match[0], insertTransition = match[1], deleteCommand = match[2], numberPrefix = match[3], multipliable = match[4], go = match[5];
      method = 'doNothing';
      args = {};
      changeToMode = null;
      if (insertTransition) {
        switch (insertTransition) {
          case "A":
            method = 'navigateLineEnd';
            break;
          case "C":
            method = 'removeToLineEnd';
            break;
          case "I":
            method = 'navigateLineStart';
        }
        changeToMode = 'insert';
      } else if (deleteCommand) {
        switch (deleteCommand) {
          case "D":
            method = 'removeToLineEnd';
        }
      } else if (multipliable) {
        if (numberPrefix) {
          args.times = parseInt(numberPrefix);
        }
        method = (function() {
          switch (multipliable) {
            case "h":
              return 'navigateLeft';
            case "j":
              return 'navigateDown';
            case "k":
              return 'navigateUp';
            case "l":
              return 'navigateRight';
            case "x":
              return 'removeRight';
            case "X":
              return 'removeLeft';
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
  Jim.prototype.onEscape = function() {
    return this.setMode('normal');
  };
  Jim.prototype.onKeypress = function(key) {
    var result;
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
  navigateLineEnd: function(env, args, request) {
    return env.editor.navigateLineEnd();
  },
  navigateLineStart: function(env, args, request) {
    return env.editor.navigateLineStart();
  },
  removeLeft: function(env, args, request) {
    var i, _ref, _results;
    _results = [];
    for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
      _results.push(env.editor.removeLeft());
    }
    return _results;
  },
  removeRight: function(env, args, request) {
    var i, _ref, _results;
    _results = [];
    for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
      _results.push(env.editor.removeRight());
    }
    return _results;
  },
  removeToLineEnd: function(env, args, request) {
    return env.editor.removeToLineEnd();
  },
  isntCharacterKey: function(hashId, key) {
    return (hashId !== 0 && (key === "" || key === String.fromCharCode(0))) || key.length > 1;
  },
  handleKeyboard: function(data, hashId, key) {
    var result;
    if (key === "esc") {
      jim.onEscape();
      return {
        command: {
          exec: this.doNothing
        }
      };
    } else if (this.isntCharacterKey(hashId, key)) {
      return;
    }
    if (hashId & 4 && key.match(/^[a-z]$/)) {
      key = key.toUpperCase();
    }
    result = jim.onKeypress(key);
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
  var startup;
  console.log('defining startup');
  startup = function(data, reason) {
    if (!data.env.editor) {
      setTimeout(startup, 0, data, reason);
      return;
    }
    console.log('executing startup');
    return env.editor.setKeyboardHandler(aceAdaptor);
  };
  exports.startup = startup;
});
