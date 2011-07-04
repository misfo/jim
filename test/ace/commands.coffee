require ['ace/edit_session', 'ace/editor', 'ace/test/mockrenderer', 'jim/ace/module', 'jim/ace/adaptor', 'text!test/fixtures/sort_by.js'], ->
  {EditSession} = require 'ace/edit_session'
  {Editor} = require 'ace/editor'
  MockRenderer = require 'ace/test/mockrenderer'
  module = require 'jim/ace/module'
  {adaptor} = require 'jim/ace/adaptor'

  MockRenderer::setStyle = (->)
  MockRenderer::unsetStyle = (->)

  js_code = require 'text!test/fixtures/sort_by.js'

  currentLine = (editor) ->
    editor.selection.doc.getLine editor.selection.selectionLead.row
  
  test 'C command', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 0, 11

    editor.onTextInput(char) for char in 'Cawesomes'.split ''
    #FIXME the jim instance is leaking state, this shouldn't be necessary
    editor.onTextInput "esc"
    eq currentLine(editor), "_.sortBy = awesomes"

  test 'D command', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 0, 11

    editor.onTextInput 'D'
    eq currentLine(editor), "_.sortBy = "
  
  test 'X command', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}
    editor.navigateTo 2, 11

    editor.onTextInput 'X'
    eq currentLine(editor), "    return{"
    editor.onTextInput 'X'
    eq currentLine(editor), "    retur{"
    editor.onTextInput(char) for char in '9X'.split ''
    eq currentLine(editor), "{"
    editor.onTextInput 'X'
    eq currentLine(editor), "{"
