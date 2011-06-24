(function() {
  var Jim, aceAdaptor, jim;
  Jim = (function() {
    Jim.movements = /[hjkl]/;
    Jim.modes = {};
    function Jim() {
      this.buffer = '';
      this.registers = {};
      this.setMode('normal');
    }
    Jim.prototype.setMode = function(modeName) {
      var modeParts, prevModeName;
      console.log('setMode', modeName);
      prevModeName = this.modeName;
      this.modeName = modeName;
      this.buffer = '';
      modeParts = modeName.split(":");
      this.mode = Jim.modes[modeParts[0]];
      if (modeName !== prevModeName) {
        return typeof this.onModeChange === "function" ? this.onModeChange(prevModeName) : void 0;
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
        return {};
      }
      this.buffer = '';
      return result;
    };
    return Jim;
  })();
  Jim.modes.insert = {
    parse: function() {}
  };
  Jim.modes.normal = {
    regex: RegExp("^([iIAC])|([vV])|(D)|(?:(\\d*)(?:(" + Jim.movements.source + ")|([[pPxX])|(G))?)"),
    parse: function(buffer) {
      var deleteCommand, fullMatch, go, insertTransition, match, movement, multipliableCommand, numberPrefix, result, visualTransition;
      match = buffer.match(this.regex);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {};
      }
      console.log('normal parse match', match);
      fullMatch = match[0], insertTransition = match[1], visualTransition = match[2], deleteCommand = match[3], numberPrefix = match[4], movement = match[5], multipliableCommand = match[6], go = match[7];
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
      } else if (movement) {
        if (numberPrefix) {
          result.args = {
            times: numberPrefix
          };
        }
        result.action = (function() {
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
  Jim.modes.visual = {
    regex: RegExp("^(\\d*)(?:(" + Jim.movements.source + ")|([ydc]))?"),
    parse: function(buffer) {
      var fullMatch, match, movement, numberPrefix, operator, result;
      match = buffer.match(this.regex);
      console.log('visual parse match', match);
      if (!(match != null) || match[0] === "") {
        console.log("unrecognized command: " + buffer);
        return {};
      }
      fullMatch = match[0], numberPrefix = match[1], movement = match[2], operator = match[3];
      numberPrefix = parseInt(numberPrefix) || null;
      result = {};
      if (movement) {
        if (numberPrefix) {
          result.args = {
            times: numberPrefix
          };
        }
        result.action = (function() {
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
  jim = new Jim();
  aceAdaptor = {
    onEscape: function(env, args) {
      return env.editor.clearSelection();
    },
    gotoLine: function(env, args) {
      return env.editor.gotoLine(args.lineNumber);
    },
    navigateUp: function(env, args) {
      return env.editor.navigateUp(args.times);
    },
    navigateDown: function(env, args) {
      return env.editor.navigateDown(args.times);
    },
    navigateLeft: function(env, args) {
      return env.editor.navigateLeft(args.times);
    },
    navigateRight: function(env, args) {
      return env.editor.navigateRight(args.times);
    },
    navigateFileEnd: function(env, args) {
      return env.editor.navigateFileEnd();
    },
    navigateLineEnd: function(env, args) {
      return env.editor.navigateLineEnd();
    },
    navigateLineStart: function(env, args) {
      return env.editor.navigateLineStart();
    },
    deleteLeft: function(env, args) {
      aceAdaptor.selectLeft(env, args);
      return aceAdaptor.deleteSelection(env, args);
    },
    deleteRight: function(env, args) {
      aceAdaptor.selectRight(env, args);
      return aceAdaptor.deleteSelection(env, args);
    },
    deleteToLineEnd: function(env, args) {
      env.editor.selection.selectLineEnd();
      return aceAdaptor.deleteSelection(env, args);
    },
    deleteSelection: function(env, args) {
      jim.registers[args.register] = env.editor.getCopyText();
      return env.editor.session.remove(env.editor.getSelectionRange());
    },
    paste: function(env, args) {
      aceAdaptor.navigateRight(env, args);
      return aceAdaptor.pasteBefore(env, args);
    },
    pasteBefore: function(env, args) {
      var text;
      text = jim.registers[args.register];
      if (text) {
        return env.editor.insert(text);
      }
    },
    selectUp: function(env, args) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectUp());
      }
      return _results;
    },
    selectDown: function(env, args) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectDown());
      }
      return _results;
    },
    selectLeft: function(env, args) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectLeft());
      }
      return _results;
    },
    selectRight: function(env, args) {
      var i, _ref, _results;
      _results = [];
      for (i = 1, _ref = args.times || 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        _results.push(env.editor.selection.selectRight());
      }
      return _results;
    },
    selectLine: function(env, args) {
      return env.editor.selection.selectLine();
    },
    yankSelection: function(env, args) {
      var start;
      jim.registers[args.register] = env.editor.getCopyText();
      if (env.editor.selection.isBackwards()) {
        return env.editor.clearSelection();
      } else {
        start = env.editor.getSelectionRange().start;
        return env.editor.navigateTo(start.row, start.column);
      }
    },
    isntCharacterKey: function(hashId, key) {
      return (hashId !== 0 && (key === "" || key === String.fromCharCode(0))) || key.length > 1;
    },
    handleKeyboard: function(data, hashId, key) {
      var noop, result;
      noop = function() {};
      if (key === "esc") {
        jim.onEscape();
        result = {
          action: 'onEscape'
        };
      } else if (this.isntCharacterKey(hashId, key)) {
        return;
      }
      if (hashId & 4 && key.match(/^[a-z]$/)) {
        key = key.toUpperCase();
      }
            if (result != null) {
        result;
      } else {
        result = jim.onKeypress(key);
      };
      if (result != null) {
        if (result.changeToMode != null) {
          jim.setMode(result.changeToMode);
        }
        return {
          command: {
            exec: this[result.action] || noop
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
      editor = data.env.editor;
      if (!editor) {
        setTimeout(startup, 0, data, reason);
        return;
      }
      console.log('executing startup');
      editor.setKeyboardHandler(aceAdaptor);
      jim.onModeChange = function(prevMode) {
        if (this.modeName === 'normal') {
          return editor.setStyle('jim-normal-mode');
        } else {
          return editor.unsetStyle('jim-normal-mode');
        }
      };
      return jim.onModeChange();
    };
    exports.startup = startup;
    exports.Jim = Jim;
  });
}).call(this);
