jim = new Jim()
console.log('jim', jim)

$(document).keyup (event) ->
  key = String.fromCharCode(event.which);
  key = key.toLowerCase() unless event.shiftKey
  if key.match(/\w/)
    command = jim.keyup(key)
    #TODO append some string representation of the command

  $('#mode').html jim.mode
  $('#buffer').html jim.buffer
