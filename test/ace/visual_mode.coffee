module 'Ace: visual mode',
  setup: ->
    @editor = new Editor(new MockRenderer(), new EditSession js_code)
    @jim = aceModule.startup env: {editor: @editor}
  
test 'motions', ->
  @editor.onTextInput c for c in 'v3Gd'
  deepEqual @editor.getCursorPosition(), row: 0, column: 0
  eq @jim.adaptor.lineText(), 'eturn {'

  @editor.onTextInput c for c in 'v2ly'
  eq @jim.registers['"'], 'etu'
  # this fails, leaves the cursor in the wrong position
  #deepEqual @editor.getCursorPosition(), row: 0, column: 0
