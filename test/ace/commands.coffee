module 'Ace: commands',
  setup: ->
    @editor = new Editor(new MockRenderer(), new EditSession js_code)
    @jim = aceModule.startup env: {editor: @editor}

test 'C', ->
  @editor.navigateTo 0, 11

  @editor.onTextInput(char) for char in 'Cawesomes'.split ''
  eq currentLine(@editor), "_.sortBy = awesomes"

test 'D', ->
  @editor.navigateTo 0, 11

  @editor.onTextInput 'D'
  eq currentLine(@editor), "_.sortBy = "

test 'p', ->
  @editor.onTextInput c for c in 'y3l2p'
  eq currentLine(@editor), "__.s_.s.sortBy = function(obj, iterator, context) {"

test 'x', ->
  @editor.onTextInput 'x'
  eq currentLine(@editor), ".sortBy = function(obj, iterator, context) {"
  @editor.onTextInput c for c in '3x'
  eq currentLine(@editor), "rtBy = function(obj, iterator, context) {"

test 'X', ->
  @editor.navigateTo 2, 11

  @editor.onTextInput 'X'
  eq currentLine(@editor), "    return{"
  @editor.onTextInput 'X'
  eq currentLine(@editor), "    retur{"
  @editor.onTextInput(char) for char in '9X'.split ''
  eq currentLine(@editor), "{"
  @editor.onTextInput 'X'
  eq currentLine(@editor), "{"

test 'o,O', ->
  @editor.onTextInput c for c in 'Onew line'
  @editor.onCommandKey {}, 0, 27 # esc
  eq currentLine(@editor), "new line"
  eq @editor.selection.selectionLead.row, 0
  eq @editor.session.doc.getLength(), 17

  @editor.onTextInput c for c in 'oanother line'
  @editor.onCommandKey {}, 0, 27 # esc
  eq currentLine(@editor), 'another line'
  eq @editor.selection.selectionLead.row, 1
  eq @editor.session.doc.getLength(), 18
