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
  exports.Vim = aceAdaptor
  console.log 'exports.Vim', exports.Vim
