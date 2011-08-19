module 'Ace: search',
  setup: setupAceTests

test '/', ->
  realPrompt = -> "or"
  window.prompt = -> "or"
  @press '/'
  deepEqual @adaptor.position(), [0, 3]

  @press 'n'
  deepEqual @adaptor.position(), [0, 31]

  window.prompt = realPrompt
