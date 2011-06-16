commandMode =
  regex: ///
    ^
    (\d*)     # multiplier
    ([hjkl]?) # movement
    $
  ///
  execute: (match) ->
    console.log 'execute', match
    [fullMatch, multiplier, movement] = match
    args = {}

    times = parseInt(multiplier) if multiplier.length > 0
    method = switch movement
      when "h" then 'navigateLeft'
      when "j" then 'navigateDown'
      when "k" then 'navigateUp'
      when "l" then 'navigateRight'
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

  navigateUp:    (env, args, request) -> env.editor.navigateUp args.times
  navigateDown:  (env, args, request) -> env.editor.navigateDown args.times
  navigateLeft:  (env, args, request) -> env.editor.navigateLeft args.times
  navigateRight: (env, args, request) -> env.editor.navigateRight args.times

  handleKeyboard: (data, hashId, key) ->
    result = jim.keypress key
    if result?
      command:
        exec: this[result[0]]
      args: result[1]

define (require, exports, module) ->
  exports.Vim = aceAdaptor
  console.log 'exports.Vim', exports.Vim
