require ['ace/edit_session', 'ace/editor', 'ace/test/mockrenderer', 'jim/ace/module', 'jim/ace/adaptor', 'text!test/fixtures/sort_by.js'], ->
  {EditSession} = require 'ace/edit_session'
  {Editor} = require 'ace/editor'
  MockRenderer = require 'ace/test/mockrenderer'
  module = require 'jim/ace/module'
  {adaptor} = require 'jim/ace/adaptor'

  MockRenderer::setStyle = (->)
  MockRenderer::unsetStyle = (->)

  cursorPositionAfter = (editor, command) ->
    editor.onTextInput(char) for char in command.split('')
    editor.getCursorPosition()

  js_code = require 'text!test/fixtures/sort_by.js'

  test 'E command', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'E'), row: 0, column: 7
    deepEqual cursorPositionAfter(editor, 'E'), row: 0, column: 9
    deepEqual cursorPositionAfter(editor, 'E'), row: 0, column: 23
    deepEqual cursorPositionAfter(editor, '3E'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'E'), row: 1, column: 7
    deepEqual cursorPositionAfter(editor, '21E'), row: 7, column: 6

  test 'W command', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    deepEqual cursorPositionAfter(editor, 'W'), row: 0, column: 9
    deepEqual cursorPositionAfter(editor, 'W'), row: 0, column: 11
    deepEqual cursorPositionAfter(editor, 'W'), row: 0, column: 25
    deepEqual cursorPositionAfter(editor, '2W'), row: 0, column: 44
    deepEqual cursorPositionAfter(editor, 'W'), row: 1, column: 2
    deepEqual cursorPositionAfter(editor, '18W'), row: 6, column: 2

  test 'B command', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    # gotta get forward before we can get back...
    deepEqual cursorPositionAfter(editor, '18W'), row: 4, column: 15

    deepEqual cursorPositionAfter(editor, 'B'), row: 4, column: 6
    deepEqual cursorPositionAfter(editor, 'B'), row: 3, column: 14
    deepEqual cursorPositionAfter(editor, '12B'), row: 0, column: 35
