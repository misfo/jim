{visual} = exports.Jim.modes

test 'visual mode invalid command parsing', ->
  deepEqual visual.parse("e"), method: 'doNothing'

test 'visual mode partial command parsing', ->
  eq visual.parse("2"), 'continueBuffering'

test 'visual mode movement parsing', ->
  eq visual.parse("j").method, 'selectDown'

  r = visual.parse "2k"
  eq r.method, 'selectUp'
  deepEqual r.args, {times: 2}
