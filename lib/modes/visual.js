(function() {
  define(function(require, exports, module) {
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
        var wasBackwards, _ref, _ref2;
        this.commandPart = (this.commandPart || '') + newKeys;
        tokenize.call(this);
        wasBackwards = this.adaptor.isSelectionBackwards();
        if (((_ref = this.command) != null ? _ref.isOperation : void 0) || ((_ref2 = this.command) != null ? _ref2.isComplete() : void 0)) {
          this.command.visualExec(this);
          if (this.command.isRepeatable) {
            this.lastCommand = this.command;
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
  });
}).call(this);
