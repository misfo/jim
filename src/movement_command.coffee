class MovementCommand
  constructor: (@times, @movement) ->

  execute: (editor) ->
    console.log "execute", editor
    switch @movement
      when "h" then @navigateLeft @times
      when "j" then @navigateDown @times
      when "k" then @navigateUp @times
      when "l" then @navigateRight @times
    
  navigateLeft:  (times) -> console.log 'navigateLeft', times
  navigateDown:  (times) -> console.log 'navigateDown', times
  navigateUp:    (times) -> console.log 'navigateUp', times
  navigateRight: (times) -> console.log 'navigateRight', times

#FIXME
window.MovementCommand = MovementCommand
