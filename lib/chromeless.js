(function() {
  var currentFile, menu, openFile, saveFile;
  currentFile = null;
  saveFile = function() {
    var data, filePicker, fp, stream;
    data = editorSession.getValue();
    if (!currentFile) {
      filePicker = require("file-picker");
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
    stream = require("file").open(currentFile, "w");
    try {
      return stream.write(data);
    } finally {
      stream.close();
    }
  };
  openFile = function() {
    var filePicker, fp;
    filePicker = require("file-picker");
    fp = filePicker.FilePicker();
    fp.title = "Hi!  Pick some files!";
    fp.mode = "multiple";
    return fp.show(function(x) {
      var i, stringData, _results;
      if (!x) {
        return;
      }
      console.log("you picked " + x.length + " files");
      i = 0;
      _results = [];
      while (i < x.length) {
        currentFile = "" + x[i];
        stringData = require("file").read(currentFile);
        editorSession.setValue(stringData);
        _results.push(i++);
      }
      return _results;
    });
  };
  menu = require(['menu'], function() {
    var file;
    return file = menu.Menu({
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
  });
}).call(this);
