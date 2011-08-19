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

test '*', ->
  @adaptor.moveTo 0, 14
  @press '*'
  deepEqual @adaptor.position(), [1, 28]

  @press 'n'
  deepEqual @adaptor.position(), [6, 10]
  @press 'N'
  deepEqual @adaptor.position(), [1, 28]

test '#', ->
  @adaptor.moveTo 1, 4
  @press '#'
  deepEqual @adaptor.position(), [8, 4]

  @press 'n'
  deepEqual @adaptor.position(), [2, 4]
  @press 'N'
  deepEqual @adaptor.position(), [8, 4]
