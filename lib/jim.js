(function() {
  define(function(require, exports, module) {
    var Jim;
    return Jim = (function() {
      Jim.modes = {
        insert: require('jim/modes/insert'),
        normal: require('jim/modes/normal'),
        visual: require('jim/modes/visual')
      };
      function Jim(adaptor) {
        this.adaptor = adaptor;
        this.clearBuffer();
        this.registers = {};
        this.setMode('normal');
      }
      Jim.prototype.clearBuffer = function() {
        return this.buffer = this.operator = '';
      };
      Jim.prototype.setMode = function(modeName) {
        var modeParts, prevModeName;
        console.log('setMode', modeName);
        prevModeName = this.modeName;
        this.buffer = '';
        if (modeName === prevModeName) {
          return;
        }
        this.modeName = modeName;
        modeParts = modeName.split(":");
        this.mode = Jim.modes[modeParts[0]];
        return typeof this.onModeChange === "function" ? this.onModeChange(prevModeName) : void 0;
      };
      Jim.prototype.onEscape = function() {
        this.setMode('normal');
        return this.adaptor.clearSelection();
      };
      Jim.prototype.onKeypress = function(key) {
        this.buffer += key;
        console.log('@buffer', this.buffer);
        return this.mode.execute.call(this);
      };
      Jim.prototype.deleteSelection = function(exclusive, linewise) {
        return this.registers['"'] = this.adaptor.deleteSelection(exclusive, linewise);
      };
      Jim.prototype.yankSelection = function(exclusive, linewise) {
        return this.registers['"'] = this.adaptor.selectionText(exclusive, linewise);
      };
      Jim.prototype.times = function(number, func) {
        var _results;
        if (!(number != null) || number === "") {
          number = 1;
        }
        _results = [];
        while (number--) {
          _results.push(func.call(this));
        }
        return _results;
      };
      return Jim;
    })();
  });
}).call(this);
