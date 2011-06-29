define(function(require, exports, module) {
  var Jim;
  Jim = (function() {
    Jim.modes = {
      insert: require('jim/modes/insert'),
      normal: require('jim/modes/normal'),
      visual: require('jim/modes/visual')
    };
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
  return Jim;
});