define(function(require, exports, module) {

var Change, Command, Delete, GoToLine, Indent, MoveToBigWordEnd, MoveToFirstNonBlank, MoveToNextBigWord, MoveToNextWord, MoveToWordEnd, Operation, Outdent, Yank, defaultMappings, map, _ref;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
Command = require('./helpers').Command;
_ref = require('./motions'), GoToLine = _ref.GoToLine, MoveToFirstNonBlank = _ref.MoveToFirstNonBlank, MoveToNextBigWord = _ref.MoveToNextBigWord, MoveToNextWord = _ref.MoveToNextWord, MoveToBigWordEnd = _ref.MoveToBigWordEnd, MoveToWordEnd = _ref.MoveToWordEnd;
defaultMappings = {};
map = function(keys, operatorClass) {
  return defaultMappings[keys] = operatorClass;
};
Operation = (function() {
  __extends(Operation, Command);
  function Operation(count, motion) {
    this.count = count != null ? count : 1;
    this.motion = motion;
    if (this.motion) {
      this.motion.operation = this;
    }
  }
  Operation.prototype.isOperation = true;
  Operation.prototype.isComplete = function() {
    var _ref2;
    return (_ref2 = this.motion) != null ? _ref2.isComplete() : void 0;
  };
  Operation.prototype.getMotion = function() {
    return this.motion;
  };
  Operation.prototype.switchToMode = 'normal';
  Operation.prototype.exec = function(jim) {
    var motion, _ref2;
    this.startingPosition = jim.adaptor.position();
    jim.adaptor.setSelectionAnchor();
    if (this.count !== 1) {
      this.motion.count *= this.count;
      this.count = 1;
    }
    motion = this.getMotion();
    if ((_ref2 = this.linewise) == null) {
      this.linewise = motion.linewise;
    }
    motion.exec(jim);
    return this.visualExec(jim);
  };
  Operation.prototype.visualExec = function(jim) {
    var _ref2;
    if (this.linewise) {
      jim.adaptor.makeLinewise();
    } else if (!((_ref2 = this.getMotion()) != null ? _ref2.exclusive : void 0)) {
      jim.adaptor.includeCursorInSelection();
    }
    this.operate(jim);
    if (this.repeatableInsert) {
      return jim.adaptor.insert(this.repeatableInsert.string);
    } else {
      if (this.switchToMode === 'insert') {
        jim.afterInsertSwitch = true;
      }
      if (this.switchToMode) {
        return jim.setMode(this.switchToMode);
      }
    }
  };
  return Operation;
})();
map('c', Change = (function() {
  __extends(Change, Operation);
  function Change() {
    Change.__super__.constructor.apply(this, arguments);
  }
  Change.prototype.getMotion = function() {
    var _ref2;
    switch ((_ref2 = this.motion) != null ? _ref2.constructor : void 0) {
      case MoveToNextWord:
        return new MoveToWordEnd(this.motion.count);
      case MoveToNextBigWord:
        return new MoveToBigWordEnd(this.motion.count);
      default:
        return Change.__super__.getMotion.apply(this, arguments);
    }
  };
  Change.prototype.operate = function(jim) {
    var motion;
    motion = this.getMotion();
    if (this.linewise) {
      jim.adaptor.moveToEndOfPreviousLine();
    }
    return jim.deleteSelection(motion != null ? motion.exclusive : void 0, this.linewise);
  };
  Change.prototype.switchToMode = 'insert';
  return Change;
})());
map('d', Delete = (function() {
  __extends(Delete, Operation);
  function Delete() {
    Delete.__super__.constructor.apply(this, arguments);
  }
  Delete.prototype.operate = function(jim) {
    var _ref2;
    jim.deleteSelection((_ref2 = this.motion) != null ? _ref2.exclusive : void 0, this.linewise);
    if (this.linewise) {
      return new MoveToFirstNonBlank().exec(jim);
    }
  };
  return Delete;
})());
map('y', Yank = (function() {
  __extends(Yank, Operation);
  function Yank() {
    Yank.__super__.constructor.apply(this, arguments);
  }
  Yank.prototype.operate = function(jim) {
    var _ref2, _ref3;
    jim.yankSelection((_ref2 = this.motion) != null ? _ref2.exclusive : void 0, this.linewise);
    if (this.startingPosition) {
      return (_ref3 = jim.adaptor).moveTo.apply(_ref3, this.startingPosition);
    }
  };
  return Yank;
})());
map('>', Indent = (function() {
  __extends(Indent, Operation);
  function Indent() {
    Indent.__super__.constructor.apply(this, arguments);
  }
  Indent.prototype.operate = function(jim) {
    var maxRow, minRow, _ref2;
    _ref2 = jim.adaptor.selectionRowRange(), minRow = _ref2[0], maxRow = _ref2[1];
    jim.adaptor.indentSelection();
    return new GoToLine(minRow + 1).exec(jim);
  };
  return Indent;
})());
map('<', Outdent = (function() {
  __extends(Outdent, Operation);
  function Outdent() {
    Outdent.__super__.constructor.apply(this, arguments);
  }
  Outdent.prototype.operate = function(jim) {
    var maxRow, minRow, _ref2;
    _ref2 = jim.adaptor.selectionRowRange(), minRow = _ref2[0], maxRow = _ref2[1];
    jim.adaptor.outdentSelection();
    return new GoToLine(minRow + 1).exec(jim);
  };
  return Outdent;
})());
module.exports = {
  Change: Change,
  Delete: Delete,
  defaultMappings: defaultMappings
};

});