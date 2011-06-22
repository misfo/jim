(function() {
  var Jim, aceAdaptor, jim;
  Jim = (function() {
    Jim.movements = /[hjkl]/;
    Jim.modes = {};
    function Jim() {
      this.buffer = '';
      this.setMode('normal');
    }
    Jim.prototype.setMode = function(modeName) {
      var prevMode;
      console.log('setMode', modeName);
      this.buffer = '';
      prevMode = this.mode;
      this.mode = Jim.modes[modeName];
      if (this.mode !== prevMode) {
        return typeof this.onModeChange === "function" ? this.onModeChange(modeName) : void 0;
      }
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
  Jim.modes.insert = {
    parse: function() {}
  };
  Jim.modes.normal = {
    regex: RegExp("^([iIAC])|(v)|(D)|(?:(\\d*)(?:(" + Jim.movements.source + ")|([xX])|(G))?)"),
    parse: function(buffer) {
      var args, changeToMode, deleteCommand, deletion, fullMatch, go, insertTransition, match, method, movement, numberPrefix, visualTransition;
      match = buffer.match(this.regex);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {
          method: 'doNothing'
        };
      }
      console.log('parse match', match);
      fullMatch = match[0], insertTransition = match[1], visualTransition = match[2], deleteCommand = match[3], numberPrefix = match[4], movement = match[5], deletion = match[6], go = match[7];
      if (numberPrefix) {
        numberPrefix = parseInt(numberPrefix);
      }
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
      } else if (visualTransition) {
        changeToMode = 'visual';
      } else if (deleteCommand) {
        switch (deleteCommand) {
          case "D":
            method = 'removeToLineEnd';
        }
      } else if (movement) {
        args.times = numberPrefix;
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
      } else if (deletion) {
        args.times = numberPrefix;
        method = (function() {
          switch (deletion) {
            case "x":
              return 'removeRight';
            case "X":
              return 'removeLeft';
          }
        })();
      } else if (go) {
        args.lineNumber = numberPrefix;
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
  };
  console.log(Jim.modes.normal.regex.toString());
  Jim.modes.visual = {
    regex: RegExp("^(\\d*)(" + Jim.movements.source + ")?"),
    parse: function(buffer) {
      var args, changeToMode, fullMatch, match, method, movement, numberPrefix;
      match = buffer.match(this.regex);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {
          method: 'doNothing'
        };
      }
      fullMatch = match[0], numberPrefix = match[1], movement = match[2];
      if (numberPrefix) {
        numberPrefix = parseInt(numberPrefix);
      }
      method = 'doNothing';
      args = {};
      changeToMode = null;
      if (movement) {
        args.times = numberPrefix;
        method = (function() {
          switch (movement) {
            case "h":
              return 'selectLeft';
            case "j":
              return 'selectDown';
            case "k":
              return 'selectUp';
            case "l":
              return 'selectRight';
          }
        })();
      } else {
        return 'continueBuffering';
      }
      return {
        method: method,
        args: args,
        changeToMode: changeToMode
      };
    }
  };
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
    selectUp: function(env, args, request) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectUp());
      }
      return _results;
    },
    selectDown: function(env, args, request) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectDown());
      }
      return _results;
    },
    selectLeft: function(env, args, request) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectLeft());
      }
      return _results;
    },
    selectRight: function(env, args, request) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectRight());
      }
      return _results;
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
    require('pilot/dom').importCssString(".jim-normal-mode div.ace_cursor {\n  border: 0;\n  background-color: #91FF00;\n  opacity: 0.5;\n}");
    console.log('defining startup');
    startup = function(data, reason) {
      var editor;
      if (!data.env.editor) {
        setTimeout(startup, 0, data, reason);
        return;
      }
      console.log('executing startup');
      editor = data.env.editor;
      editor.setKeyboardHandler(aceAdaptor);
      jim.onModeChange = function(state) {
        if (state === 'normal') {
          editor.setStyle('jim-normal-mode');
        } else {
          editor.unsetStyle('jim-normal-mode');
        }
        if (state === 'visual') {
          return editor.selection.selectRight();
        } else {
          return editor.clearSelection();
        }
      };
      return jim.onModeChange('normal');
    };
    exports.startup = startup;
    exports.Jim = Jim;
  });
}).call(this);
