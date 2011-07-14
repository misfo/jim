(function() {
  var fileRequire, fileToEdit;
  require({
    paths: {
      root: ".",
      jim: "./lib",
      ace: "./vendor/ace/lib/ace",
      pilot: "./vendor/ace/support/pilot/lib/pilot",
      text: "./vendor/text"
    }
  });
  fileToEdit = 'README.md';
  fileRequire = "text!root/" + fileToEdit;
  require(['ace/ace', 'jim/ace/module', fileRequire, 'ace/theme/idle_fingers'], function() {
    return require.ready(function() {
      this.editor = require('ace/ace').edit('editor');
      require('jim/ace/module').startup({
        env: {
          editor: editor
        }
      });
      editor.session.setValue(require(fileRequire));
      return editor.setTheme(require('ace/theme/idle_fingers'));
    });
  });
}).call(this);
