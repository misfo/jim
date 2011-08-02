(function() {
  var __hasProp = Object.prototype.hasOwnProperty;
  define(function(require, exports, module) {
    var Keymap;
    return Keymap = (function() {
      var buildPartialCommandRegex;
      Keymap.getDefault = function() {
        var commandClass, keymap, keys, motionClass, operationClass, _ref, _ref2, _ref3;
        keymap = new Keymap;
        _ref = require('jim/commands').defaultMappings;
        for (keys in _ref) {
          if (!__hasProp.call(_ref, keys)) continue;
          commandClass = _ref[keys];
          keymap.mapCommand(keys, commandClass);
        }
        _ref2 = require('jim/operators').defaultMappings;
        for (keys in _ref2) {
          if (!__hasProp.call(_ref2, keys)) continue;
          operationClass = _ref2[keys];
          keymap.mapOperator(keys, operationClass);
        }
        _ref3 = require('jim/motions').defaultMappings;
        for (keys in _ref3) {
          if (!__hasProp.call(_ref3, keys)) continue;
          motionClass = _ref3[keys];
          keymap.mapMotion(keys, motionClass);
        }
        return keymap;
      };
      function Keymap() {
        this.commands = {};
        this.motions = {};
        this.visualCommands = {};
        this.partialCommands = {};
        this.partialMotions = {};
        this.partialVisualCommands = {};
      }
      Keymap.prototype.mapCommand = function(keys, commandClass) {
        if (commandClass.prototype.exec) {
          this.commands[keys] = commandClass;
          if (keys.length === 2) {
            this.partialCommands[keys[0]] = true;
          }
        }
        if (commandClass.prototype.visualExec) {
          this.visualCommands[keys] = commandClass;
          if (keys.length === 2) {
            return this.partialVisualCommands[keys[0]] = true;
          }
        }
      };
      Keymap.prototype.mapMotion = function(keys, motionClass) {
        this.commands[keys] = motionClass;
        this.motions[keys] = motionClass;
        this.visualCommands[keys] = motionClass;
        if (keys.length === 2) {
          this.partialMotions[keys[0]] = true;
          this.partialCommands[keys[0]] = true;
          return this.partialVisualCommands[keys[0]] = true;
        }
      };
      Keymap.prototype.mapOperator = function(keys, operatorClass) {
        this.commands[keys] = operatorClass;
        this.visualCommands[keys] = operatorClass;
        if (keys.length === 2) {
          this.partialCommands[keys[0]] = true;
          return this.partialVisualCommands[keys[0]] = true;
        }
      };
      buildPartialCommandRegex = function(partialCommands) {
        var char, nothing;
        return RegExp("^([1-9]\\d*)?([" + (((function() {
          var _results;
          _results = [];
          for (char in partialCommands) {
            if (!__hasProp.call(partialCommands, char)) continue;
            nothing = partialCommands[char];
            _results.push(char);
          }
          return _results;
        })()).join('')) + "]?(.*))?$");
      };
      Keymap.prototype.commandFor = function(commandPart) {
        var beyondPartial, command, commandClass, count, _ref;
        this.partialCommandRegex || (this.partialCommandRegex = buildPartialCommandRegex(this.partialCommands));
        _ref = commandPart.match(this.partialCommandRegex), commandPart = _ref[0], count = _ref[1], command = _ref[2], beyondPartial = _ref[3];
        if (beyondPartial) {
          if (commandClass = this.commands[command]) {
            return new commandClass(parseInt(count) || null);
          } else {
            return false;
          }
        } else {
          return true;
        }
      };
      Keymap.prototype.motionFor = function(commandPart, operatorPending) {
        var LinewiseCommandMotion, beyondPartial, count, motion, motionClass, _ref;
        this.partialMotionRegex || (this.partialMotionRegex = buildPartialCommandRegex(this.partialMotions));
        _ref = commandPart.match(this.partialCommandRegex), commandPart = _ref[0], count = _ref[1], motion = _ref[2], beyondPartial = _ref[3];
        if (beyondPartial) {
          if (motion === operatorPending) {
            LinewiseCommandMotion = require('jim/motions').LinewiseCommandMotion;
            return new LinewiseCommandMotion(parseInt(count) || null);
          } else if (motionClass = this.motions[motion]) {
            return new motionClass(parseInt(count) || null);
          } else {
            return false;
          }
        } else {
          return true;
        }
      };
      Keymap.prototype.visualCommandFor = function(commandPart) {
        var beyondPartial, command, commandClass, count, _ref;
        this.partialVisualCommandRegex || (this.partialVisualCommandRegex = buildPartialCommandRegex(this.partialVisualCommands));
        _ref = commandPart.match(this.partialVisualCommandRegex), commandPart = _ref[0], count = _ref[1], command = _ref[2], beyondPartial = _ref[3];
        if (beyondPartial) {
          if (commandClass = this.visualCommands[command]) {
            return new commandClass(parseInt(count) || null);
          } else {
            return false;
          }
        } else {
          return true;
        }
      };
      return Keymap;
    })();
  });
}).call(this);
