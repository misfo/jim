# most of this is borrowed from the chromeless example app: 
# github.com/taboca/Chromeless-Standalone-Text-Editor-with-Ace/blob/master/src/index.js

# only run this if we're in a Chromeless app
return unless require?

@clrequire = require

menu = clrequire 'menu'
ui   = clrequire 'ui'

currentFile = null

saveFile = ->
  data = editor.session.getValue()
  unless currentFile
    filePicker = clrequire("file-picker")
    fp = filePicker.FilePicker("New file", "save")
    fp.show (x) ->
      if x == undefined
        console.log "user selected nothing!  (canceled dialog)"
      else
        currentFile = x
  console.log "file = " + currentFile
  stream = clrequire("file").open(currentFile, "w")
  try
    stream.write data
  finally
    stream.close()

openFile = ->
  filePicker = clrequire("file-picker")
  fp = filePicker.FilePicker()
  fp.title = "Hi!  Pick some files!"
  fp.mode = "multiple"
  fp.show (x) ->
    return  unless x
    console.log "you picked " + x.length + " files"
    i = 0
    
    while i < x.length
      currentFile = "" + x[i]
      stringData = clrequire("file").read(currentFile)
      editor.session.setValue stringData
      i++

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
