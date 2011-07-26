(function() {
  define(function(require, exports, module) {
    var Jim, motions;
    motions = require('jim/motions');
    return Jim = (function() {
      function Jim(adaptor) {
        this.adaptor = adaptor;
        this.clearBuffer();
        this.registers = {};
        this.setMode('normal');
      }
      Jim.prototype.modes = {
        insert: require('jim/modes/insert'),
        normal: require('jim/modes/normal'),
        visual: require('jim/modes/visual')
      };
      Jim.prototype.clearBuffer = function() {
        return this.buffer = this.operator = '';
      };
      Jim.prototype.setMode = function(modeName) {
        var modeParts, prevModeName;
        if (this.debugMode) {
          console.log('setMode', modeName);
        }
        prevModeName = this.modeName;
        this.clearBuffer();
        if (modeName === prevModeName) {
          return;
        }
        this.modeName = modeName;
        modeParts = modeName.split(":");
        this.mode = this.modes[modeParts[0]];
        if (prevModeName === 'insert') {
          this.adaptor.moveLeft();
        }
        return typeof this.onModeChange === "function" ? this.onModeChange(prevModeName) : void 0;
      };
      Jim.prototype.onEscape = function() {
        this.setMode('normal');
        return this.adaptor.clearSelection();
      };
      Jim.prototype.onKeypress = function(key) {
        this.buffer += key;
        if (this.debugMode) {
          console.log('@buffer', this.buffer);
        }
        return this.mode.execute.call(this);
      };
      Jim.prototype.joinLines = function(rowStart, lines, replaceWithSpace) {
        var timesLeft, _results;
        this.adaptor.clearSelection();
        this.adaptor.moveTo(rowStart, 0);
        timesLeft = Math.max(lines, 2) - 1;
        _results = [];
        while (timesLeft--) {
          this.adaptor.selectLineEnding(replaceWithSpace);
          this.adaptor.deleteSelection();
          _results.push(replaceWithSpace ? (this.adaptor.insert(' '), this.adaptor.moveLeft()) : void 0);
        }
        return _results;
      };
      Jim.prototype.moveToFirstNonBlank = function(row) {
        var column, line, _ref;
                if (row != null) {
          row;
        } else {
          row = this.adaptor.row();
        };
        line = this.adaptor.lineText(row);
        column = ((_ref = /\S/.exec(line)) != null ? _ref.index : void 0) || 0;
        return this.adaptor.moveTo(row, column);
      };
      Jim.prototype.deleteSelection = function(exclusive, linewise) {
        return this.registers['"'] = this.adaptor.deleteSelection(exclusive, linewise);
      };
      Jim.prototype.yankSelection = function(exclusive, linewise) {
        this.registers['"'] = this.adaptor.selectionText(exclusive, linewise);
        return this.adaptor.clearSelection(true);
      };
      Jim.prototype.indentSelection = function() {
        var maxRow, minRow, _ref;
        _ref = this.adaptor.selectionRowRange(), minRow = _ref[0], maxRow = _ref[1];
        this.adaptor.indentSelection();
        return motions.move(this, 'G', minRow + 1);
      };
      Jim.prototype.outdentSelection = function() {
        var maxRow, minRow, _ref;
        _ref = this.adaptor.selectionRowRange(), minRow = _ref[0], maxRow = _ref[1];
        this.adaptor.outdentSelection();
        return motions.move(this, 'G', minRow + 1);
      };
      return Jim;
    })();
  });
}).call(this);
