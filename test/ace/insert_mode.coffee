require ['ace/edit_session', 'ace/editor', 'ace/test/mockrenderer', 'jim/ace/module', 'jim/ace/adaptor', 'text!test/fixtures/sort_by.js'], ->
  {EditSession} = require 'ace/edit_session'
  {Editor} = require 'ace/editor'
  MockRenderer = require 'ace/test/mockrenderer'
  module = require 'jim/ace/module'
  {adaptor} = require 'jim/ace/adaptor'

  MockRenderer::setStyle = (->)
  MockRenderer::unsetStyle = (->)

  js_code = require 'text!test/fixtures/sort_by.js'
  
  test 'insert mode leaves the cursor in the right spot', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    jim = module.startup env: {editor}

    editor.onTextInput c for c in 'Wi'
    editor.onCommandKey {}, 0, 27 # esc
    deepEqual editor.getCursorPosition(), row: 0, column: 8
    editor.onTextInput 'i'
    editor.onCommandKey {}, 0, 27 # esc
    deepEqual editor.getCursorPosition(), row: 0, column: 7
    editor.onTextInput 'a'
    editor.onCommandKey {}, 0, 27 # esc
    deepEqual editor.getCursorPosition(), row: 0, column: 7
