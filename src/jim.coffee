commandMode =
  regex: ///
    ^
    (\d*)     # number prefix (multiplier, line number, ...)
    ([hjkl]?) # movement
    (G?)      # go!
    $
  ///

  execute: (match) ->
    console.log 'execute', match
    [fullMatch, numberPrefix, movement, go] = match
    args = {}

    if movement
      args.times = parseInt(numberPrefix) if numberPrefix
      method = switch movement
        when "h" then 'navigateLeft'
        when "j" then 'navigateDown'
        when "k" then 'navigateUp'
        when "l" then 'navigateRight'
    else if go
      args.lineNumber = parseInt(numberPrefix) if numberPrefix
      method = if numberPrefix then 'gotoLine' else 'navigateFileEnd'

    if method
      [method, args]
    

class Jim
  constructor: ->
    @buffer = ''
    @mode = commandMode

  keypress: (key) ->
    @buffer += key
    console.log '@buffer', @buffer
    match = @buffer.match(@mode.regex)
    result = null
    if match?
      result = @mode.execute(match)
      @buffer = '' if result?
      result ?= ['doNothing', {}]
    else
      console.log "unrecognized command: #{@buffer}"
      #FIXME this won't work for other modes
      result = ['doNothing', {}]
      @buffer = ''
    
    result

jim = new Jim()

aceAdaptor =
  doNothing: ->

  gotoLine: (env, args, request) -> env.editor.gotoLine args.lineNumber

  navigateUp:    (env, args, request) -> env.editor.navigateUp args.times
  navigateDown:  (env, args, request) -> env.editor.navigateDown args.times
  navigateLeft:  (env, args, request) -> env.editor.navigateLeft args.times
  navigateRight: (env, args, request) -> env.editor.navigateRight args.times

  navigateFileEnd: (env, args, request) -> env.editor.navigateFileEnd()


  handleKeyboard: (data, hashId, key) ->
    return if hashId isnt 0 and (key is "" or key is String.fromCharCode 0) # do nothing if it's just a modifier key
    key = key.toUpperCase() if hashId & 4 and key.match /^[a-z]$/
    result = jim.keypress key
    if result?
      command:
        exec: this[result[0]]
      args: result[1]

define (require, exports, module) ->
  exports.Vim = aceAdaptor
  console.log 'exports.Vim', exports.Vim
