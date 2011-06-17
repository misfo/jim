modes =
  normal:
    regex: ///
      ^
      ([iI])|        # insert mode transition
      (?:
        (\d*)       # number prefix (multiplier, line number, ...)
        (?:
          ([hjkl])| # movement
          (G)       # go!
        )?
      )
    ///

    parse: (buffer) ->
      match = buffer.match(@regex)
      if not match? or match[0] is ""
        console.log "unrecognized command: #{buffer}"
        return method: 'doNothing'
      console.log 'parse match', match
      [fullMatch, insertTransition, numberPrefix, movement, go] = match

      method = 'doNothing'
      args = {}
      changeToMode = null

      if insertTransition
        switch insertTransition
          when "I" then method = 'navigateLineStart'
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
      else
        return 'continueBuffering'

      {method, args, changeToMode}

  insert:
    parse: ->
