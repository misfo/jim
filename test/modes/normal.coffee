{normal} = exports.Jim.modes

test 'normal mode invalid command parsing', ->
  deepEqual normal.parse("e"), method: 'doNothing'

test 'normal mode partial command parsing', ->
  eq normal.parse("2"), 'continueBuffering'

test 'normal mode insert transition parsing', ->
  r = normal.parse "i"
  eq r.method, 'doNothing'
  eq r.changeToMode, 'insert'

  r = normal.parse "I"
  eq r.method, 'navigateLineStart'
  eq r.changeToMode, 'insert'

  r = normal.parse "A"
  eq r.method, 'navigateLineEnd'
  eq r.changeToMode, 'insert'

  r = normal.parse "C"
  eq r.method, 'removeToLineEnd'
  eq r.changeToMode, 'insert'

test 'normal mode visual transition parsing', ->
  r = normal.parse 'v'
  eq r.method, 'doNothing'
  eq r.changeToMode, 'visual:characterwise'

  r = normal.parse 'V'
  eq r.method, 'doNothing'
  eq r.changeToMode, 'visual:linewise'

test 'normal mode movement parsing', ->
  eq normal.parse("j").method, 'navigateDown'

  r = normal.parse "2k"
  eq r.method, 'navigateUp'
  deepEqual r.args, {times: 2}

test 'normal mode jump parsing', ->
  eq normal.parse("G").method, 'navigateFileEnd'

  r = normal.parse "13G"
  eq r.method, 'gotoLine'
  deepEqual r.args, lineNumber: 13

test 'normal mode delete parsing', ->
  r = normal.parse "D"
  eq r.method, 'removeToLineEnd'

  r = normal.parse "x"
  eq r.method, 'removeRight'

  r = normal.parse "X"
  eq r.method, 'removeLeft'
