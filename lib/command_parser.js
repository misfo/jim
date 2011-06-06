(function() {
  var CommandParser;
  CommandParser = {
    chunker: /^(\d*)([hjkl])$/,
    parse: function(commandString) {
      var command, match;
      command = null;
      if (match = commandString.match(this.chunker)) {
        command = new MovementCommand(match[1], match[2]);
      }
      return command;
    }
  };
  window.CommandParser = CommandParser;
}).call(this);
