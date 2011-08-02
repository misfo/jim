define (require, exports, module) ->
  onKeypress: ->
    # replace mode just passes all keystrokes through (except <esc>)
    true
