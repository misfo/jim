{Jim} = exports

test 'that Jim modes are loaded', ->
  ok Jim.modes.insert
  ok Jim.modes.normal
  ok Jim.modes.visual
