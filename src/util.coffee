define (require, exports, module) ->
  # this takes an objects property names and makes a regex that
  # will match any of them (partial matches as well)
  propertyNameRegex: (obj) ->
    singleChar = []
    dualChar = []
    for own k, v of obj
      switch k.length
        when 1 then singleChar.push k 
        # second character is optional (because of partial matches)
        when 2 then dualChar.push "#{k}?"

    ///
      [#{(c for c in singleChar).join ''}]
      |
      #{(c for c in dualChar).join '|'}
    ///
