modes =
  normal:
    regex: ///
      ^
      ([i])|        # insert mode transition
      (?:
        (\d*)       # number prefix (multiplier, line number, ...)
        (?:
          ([hjkl])| # movement
          (G)       # go!
        )?
      )
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
