(function() {
  var MovementCommand;
  MovementCommand = (function() {
    function MovementCommand(times, movement) {
      this.times = times;
      this.movement = movement;
    }
    MovementCommand.prototype.execute = function(editor) {
      console.log("execute", editor);
      switch (this.movement) {
        case "h":
          return this.navigateLeft(this.times);
        case "j":
          return this.navigateDown(this.times);
        case "k":
          return this.navigateUp(this.times);
        case "l":
          return this.navigateRight(this.times);
      }
    };
    MovementCommand.prototype.navigateLeft = function(times) {
      return console.log('navigateLeft', times);
    };
    MovementCommand.prototype.navigateDown = function(times) {
      return console.log('navigateDown', times);
    };
    MovementCommand.prototype.navigateUp = function(times) {
      return console.log('navigateUp', times);
    };
    MovementCommand.prototype.navigateRight = function(times) {
      return console.log('navigateRight', times);
    };
    return MovementCommand;
  })();
  window.MovementCommand = MovementCommand;
}).call(this);
