(function() {
  var Jim, aceAdaptor, commandMode, jim;
  commandMode = {
    regex: /^(\d*)([hjkl]?)$/,
    execute: function(match) {
      var args, fullMatch, method, movement, multiplier;
      console.log('execute', match);
      fullMatch = match[0], multiplier = match[1], movement = match[2];
      args = {};
      if (multiplier.length > 0) {
        args.times = parseInt(multiplier);
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
    handleKeyboard: function(data, hashId, key) {
      var result;
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
