define (require, exports, module) ->
  Jim = require 'jim/jim'

  test 'that Jim modes are loaded', ->
    ok Jim.modes.insert
    ok Jim.modes.normal
    ok Jim.modes.visual
