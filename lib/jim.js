(function() {
  var AceAdaptor, Jim, commandMode, jim;
  commandMode = {
    regex: /^(\d*)([hjklbe]?)$/,
    execute: function(match) {
      var movement, times;
      console.log('execute', match);
      if (match[1].length > 0) {
        times = parseInt(match[1]);
      }
      movement = (function() {
        switch (match[2]) {
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
      if (movement) {
        return [
          movement, {
            times: times
          }
        ];
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
  AceAdaptor = (function() {
    function AceAdaptor() {}
    AceAdaptor.prototype.doNothing = function() {};
    AceAdaptor.prototype.navigateUp = function(env, args, request) {
      return env.editor.navigateUp(args.times);
    };
    AceAdaptor.prototype.navigateDown = function(env, args, request) {
      return env.editor.navigateDown(args.times);
    };
    AceAdaptor.prototype.navigateLeft = function(env, args, request) {
      return env.editor.navigateLeft(args.times);
    };
    AceAdaptor.prototype.navigateRight = function(env, args, request) {
      return env.editor.navigateRight(args.times);
    };
    AceAdaptor.prototype.handleKeyboard = function(data, hashId, key) {
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
    };
    return AceAdaptor;
  })();
  define(function(require, exports, module) {
    exports.Vim = new AceAdaptor();
    return console.log('exports.Vim', exports.Vim);
  });
}).call(this);
