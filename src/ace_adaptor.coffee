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


  handleKeyboard: (data, hashId, key) ->
    return if hashId isnt 0 and (key is "" or key is String.fromCharCode 0) # do nothing if it's just a modifier key
    key = key.toUpperCase() if hashId & 4 and key.match /^[a-z]$/
    result = jim.keypress key
    if result?
      jim.setMode result.changeToMode if result.changeToMode?
      command:
        exec: this[result.method]
      args: result.args

define (require, exports, module) ->
  exports.Vim = aceAdaptor
  console.log 'exports.Vim', exports.Vim
