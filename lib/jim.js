(function() {
  var Jim;
  Jim = (function() {
    function Jim() {
      this.buffer = '';
      this.mode = 'command';
    }
    Jim.prototype.keyup = function(key) {
      var command;
      console.log('key', key);
      this.buffer += key;
      console.log('@buffer', this.buffer);
      command = CommandParser.parse(this.buffer);
      console.log('command', command);
      if (command) {
        command.execute();
        this.buffer = '';
      }
      return command;
    };
    return Jim;
  })();
  window.Jim = Jim;
}).call(this);
