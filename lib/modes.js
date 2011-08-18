(function() {
  define(function(require, exports, module) {
    var MoveDown, MoveLeft, _ref;
    _ref = require('jim/motions'), MoveLeft = _ref.MoveLeft, MoveDown = _ref.MoveDown;
    exports.normal = (function() {
      var invalidCommand, tokenize;
      tokenize = function() {
        var command, motion, regex, _ref2;
        if (!this.command) {
          command = this.keymap.commandFor(this.commandPart);
          if (command === false) {
            return invalidCommand.call(this);
          } else if (command !== true) {
            if (command.isOperation) {
              this.operatorPending = this.commandPart.match(/[^\d]+$/)[0];
            }
            this.command = command;
            return this.commandPart = '';
          }
        } else if (this.command.constructor.followedBy) {
          if (this.command.constructor.followedBy.test(this.commandPart)) {
            this.command.followedBy = this.commandPart;
          } else {
            console.log("" + this.command + " didn't expect to be followed by \"" + this.commandPart + "\"");
          }
          return this.commandPart = '';
        } else if (this.command.isOperation) {
          if (regex = (_ref2 = this.command.motion) != null ? _ref2.constructor.followedBy : void 0) {
            if (regex.test(this.commandPart)) {
              return this.command.motion.followedBy = this.commandPart;
            } else {
              return console.log("" + this.command + " didn't expect to be followed by \"" + this.commandPart + "\"");
            }
          } else {
            motion = this.keymap.motionFor(this.commandPart, this.operatorPending);
            if (motion === false) {
              return invalidCommand.call(this, 'motion');
            } else if (motion !== true) {
              this.command.motion = motion;
              this.command.motion.operation = this.command;
              this.operatorPending = null;
              return this.commandPart = '';
            }
          }
        }
      };
      invalidCommand = function(type) {
        if (type == null) {
          type = 'command';
        }
        console.log("invalid " + type + ": " + this.commandPart);
        return this.onEscape();
      };
      return {
        onKeypress: function(keys) {
          var _ref2;
          this.commandPart = (this.commandPart || '') + keys;
          tokenize.call(this);
          if ((_ref2 = this.command) != null ? _ref2.isComplete() : void 0) {
            this.command.exec(this);
            if (this.command.isRepeatable) {
              this.lastCommand = this.command;
            }
            return this.command = null;
          }
        }
      };
    })();
    exports.visual = (function() {
      var invalidCommand, tokenize;
      invalidCommand = function(type) {
        if (type == null) {
          type = 'command';
        }
        console.log("invalid " + type + ": " + this.commandPart);
        return this.commandPart = '';
      };
      tokenize = function() {
        var command;
        if (!this.command) {
          command = this.keymap.visualCommandFor(this.commandPart);
          if (command === false) {
            return invalidCommand.call(this);
          } else if (command !== true) {
            this.command = command;
            return this.commandPart = '';
          }
        } else if (this.command.constructor.followedBy) {
          if (this.command.constructor.followedBy.test(this.commandPart)) {
            this.command.followedBy = this.commandPart;
          } else {
            console.log("" + this.command + " didn't expect to be followed by \"" + this.commandPart + "\"");
          }
          return this.commandPart = '';
        }
      };
      return {
        onKeypress: function(newKeys) {
          var maxRow, minRow, wasBackwards, _ref2, _ref3, _ref4;
          this.commandPart = (this.commandPart || '') + newKeys;
          tokenize.call(this);
          wasBackwards = this.adaptor.isSelectionBackwards();
          if (((_ref2 = this.command) != null ? _ref2.isOperation : void 0) || ((_ref3 = this.command) != null ? _ref3.isComplete() : void 0)) {
            if (this.command.isRepeatable) {
              this.command.selectionSize = this.modeName === 'visual:linewise' ? ((_ref4 = this.adaptor.selectionRowRange(), minRow = _ref4[0], maxRow = _ref4[1], _ref4), {
                lines: (maxRow - minRow) + 1
              }) : this.adaptor.characterwiseSelectionSize();
              this.command.linewise = this.modeName === 'visual:linewise';
              this.command.visualExec(this);
              this.lastCommand = this.command;
              console.log('repeatable visual command', this.lastCommand);
            } else {
              this.command.visualExec(this);
            }
            this.command = null;
          }
          if (this.inVisualMode()) {
            if (wasBackwards) {
              if (!this.adaptor.isSelectionBackwards()) {
                return this.adaptor.adjustAnchor(-1);
              }
            } else {
              if (this.adaptor.isSelectionBackwards()) {
                return this.adaptor.adjustAnchor(1);
              }
            }
          }
        }
      };
    })();
    exports.insert = {
      onKeypress: function() {
        return true;
      }
    };
    exports.replace = {
      onKeypress: function() {
        return true;
      }
    };
  });
}).call(this);
