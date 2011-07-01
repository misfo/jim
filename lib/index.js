(function() {
  require({
    paths: {
      root: ".",
      jim: "./lib",
      ace: "./vendor/ace/lib/ace",
      pilot: "./vendor/ace/support/pilot/lib/pilot",
      text: "./vendor/text"
    }
  });
  require(['ace/ace', 'jim/ace/module', 'text!root/README.md', 'ace/theme/idle_fingers'], function() {
    return require.ready(function() {
      var editor;
      editor = require('ace/ace').edit('editor');
      require('jim/ace/module').startup({
        env: {
          editor: editor
        }
      });
      editor.session.setValue(require('text!root/README.md'));
      return editor.setTheme(require('ace/theme/idle_fingers'));
    });
  });
}).call(this);
