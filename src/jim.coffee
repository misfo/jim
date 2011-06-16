modes =
  normal:
    regex: ///
      ^
      ([i])         # insert mode transition
      |(?:
        (\d*)     # number prefix (multiplier, line number, ...)
        ([hjkl]?) # movement
        (G?)      # go!
      )
      $
    ///

    execute: (match) ->
      console.log 'execute', match
      [fullMatch, insertTransition, numberPrefix, movement, go] = match

      method = 'doNothing'
      args = {}
      changeToMode = null

      if insertTransition
        changeToMode = 'insert'
      else if movement
        args.times = parseInt(numberPrefix) if numberPrefix
        method = switch movement
          when "h" then 'navigateLeft'
          when "j" then 'navigateDown'
          when "k" then 'navigateUp'
          when "l" then 'navigateRight'
      else if go
        args.lineNumber = parseInt(numberPrefix) if numberPrefix
        method = if numberPrefix then 'gotoLine' else 'navigateFileEnd'

      {method, args, changeToMode}

  insert:
    #FIXME this shouldn't be needed
    regex: /.*/
    execute: ->
    

class Jim
  constructor: ->
    @buffer = ''
    @setMode 'normal'

  setMode: (modeName) ->
    console.log 'setMode', modeName
    @buffer = ''
    @mode = modes[modeName]

  keypress: (key) ->
    if key is "esc"
      @setMode 'normal'
      return
    @buffer += key
    console.log '@buffer', @buffer
    match = @buffer.match(@mode.regex)
    result = null
    if match?
      result = @mode.execute(match)
      @buffer = '' if result? and result.method isnt 'doNothing'
    else
      console.log "unrecognized command: #{@buffer}"
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
      jim.setMode result.changeToMode if result.changeToMode?
      command:
        exec: this[result.method]
      args: result.args

define (require, exports, module) ->
  exports.Vim = aceAdaptor
  console.log 'exports.Vim', exports.Vim
