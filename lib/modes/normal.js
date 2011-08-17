(function() {
  define(function(require, exports, module) {
    var MoveDown, MoveLeft, invalidCommand, tokenize, _ref;
    _ref = require('jim/motions'), MoveLeft = _ref.MoveLeft, MoveDown = _ref.MoveDown;
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
    exports.onKeypress = function(keys) {
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
    };
  });
}).call(this);
