require ['jim/modes/normal'], ->
  normal = require 'jim/modes/normal'

  test 'normal mode invalid command parsing', ->
    deepEqual normal.parse("e"), {}

  test 'normal mode partial command parsing', ->
    deepEqual normal.parse("2"), 'continueBuffering'

  test 'normal mode insert transition parsing', ->
    deepEqual normal.parse('i'), changeToMode: 'insert'
    deepEqual normal.parse('I'), action: 'navigateLineStart', changeToMode: 'insert'
    deepEqual normal.parse('A'), action: 'navigateLineEnd', changeToMode: 'insert'
    deepEqual normal.parse('C'), action: 'deleteToLineEnd', changeToMode: 'insert'

  test 'normal mode visual transition parsing', ->
    deepEqual normal.parse('v'), action: 'selectRight', changeToMode: 'visual:characterwise'
    deepEqual normal.parse('V'), action: 'selectLine', changeToMode: 'visual:linewise'

  test 'normal mode motion parsing', ->
    deepEqual normal.parse('j'), action: 'navigateDown'
    deepEqual normal.parse('2k'), action: 'navigateUp', args: {times: 2}
    deepEqual normal.parse('E'), action: 'navigateWORDEnd'
    deepEqual normal.parse('4W'), action: 'navigateNextWORD', args: {times: 4}
    deepEqual normal.parse('B'), action: 'navigateBackWORD'
    deepEqual normal.parse('w'), action: 'navigateNextWord'
    deepEqual normal.parse('3e'), action: 'navigateWordEnd', args: {times: 3}
    deepEqual normal.parse('b'), action: 'navigateBackWord'

  test 'normal mode jump parsing', ->
    deepEqual normal.parse('G'), action: 'navigateFileEnd'
    deepEqual normal.parse('13G'), action: 'gotoLine', args: {lineNumber: 13}

  test 'normal mode delete to end of line parsing', ->
    deepEqual normal.parse('D'), action: 'deleteToLineEnd'

  test 'normal mode multipliable command parsing', ->
    deepEqual normal.parse('x'), action: 'deleteRight', args: {register: '"'}
    deepEqual normal.parse('X'), action: 'deleteLeft', args: {register: '"'}
    deepEqual normal.parse('p'), action: 'paste', args: {register: '"'}
    deepEqual normal.parse('P'), action: 'pasteBefore', args: {register: '"'}

    deepEqual normal.parse('3P'), action: 'pasteBefore', args: {register: '"', times: 3}
    deepEqual normal.parse('12x'), action: 'deleteRight', args: {register: '"', times: 12}
