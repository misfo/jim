(function() {
  require({
    paths: {
      jim: "./lib",
      ace: "./vendor/ace/lib/ace",
      pilot: "./vendor/ace/support/pilot/lib/pilot",
      text: "./vendor/text"
    }
  });
  require(['ace/ace', 'jim/ace/module', 'ace/theme/idle_fingers'], function() {
    return require.ready(function() {
      this.editor = require('ace/ace').edit('editor');
      require('jim/ace/module').startup({
        env: {
          editor: editor
        }
      });
      return editor.setTheme(require('ace/theme/idle_fingers'));
    });
  });
}).call(this);
