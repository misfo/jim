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
      var editor;
      editor = require('ace/ace').edit('editor');
      require('jim/ace/module').startup({
        env: {
          editor: editor
        }
      });
      editor.setTheme(require('ace/theme/idle_fingers'));
      return require(['jim/chromeless'], function() {
        return console.log('loaded chromeless open/save stuff');
      });
    });
  });
}).call(this);
