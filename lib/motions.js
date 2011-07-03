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
        B: 'BackWORD',
        w: 'NextWord',
        e: 'WordEnd',
        b: 'BackWord'
      },
      regex: /[hjklWEBweb]/
    };
  });
}).call(this);
