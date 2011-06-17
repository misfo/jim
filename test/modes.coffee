{normal} = modes

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
