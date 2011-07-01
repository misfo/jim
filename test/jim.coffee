require ['jim/jim'], ->
  Jim = require 'jim/jim'

  test 'that Jim modes are loaded', ->
    ok Jim.modes.insert
    ok Jim.modes.normal
    ok Jim.modes.visual
