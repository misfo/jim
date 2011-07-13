module 'Ace: insert mode',
  setup: setupAceTests
  
test 'leaves the cursor in the right spot', ->
  @press 'Wi', @esc
  deepEqual @adaptor.position(), [0, 8]
  @press 'i', @esc
  deepEqual @adaptor.position(), [0, 7]
  @press 'a', @esc
  deepEqual @adaptor.position(), [0, 7]
