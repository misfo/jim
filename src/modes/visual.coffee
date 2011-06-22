Jim.modes.visual =
  regex: ///
    ^
    (\d*)
    (#{Jim.movements.source})?
  ///

  parse: (buffer) ->
    match = buffer.match @regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return method: 'doNothing'

    [fullMatch, numberPrefix, movement] = match
    numberPrefix = parseInt(numberPrefix) if numberPrefix

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
    else
      return 'continueBuffering'

    {method, args, changeToMode}
