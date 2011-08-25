define(function(require, exports, module) {

var GoToLine, Jim, Keymap;
Keymap = require('./keymap');
GoToLine = require('./motions').GoToLine;
Jim = (function() {
  function Jim(adaptor) {
    this.adaptor = adaptor;
    this.command = null;
    this.registers = {};
    this.keymap = Keymap.getDefault();
    this.setMode('normal');
  }
  Jim.prototype.modes = require('./modes');
  Jim.prototype.setMode = function(modeName, modeState) {
    var prevMode;
    if (modeState == null) {
      modeState = {};
    }
    if (this.debugMode) {
      console.log('setMode', modeName, modeState);
    }
    prevMode = this.mode;
    if (modeName === (prevMode != null ? prevMode.name : void 0) && modeState.linewise === prevMode.linewise) {
      return;
    }
    this.mode = modeState;
    this.mode.name = modeName;
    switch (prevMode != null ? prevMode.name : void 0) {
      case 'insert':
        this.adaptor.moveLeft();
        break;
      case 'replace':
        this.adaptor.setOverwriteMode(false);
    }
    return typeof this.onModeChange === "function" ? this.onModeChange(prevMode) : void 0;
  };
  Jim.prototype.onEscape = function() {
    this.setMode('normal');
    this.command = null;
    this.commandPart = '';
    return this.adaptor.clearSelection();
  };
  Jim.prototype.onKeypress = function(keys) {
    return this.modes[this.mode.name].onKeypress.call(this, keys);
  };
  Jim.prototype.deleteSelection = function(exclusive, linewise) {
    return this.registers['"'] = this.adaptor.deleteSelection(exclusive, linewise);
  };
  Jim.prototype.yankSelection = function(exclusive, linewise) {
    this.registers['"'] = this.adaptor.selectionText(exclusive, linewise);
    return this.adaptor.clearSelection(true);
  };
  return Jim;
})();
module.exports = Jim;

});