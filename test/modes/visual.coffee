require ['jim/modes/visual'], ->
  visual = require 'jim/modes/visual'

  test 'visual mode invalid command parsing', ->
    deepEqual visual.parse("m"), {}

  test 'visual mode partial command parsing', ->
    eq visual.parse("2"), 'continueBuffering'

  test 'visual mode motion parsing', ->
    deepEqual visual.parse("j"), action: 'selectDown'
    deepEqual visual.parse('2k'), action: 'selectUp', args: {times: 2}
    deepEqual visual.parse('E'), action: 'selectWORDEnd'
    deepEqual visual.parse('4W'), action: 'selectNextWORD', args: {times: 4}
    deepEqual visual.parse('B'), action: 'selectBackWORD'

  test 'visual mode operator parsing', ->
    deepEqual visual.parse('d'), action: 'deleteSelection', changeToMode: 'normal', args: {register: '"'}
    deepEqual visual.parse('c'), action: 'deleteSelection', changeToMode: 'insert', args: {register: '"'}
    deepEqual visual.parse('y'), action: 'yankSelection', changeToMode: 'normal', args: {register: '"'}
