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
  
  test 'c operator', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    editor.onTextInput(char) for char in 'cWsorta'
    editor.onCommandKey {}, 0, 27 # esc
    eq currentLine(editor), "sorta = function(obj, iterator, context) {"

    editor.navigateTo 0, 21
    editor.onTextInput(char) for char in 'c4bfunky('
    editor.onCommandKey {}, 0, 27 # esc
    eq currentLine(editor), "sorta = funky( iterator, context) {"

    eq editor.session.doc.getLength(), 16
    editor.navigateTo 6, 0
    editor.onTextInput(char) for char in 'ckkablammo!'
    eq currentLine(editor), "kablammo!"
    eq editor.session.doc.getLength(), 15

  test 'd operator', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    module.startup env: {editor}

    editor.navigateTo 0, 11
    editor.onTextInput char for char in 'd11W'
    eq currentLine(editor), "_.sortBy = {"

    eq editor.session.doc.getLength(), 14
    editor.onTextInput char for char in 'dj'
    eq editor.session.doc.getLength(), 12

  test 'y operator', ->
    editor = new Editor(new MockRenderer(), new EditSession js_code)
    jim = module.startup env: {editor}

    editor.onTextInput(char) for char in 'y3W'
    eq jim.registers['"'], "_.sortBy = function(obj, "

    editor.onTextInput(char) for char in 'yj'
    eq jim.registers['"'], """
      _.sortBy = function(obj, iterator, context) {
        return _.pluck(_.map(obj, function(value, index, list) {

    """
