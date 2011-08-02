define (require, exports, module) ->
  onKeypress: ->
    # insert mode just passes all keystrokes through (except <esc>)
    true
