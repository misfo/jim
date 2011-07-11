require ['ace/edit_session', 'ace/editor', 'ace/test/mockrenderer', 'jim/ace/module', 'jim/ace/adaptor', 'text!test/fixtures/sort_by.js'], ->
  {EditSession} = require 'ace/edit_session'
  {Editor} = require 'ace/editor'
  MockRenderer = require 'ace/test/mockrenderer'
  module = require 'jim/ace/module'
  {adaptor} = require 'jim/ace/adaptor'

  MockRenderer::setStyle = (->)
  MockRenderer::unsetStyle = (->)

  cursorPositionAfter = (editor, command) ->
    editor.onTextInput(char) for char in command
    editor.getCursorPosition()

  js_code = require 'text!test/fixtures/sort_by.js'
  
  test 'h motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 1, 14

    deepEqual cursorPositionAfter(editor, 'h'), row: 1, column: 13
    deepEqual cursorPositionAfter(editor, 'h'), row: 1, column: 12
    deepEqual cursorPositionAfter(editor, '12h'), row: 1, column: 0
    deepEqual cursorPositionAfter(editor, 'h'), row: 1, column: 0

  test 'j motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'j'), row: 1, column: 0
    deepEqual cursorPositionAfter(editor, 'j'), row: 2, column: 0
    deepEqual cursorPositionAfter(editor, '12j'), row: 14, column: 0
    #deepEqual cursorPositionAfter(editor, 'j'), row: 14, column: 0

  test 'k motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 5, 0

    deepEqual cursorPositionAfter(editor, 'k'), row: 4, column: 0
    deepEqual cursorPositionAfter(editor, 'k'), row: 3, column: 0
    deepEqual cursorPositionAfter(editor, '3k'), row: 0, column: 0
    deepEqual cursorPositionAfter(editor, 'k'), row: 0, column: 0

  test 'l motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'l'), row: 0, column: 1
    deepEqual cursorPositionAfter(editor, 'l'), row: 0, column: 2
    deepEqual cursorPositionAfter(editor, '42l'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'l'), row: 0, column: 44

  test 'E motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'E'), row: 0, column: 7
    deepEqual cursorPositionAfter(editor, 'E'), row: 0, column: 9
    deepEqual cursorPositionAfter(editor, 'E'), row: 0, column: 23
    deepEqual cursorPositionAfter(editor, '3E'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'E'), row: 1, column: 7
    deepEqual cursorPositionAfter(editor, '21E'), row: 7, column: 6

  test 'W motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'W'), row: 0, column: 9
    deepEqual cursorPositionAfter(editor, 'W'), row: 0, column: 11
    deepEqual cursorPositionAfter(editor, 'W'), row: 0, column: 25
    deepEqual cursorPositionAfter(editor, '2W'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'W'), row: 1, column: 2
    deepEqual cursorPositionAfter(editor, '18W'), row: 6, column: 2

  test 'B motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 4, 15

    deepEqual cursorPositionAfter(editor, 'B'), row: 4, column: 6
    deepEqual cursorPositionAfter(editor, 'B'), row: 3, column: 14
    deepEqual cursorPositionAfter(editor, '12B'), row: 0, column: 35

  test 'e motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'e'), row: 0, column: 1
    deepEqual cursorPositionAfter(editor, 'e'), row: 0, column: 7
    deepEqual cursorPositionAfter(editor, 'e'), row: 0, column: 9
    deepEqual cursorPositionAfter(editor, 'e'), row: 0, column: 18
    deepEqual cursorPositionAfter(editor, 'e'), row: 0, column: 19
    deepEqual cursorPositionAfter(editor, 'e'), row: 0, column: 22
    deepEqual cursorPositionAfter(editor, '6e'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'e'), row: 1, column: 7
    deepEqual cursorPositionAfter(editor, '28e'), row: 4, column: 24

  test 'w motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'w'), row: 0, column: 1
    deepEqual cursorPositionAfter(editor, 'w'), row: 0, column: 2
    deepEqual cursorPositionAfter(editor, 'w'), row: 0, column: 9
    deepEqual cursorPositionAfter(editor, 'w'), row: 0, column: 11
    deepEqual cursorPositionAfter(editor, '8w'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'w'), row: 1, column: 2
    deepEqual cursorPositionAfter(editor, '3w'), row: 1, column: 11
    deepEqual cursorPositionAfter(editor, 'w'), row: 1, column: 16
    deepEqual cursorPositionAfter(editor, 'w'), row: 1, column: 17

  test 'b motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 4, 15

    deepEqual cursorPositionAfter(editor, 'b'), row: 4, column: 6
    deepEqual cursorPositionAfter(editor, 'b'), row: 3, column: 19
    deepEqual cursorPositionAfter(editor, 'b'), row: 3, column: 14
    deepEqual cursorPositionAfter(editor, 'b'), row: 3, column: 12
    deepEqual cursorPositionAfter(editor, 'b'), row: 3, column: 6
    deepEqual cursorPositionAfter(editor, 'b'), row: 2, column: 11
    deepEqual cursorPositionAfter(editor, '17b'), row: 1, column: 16

  test '0 motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    editor.navigateTo 0, 7
    deepEqual cursorPositionAfter(editor, '0'), row: 0, column: 0

  test 'G motion', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, '3G'), row: 2, column: 4
    deepEqual cursorPositionAfter(editor, 'G'), row: 14, column: 0
    deepEqual cursorPositionAfter(editor, '1G'), row: 0, column: 0
