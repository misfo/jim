modes =
  normal:
    regex: ///
      ^
      ([iIAC])|       # insert mode transition
      (D)|            # delete to end of line command
      (?:
        (\d*)         # number prefix (multiplier, line number, ...)
        (?:
          ([hjklxX])| # multipliable command (movements, deletions)
          (G)         # go!
        )?
      )
    ///

    parse: (buffer) ->
      match = buffer.match(@regex)
      if not match? or match[0] is ""
        console.log "unrecognized command: #{buffer}"
        return method: 'doNothing'
      console.log 'parse match', match
      [fullMatch, insertTransition, deleteCommand, numberPrefix, multipliable, go] = match

      method = 'doNothing'
      args = {}
      changeToMode = null

      if insertTransition
        switch insertTransition
          when "A" then method = 'navigateLineEnd'
          when "C" then method = 'removeToLineEnd'
          when "I" then method = 'navigateLineStart'
        changeToMode = 'insert'
      else if deleteCommand
        switch deleteCommand
          when "D" then method = 'removeToLineEnd'
      else if multipliable
        args.times = parseInt(numberPrefix) if numberPrefix
        method = switch multipliable
          when "h" then 'navigateLeft'
          when "j" then 'navigateDown'
          when "k" then 'navigateUp'
          when "l" then 'navigateRight'
          when "x" then 'removeRight'
          when "X" then 'removeLeft'
      else if go
        args.lineNumber = parseInt(numberPrefix) if numberPrefix
        method = if numberPrefix then 'gotoLine' else 'navigateFileEnd'
      else
        return 'continueBuffering'

      {method, args, changeToMode}

  insert:
    parse: ->
