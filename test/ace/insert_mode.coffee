module 'Ace: insert mode',
  setup: ->
    @editor = new Editor(new MockRenderer(), new EditSession js_code)
    @jim = aceModule.startup env: {editor: @editor}
  
test 'leaves the cursor in the right spot', ->
  @editor.onTextInput c for c in 'Wi'
  @editor.onCommandKey {}, 0, 27 # esc
  deepEqual @editor.getCursorPosition(), row: 0, column: 8
  @editor.onTextInput 'i'
  @editor.onCommandKey {}, 0, 27 # esc
  deepEqual @editor.getCursorPosition(), row: 0, column: 7
  @editor.onTextInput 'a'
  @editor.onCommandKey {}, 0, 27 # esc
  deepEqual @editor.getCursorPosition(), row: 0, column: 7
