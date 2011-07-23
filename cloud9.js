define(function(require, exports, module) {
  console.log("define");
  // this doesn't work, have to add path to server/cloud9/ide.js
  //require({paths: {jim: "/static/ext/jim/lib"}});
  var ide = require('core/ide'),
    ext = require('core/ext'),
    editors = require('ext/editors/editors'),
    module = require('jim/ace/module');
 
  ext.register("ext/jim/cloud9", {
    name: "Jim",
    dev: "Trent Ogren",
    alone: true,
    type: ext.EDITOR,
    contentTypes: [],
    init: function(page) { return console.log('init', page); },
    hook: function() {
      console.log('hook');
      ide.addEventListener('keybindingschange', function(e) {
        console.log('keybindingschange', e);
        if (typeof ceEditor === "undefined" || ceEditor === null) {
          return;
        }
        module.startup({env: {editor: ceEditor.$editor}});
      });
    },
    enable: function() { return console.log('enable'); },
    disable: function() { return console.log('disable'); },
    destroy: function() { return console.log('destroy'); }
  });
});