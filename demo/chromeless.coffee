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
  filePicker = clrequire 'file-picker'
  filePicker.FilePicker('Open', 'open').show (filename) ->
    return unless filename

    currentFile = "#{filename}"
    stringData = clrequire("file").read currentFile
    editor.session.setValue stringData

    document
      .getElementsByTagName('head')[0]
      .getElementsByTagName('title')[0]
      .innerHTML = currentFile

    modeName = switch currentFile.match(/[./\\](\w+)$/)?[1]
      when 'coffee', 'Cakefile'           then 'coffee'
      when 'css'                          then 'css'
      when 'html'                         then 'html'
      when 'js'                           then 'javascript'
      when 'json'                         then 'json'
      when 'rb', 'ru', 'rake', 'Rakefile' then 'ruby'
      else                                     'text'
    require ["ace/mode/#{modeName}"], (mode) ->
      editor.session.setMode new mode.Mode()
      editor.session.setUseSoftTabs true
      editor.session.setTabSize 2

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
