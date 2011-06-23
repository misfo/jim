Jim.modes.normal =
  regex: ///
    ^
    ([iIAC])|            # insert mode transition
    ([vV])|              # visual mode transition
    (D)|                 # delete to end of line command
    (?:
      (\d*)              # number prefix (multiplier, line number, ...)
      (?:
        (#{Jim.movements.source})|
        ([xX])|          # deletions
        (G)              # go!
      )?
    )
  ///

  parse: (buffer) ->
    match = buffer.match(@regex)
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return method: 'doNothing'
    console.log 'parse match', match
    [fullMatch, insertTransition, visualTransition, deleteCommand, numberPrefix, movement, deletion, go] = match
    numberPrefix = parseInt(numberPrefix) if numberPrefix

    method = 'doNothing'
    args = {}
    changeToMode = null

    if insertTransition
      switch insertTransition
        when "A" then method = 'navigateLineEnd'
        when "C" then method = 'removeToLineEnd'
        when "I" then method = 'navigateLineStart'
      changeToMode = 'insert'
    else if visualTransition
      changeToMode = if visualTransition is 'V' then 'visual:linewise' else 'visual:characterwise'
    else if deleteCommand
      switch deleteCommand
        when "D" then method = 'removeToLineEnd'
    else if movement
      args.times = numberPrefix
      method = switch movement
        when "h" then 'navigateLeft'
        when "j" then 'navigateDown'
        when "k" then 'navigateUp'
        when "l" then 'navigateRight'
    else if deletion
      args.times = numberPrefix
      method = switch deletion
        when "x" then 'removeRight'
        when "X" then 'removeLeft'
    else if go
      args.lineNumber = numberPrefix
      method = if numberPrefix then 'gotoLine' else 'navigateFileEnd'
    else
      return 'continueBuffering'

    {method, args, changeToMode}
