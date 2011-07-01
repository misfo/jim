# these are borrowed from the chromeless example app: 
# github.com/taboca/Chromeless-Standalone-Text-Editor-with-Ace/blob/master/src/index.js

currentFile = null

saveFile = ->
  data = editorSession.getValue()
  unless currentFile
    filePicker = require("file-picker")
    fp = filePicker.FilePicker("New file", "save")
    fp.show (x) ->
      if x == undefined
        console.log "user selected nothing!  (canceled dialog)"
      else
        currentFile = x
  console.log "file = " + currentFile
  stream = require("file").open(currentFile, "w")
  try
    stream.write data
  finally
    stream.close()

openFile = ->
  filePicker = require("file-picker")
  fp = filePicker.FilePicker()
  fp.title = "Hi!  Pick some files!"
  fp.mode = "multiple"
  fp.show (x) ->
    return  unless x
    console.log "you picked " + x.length + " files"
    i = 0
    
    while i < x.length
      currentFile = "" + x[i]
      stringData = require("file").read(currentFile)
      editorSession.setValue stringData
      i++

menu = require ['menu'], ->
  file = menu.Menu(
    parent: ui.getMenu()
    label: "File"
    children: [ menu.Menu(
      label: "Open File"
      hotkey: "accel-o"
      onClick: (e) ->
        openFile()
    ), menu.Menu(
      label: "Save"
      hotkey: "accel-s"
      onClick: (e) ->
        saveFile()
    ) ]
  )
