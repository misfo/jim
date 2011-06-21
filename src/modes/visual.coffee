Jim.modes.visual =
  regex: ///
    ^
    (\d*)
    (#{Jim.movements.source})
  ///

  parse: (buffer) ->
    match = buffer.match @regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return method: 'doNothing'

    [fullMatch, numberPrefix, movement] = match

    method = 'doNothing'
    args = {}
    changeToMode = null

    if movement
      args.times = numberPrefix
      method = switch movement
        when "h" then 'selectLeft'
        when "j" then 'selectDown'
        when "k" then 'selectUp'
        when "l" then 'selectRight'

    {method, args, changeToMode}
