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
      return {}
    console.log 'normal parse match', match
    [fullMatch, insertTransition, visualTransition, deleteCommand, numberPrefix, movement, deletion, go] = match
    numberPrefix = parseInt(numberPrefix) if numberPrefix

    result = {}

    if insertTransition
      switch insertTransition
        when "A" then result.action = 'navigateLineEnd'
        when "C" then result.action = 'deleteToLineEnd'
        when "I" then result.action = 'navigateLineStart'
      result.changeToMode = 'insert'
    else if visualTransition
      result = if visualTransition is 'V'
        action: 'selectLine', changeToMode: 'visual:linewise'
      else
        action: 'selectRight', changeToMode: 'visual:characterwise'
    else if deleteCommand
      switch deleteCommand
        when "D" then result.action = 'deleteToLineEnd'
    else if movement
      if numberPrefix
        result.args = times: numberPrefix
      result.action = switch movement
        when "h" then 'navigateLeft'
        when "j" then 'navigateDown'
        when "k" then 'navigateUp'
        when "l" then 'navigateRight'
    else if deletion
      if numberPrefix
        result.args = times: numberPrefix
      result.action = switch deletion
        when "x" then 'deleteRight'
        when "X" then 'deleteLeft'
    else if go
      if numberPrefix
        result.args = lineNumber: numberPrefix
      result.action = if numberPrefix then 'gotoLine' else 'navigateFileEnd'
    else
      return 'continueBuffering'

    result
