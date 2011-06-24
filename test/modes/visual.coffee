{visual} = exports.Jim.modes

test 'visual mode invalid command parsing', ->
  deepEqual visual.parse("e"), {}

test 'visual mode partial command parsing', ->
  eq visual.parse("2"), 'continueBuffering'

test 'visual mode motion parsing', ->
  deepEqual visual.parse("j"), action: 'selectDown'
  deepEqual visual.parse('2k'), action: 'selectUp', args: {times: 2}

test 'visual mode operator parsing', ->
  deepEqual visual.parse('d'), action: 'deleteSelection', changeToMode: 'normal', args: {register: '"'}
  deepEqual visual.parse('c'), action: 'deleteSelection', changeToMode: 'insert', args: {register: '"'}
  deepEqual visual.parse('y'), action: 'yankSelection', changeToMode: 'normal', args: {register: '"'}
