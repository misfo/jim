Jim.modes.visual =
  regex: ///
    ^
    (\d*)
    (?:
      (#{Jim.movements.source})|
      ([ydc])                    # operators
    )?
  ///

  parse: (buffer) ->
    match = buffer.match @regex
    console.log 'visual parse match', match
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return {}

    [fullMatch, numberPrefix, movement, operator] = match
    numberPrefix = parseInt(numberPrefix) or null

    result = {}

    if movement
      if numberPrefix
        result.args = {times: numberPrefix}
      result.action = switch movement
        when "h" then 'selectLeft'
        when "j" then 'selectDown'
        when "k" then 'selectUp'
        when "l" then 'selectRight'
    else if operator
      switch operator
        when 'c'
          result = action: 'removeSelection', changeToMode: 'insert'
        when 'd'
          result = action: 'removeSelection', changeToMode: 'normal'
        when 'y'
          result = action: 'yankSelection', changeToMode: 'normal'
      result.args = register: '"'
    else
      result = 'continueBuffering'

    result
