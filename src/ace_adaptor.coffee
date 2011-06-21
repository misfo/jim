jim = new Jim()

aceAdaptor =
  doNothing: ->

  gotoLine: (env, args, request) -> env.editor.gotoLine args.lineNumber

  navigateUp:    (env, args, request) -> env.editor.navigateUp args.times
  navigateDown:  (env, args, request) -> env.editor.navigateDown args.times
  navigateLeft:  (env, args, request) -> env.editor.navigateLeft args.times
  navigateRight: (env, args, request) -> env.editor.navigateRight args.times

  navigateFileEnd:   (env, args, request) -> env.editor.navigateFileEnd()
  navigateLineEnd:   (env, args, request) -> env.editor.navigateLineEnd()
  navigateLineStart: (env, args, request) -> env.editor.navigateLineStart()

  removeLeft: (env, args, request) ->
    env.editor.removeLeft() for i in [1..(args.times or 1)]
  removeRight: (env, args, request) ->
    env.editor.removeRight() for i in [1..(args.times or 1)]
  removeToLineEnd: (env, args, request) -> env.editor.removeToLineEnd()


  isntCharacterKey: (hashId, key) ->
    (hashId isnt 0 and (key is "" or key is String.fromCharCode 0)) or key.length > 1

  handleKeyboard: (data, hashId, key) ->
    if key is "esc"
      jim.onEscape()
      return command: exec: @doNothing
    else if @isntCharacterKey(hashId, key)
      # do nothing if it's just a modifier key
      return

    key = key.toUpperCase() if hashId & 4 and key.match /^[a-z]$/
    result = jim.onKeypress key
    if result?
      jim.setMode result.changeToMode if result.changeToMode?
      command:
        exec: this[result.method]
      args: result.args

define (require, exports, module) ->
  require('pilot/dom').importCssString """
    .jim-normal-mode div.ace_cursor {
      border: 0;
      background-color: #91FF00;
      opacity: 0.5;
    }
  """

  console.log 'defining startup'
  startup = (data, reason) ->
    if not data.env.editor
      setTimeout startup, 0, data, reason
      return
    console.log 'executing startup'
    {editor} = data.env
    editor.setKeyboardHandler aceAdaptor

    jim.onModeChange = (state) ->
      if state is 'normal'
        editor.setStyle 'jim-normal-mode'
      else
        editor.unsetStyle 'jim-normal-mode'

    jim.onModeChange 'normal'
  exports.startup = startup
  return
