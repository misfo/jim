define (require, exports, module) ->
  motions = require 'jim/motions'

  regex: ///
    ^
    (\d*)
    (?:
      (#{motions.regex.source})|
      ([ydc])                    # operators
    )?
  ///

  parse: (buffer) ->
    match = buffer.match @regex
    if not match? or match[0] is ""
      console.log "unrecognized command: #{buffer}"
      return {}

    [fullMatch, numberPrefix, motion, operator] = match
    numberPrefix = parseInt(numberPrefix) or null

    result = {}

    if motion
      result.action = "select#{motions.map[motion]}"
      if numberPrefix
        result.args = times: numberPrefix
    else if operator
      switch operator
        when 'c'
          result = action: 'deleteSelection', changeToMode: 'insert'
        when 'd'
          result = action: 'deleteSelection', changeToMode: 'normal'
        when 'y'
          result = action: 'yankSelection', changeToMode: 'normal'
      result.args = register: '"'
    else
      result = 'continueBuffering'

    result
