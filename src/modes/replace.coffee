define (require, exports, module) ->
  execute: ->
    # no need to keep a buffer
    @clearBuffer()
    # replace mode just passes all keystrokes through (except <esc>)
    true
