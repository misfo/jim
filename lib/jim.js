(function() {
  var Jim, aceAdaptor, commandMode, jim;
  commandMode = {
    regex: /^(\d*)([hjkl]?)(G?)$/,
    execute: function(match) {
      var args, fullMatch, go, method, movement, numberPrefix;
      console.log('execute', match);
      fullMatch = match[0], numberPrefix = match[1], movement = match[2], go = match[3];
      args = {};
      if (movement) {
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
      }
      if (method) {
        return [method, args];
      }
    }
  };
  Jim = (function() {
    function Jim() {
      this.buffer = '';
      this.mode = commandMode;
    }
    Jim.prototype.keypress = function(key) {
      var match, result;
      this.buffer += key;
      console.log('@buffer', this.buffer);
      match = this.buffer.match(this.mode.regex);
      result = null;
      if (match != null) {
        result = this.mode.execute(match);
        if (result != null) {
          this.buffer = '';
        }
                if (result != null) {
          result;
        } else {
          result = ['doNothing', {}];
        };
      } else {
        console.log("unrecognized command: " + this.buffer);
        result = ['doNothing', {}];
        this.buffer = '';
      }
      return result;
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
        return {
          command: {
            exec: this[result[0]]
          },
          args: result[1]
        };
      }
    }
  };
  define(function(require, exports, module) {
    exports.Vim = aceAdaptor;
    return console.log('exports.Vim', exports.Vim);
  });
}).call(this);
