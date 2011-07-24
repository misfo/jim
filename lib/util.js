(function() {
  var __hasProp = Object.prototype.hasOwnProperty;
  define(function(require, exports, module) {
    return {
      propertyNameRegex: function(obj) {
        var c, dualChar, k, singleChar, v;
        singleChar = [];
        dualChar = [];
        for (k in obj) {
          if (!__hasProp.call(obj, k)) continue;
          v = obj[k];
          switch (k.length) {
            case 1:
              singleChar.push(k);
              break;
            case 2:
              dualChar.push("" + k + "?");
          }
        }
        return RegExp("[" + (((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = singleChar.length; _i < _len; _i++) {
            c = singleChar[_i];
            _results.push(c);
          }
          return _results;
        })()).join('')) + "]|" + (((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = dualChar.length; _i < _len; _i++) {
            c = dualChar[_i];
            _results.push(c);
          }
          return _results;
        })()).join('|')));
      }
    };
  });
}).call(this);
