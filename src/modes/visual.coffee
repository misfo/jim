Jim.modes.visual =
  regex: ///
    ^
    (\d*)
    (?:
      (#{Jim.movements.source})|
      ([cd])                     # operators
    )?
  ///

  parse: (buffer) ->
    match = buffer.match @regex
    console.log 'visual parse match', match
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return method: 'doNothing'

    [fullMatch, numberPrefix, movement, operator] = match
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
    else if operator
      switch operator
        when 'c'
          method = 'removeSelection'
          changeToMode = 'insert'
        when 'd'
          method = 'removeSelection'
          changeToMode = 'normal'
    else
      return 'continueBuffering'

    {method, args, changeToMode}
