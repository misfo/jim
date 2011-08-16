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
        var maxRow, minRow, wasBackwards, _ref, _ref2, _ref3;
        this.commandPart = (this.commandPart || '') + newKeys;
        tokenize.call(this);
        wasBackwards = this.adaptor.isSelectionBackwards();
        if (((_ref = this.command) != null ? _ref.isOperation : void 0) || ((_ref2 = this.command) != null ? _ref2.isComplete() : void 0)) {
          if (this.command.isRepeatable) {
            this.command.selectionSize = this.modeName === 'visual:linewise' ? ((_ref3 = this.adaptor.selectionRowRange(), minRow = _ref3[0], maxRow = _ref3[1], _ref3), {
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
  });
}).call(this);
