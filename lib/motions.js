(function() {
  define(function(require, exports, module) {
    return {
      map: {
        h: 'Left',
        j: 'Down',
        k: 'Up',
        l: 'Right',
        W: 'NextWORD',
        E: 'WORDEnd',
        B: 'BackWORD'
      },
      regex: /[hjklWEB]/
    };
  });
}).call(this);
