module 'unhandled keys',
  setup: setupAceTests

test 'arrow keys', ->
  @press @down, @down
  eq @adaptor.editor.session.getValue(), @sort_by_js
  deepEqual @adaptor.position(), [2, 0]
