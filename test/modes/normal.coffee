{normal} = exports.Jim.modes

test 'normal mode invalid command parsing', ->
  deepEqual normal.parse("e"), {}

test 'normal mode partial command parsing', ->
  deepEqual normal.parse("2"), 'continueBuffering'

test 'normal mode insert transition parsing', ->
  deepEqual normal.parse('i'), changeToMode: 'insert'
  deepEqual normal.parse('I'), action: 'navigateLineStart', changeToMode: 'insert'
  deepEqual normal.parse('A'), action: 'navigateLineEnd', changeToMode: 'insert'
  deepEqual normal.parse('C'), action: 'removeToLineEnd', changeToMode: 'insert'

test 'normal mode visual transition parsing', ->
  deepEqual normal.parse('v'), changeToMode: 'visual:characterwise'
  deepEqual normal.parse('V'), changeToMode: 'visual:linewise'

test 'normal mode movement parsing', ->
  deepEqual normal.parse('j'), action: 'navigateDown'
  deepEqual normal.parse('2k'), action: 'navigateUp', args: {times: 2}

test 'normal mode jump parsing', ->
  deepEqual normal.parse('G'), action: 'navigateFileEnd'
  deepEqual normal.parse('13G'), action: 'gotoLine', args: {lineNumber: 13}

test 'normal mode delete parsing', ->
  deepEqual normal.parse('D'), action: 'removeToLineEnd'
  deepEqual normal.parse('x'), action: 'removeRight'
  deepEqual normal.parse('X'), action: 'removeLeft'
