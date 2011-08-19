(function() {
  define(function(require, exports, module) {
    var GoToLine, Jim, Keymap;
    Keymap = require('./keymap');
    GoToLine = require('./motions').GoToLine;
    return Jim = (function() {
      function Jim(adaptor) {
        this.adaptor = adaptor;
        this.command = null;
        this.registers = {};
        this.keymap = Keymap.getDefault();
        this.setMode('normal');
      }
      Jim.prototype.modes = require('./modes');
      Jim.prototype.setMode = function(modeName) {
        var modeParts, prevModeName;
        if (this.debugMode) {
          console.log('setMode', modeName);
        }
        prevModeName = this.modeName;
        if (modeName === prevModeName) {
          return;
        }
        this.modeName = modeName;
        modeParts = modeName.split(":");
        this.mode = this.modes[modeParts[0]];
        switch (prevModeName) {
          case 'insert':
            this.adaptor.moveLeft();
            break;
          case 'replace':
            this.adaptor.setOverwriteMode(false);
        }
        return typeof this.onModeChange === "function" ? this.onModeChange(prevModeName) : void 0;
      };
      Jim.prototype.inVisualMode = function() {
        return /^visual:/.test(this.modeName);
      };
      Jim.prototype.onEscape = function() {
        this.setMode('normal');
        this.command = null;
        this.commandPart = '';
        return this.adaptor.clearSelection();
      };
      Jim.prototype.onKeypress = function(keys) {
        return this.mode.onKeypress.call(this, keys);
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
  });
}).call(this);
