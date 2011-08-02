define (require, exports, module) ->

  # the base class for all commands
  class exports.Command
    constructor: (@count = 1) ->
    isRepeatable: yes
    isComplete: ->
      # if the class specifies a regex that should follow match
      # some keys following the command and they haven't been
      # matched yet, the command isn't complete
      if @constructor.followedBy then @followedBy else true


  return
