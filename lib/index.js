(function() {
  var fileRequire, fileToEdit;
  require({
    paths: {
      root: ".",
      jim: "./lib",
      ace: "./vendor/ace/lib/ace",
      pilot: "./vendor/pilot/lib/pilot",
      text: "./vendor/text"
    }
  });
  fileToEdit = 'README.md';
  fileRequire = "text!root/" + fileToEdit;
  require(['ace/ace', 'jim/ace', fileRequire, 'ace/theme/idle_fingers'], function() {
    return require.ready(function() {
      var jim;
      this.editor = require('ace/ace').edit('editor');
      jim = require('jim/ace').startup({
        env: {
          editor: editor
        }
      });
      jim.debugMode = true;
      editor.session.setValue(require(fileRequire));
      return editor.setTheme(require('ace/theme/idle_fingers'));
    });
  });
}).call(this);
