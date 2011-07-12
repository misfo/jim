(function() {
  var currentFile, file, menu, openFile, saveFile, ui;
  if (typeof require === "undefined" || require === null) {
    return;
  }
  this.clrequire = require;
  menu = clrequire('menu');
  ui = clrequire('ui');
  currentFile = null;
  saveFile = function() {
    var data, filePicker, fp, stream;
    data = editor.session.getValue();
    if (!currentFile) {
      filePicker = clrequire("file-picker");
      fp = filePicker.FilePicker("New file", "save");
      fp.show(function(x) {
        if (x === void 0) {
          return console.log("user selected nothing!  (canceled dialog)");
        } else {
          return currentFile = x;
        }
      });
    }
    console.log("file = " + currentFile);
    stream = clrequire("file").open(currentFile, "w");
    try {
      return stream.write(data);
    } finally {
      stream.close();
    }
  };
  openFile = function() {
    var filePicker;
    filePicker = clrequire('file-picker');
    return filePicker.FilePicker('Open', 'open').show(function(filename) {
      var modeName, stringData;
      if (!filename) {
        return;
      }
      currentFile = "" + filename;
      stringData = clrequire("file").read(currentFile);
      editor.session.setValue(stringData);
      document.getElementsByTagName('head')[0].getElementsByTagName('title')[0].innerHTML = currentFile;
      modeName = (function() {
        var _ref;
        switch ((_ref = currentFile.match(/[./\\](\w+)$/)) != null ? _ref[1] : void 0) {
          case 'coffee':
          case 'Cakefile':
            return 'coffee';
          case 'css':
            return 'css';
          case 'html':
            return 'html';
          case 'js':
            return 'javascript';
          case 'json':
            return 'json';
          case 'rb':
          case 'ru':
          case 'rake':
          case 'Rakefile':
            return 'ruby';
          default:
            return 'text';
        }
      })();
      return require(["ace/mode/" + modeName], function(mode) {
        editor.session.setMode(new mode.Mode());
        editor.session.setUseSoftTabs(true);
        return editor.session.setTabSize(2);
      });
    });
  };
  file = menu.Menu({
    parent: ui.getMenu(),
    label: "File",
    children: [
      menu.Menu({
        label: "Open File",
        hotkey: "accel-o",
        onClick: function(e) {
          return openFile();
        }
      }), menu.Menu({
        label: "Save",
        hotkey: "accel-s",
        onClick: function(e) {
          return saveFile();
        }
      })
    ]
  });
}).call(this);
