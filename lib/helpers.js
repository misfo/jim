(function() {
  define(function(require, exports, module) {
    exports.Command = (function() {
      function Command(count) {
        this.count = count != null ? count : 1;
      }
      Command.prototype.isRepeatable = true;
      Command.prototype.isComplete = function() {
        if (this.constructor.followedBy) {
          return this.followedBy;
        } else {
          return true;
        }
      };
      return Command;
    })();
    exports.repeatCountTimes = function(func) {
      return function(jim) {
        var timesLeft, _results;
        timesLeft = this.count;
        _results = [];
        while (timesLeft--) {
          _results.push(func.call(this, jim));
        }
        return _results;
      };
    };
  });
}).call(this);
