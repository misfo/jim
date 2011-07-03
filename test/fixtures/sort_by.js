_.sortBy = function(obj, iterator, context) {
  return _.pluck(_.map(obj, function(value, index, list) {
    return {
      value : value,
      criteria : iterator.call(context, value, index, list)
    };
  }).sort(function(left, right) {
    var a = left.criteria, b = right.criteria;
    return a < b ? -1 : a > b ? 1 : 0;
  }), 'value');
};

// borrowed from:
//     Underscore.js 1.1.6
//     (c) 2011 Jeremy Ashkenas, DocumentCloud Inc.
