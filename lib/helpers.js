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
  });
}).call(this);
