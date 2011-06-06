(function() {
  var jim;
  jim = new Jim();
  console.log('jim', jim);
  $(document).keyup(function(event) {
    var command, key;
    key = String.fromCharCode(event.which);
    if (!event.shiftKey) {
      key = key.toLowerCase();
    }
    if (key.match(/\w/)) {
      command = jim.keyup(key);
    }
    $('#mode').html(jim.mode);
    return $('#buffer').html(jim.buffer);
  });
}).call(this);
