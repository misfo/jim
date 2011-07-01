require ['ace/edit_session', 'ace/editor', 'ace/test/mockrenderer', 'jim/ace/module', 'jim/ace/adaptor'], ->
  {EditSession} = require 'ace/edit_session'
  {Editor} = require 'ace/editor'
  MockRenderer = require 'ace/test/mockrenderer'
  module = require 'jim/ace/module'
  {adaptor} = require 'jim/ace/adaptor'

  MockRenderer::setStyle = (->)
  MockRenderer::unsetStyle = (->)

  test 'E command', ->
    session = new EditSession "this isn't text!?$%#9 "
    editor = new Editor(new MockRenderer(), session)
    module.startup env: {editor}

    editor.onTextInput "E"
    deepEqual editor.getCursorPosition(), row: 0, column: 3
    editor.onTextInput "E"
    deepEqual editor.getCursorPosition(), row: 0, column: 9
    editor.onTextInput "E"
    deepEqual editor.getCursorPosition(), row: 0, column: 20
