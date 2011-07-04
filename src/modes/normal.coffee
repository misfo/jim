define (require, exports, module) ->
  motions = require 'jim/motions'

  regex: ///
    ^
    ([iIAC])|            # insert mode transition
    ([vV])|              # visual mode transition
    (D)|                 # delete to end of line command
    (?:
      (\d*)              # number prefix (multiplier, line number, ...)
      (?:
        (#{motions.regex.source})|
        ([[pPxXu])|      # multipliable commands
        (G)              # go!
      )?
    )
  ///

  parse: (buffer) ->
    match = buffer.match(@regex)
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return {}
    [fullMatch, insertTransition, visualTransition, deleteCommand, numberPrefix,
      motion, multipliableCommand, go] = match
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
        changeToMode: 'visual:characterwise'
    else if deleteCommand
      switch deleteCommand
        when "D" then result.action = 'deleteToLineEnd'
    else if motion
      if numberPrefix
        result.args = times: numberPrefix
      result.action = "navigate#{motions.map[motion]}"
    else if multipliableCommand
      result.action = switch multipliableCommand
        when "p" then 'paste'
        when "P" then 'pasteBefore'
        when "x" then 'deleteRight'
        when "X" then 'deleteLeft'
        when "u" then 'undo'
      result.args = register: '"'
      if numberPrefix
        result.args.times = numberPrefix
    else if go
      if numberPrefix
        result.args = lineNumber: numberPrefix
      result.action = if numberPrefix then 'gotoLine' else 'navigateFileEnd'
    else
      return 'continueBuffering'

    result
