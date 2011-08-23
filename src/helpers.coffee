# the base class for all commands
class exports.Command
  constructor: (@count = 1) ->
  isRepeatable: yes
  isComplete: ->
    # if the class specifies a regex that should follow match
    # some keys following the command and they haven't been
    # matched yet, the command isn't complete
    if @constructor.followedBy then @followedBy else true

# A bunch of commands can just repeat an action however many times their `@count`
# specifies.  For example `5x` does exactly the same thing as pressing `x` five times.
# This helper is used for that case.
exports.repeatCountTimes = (func) ->
  (jim) ->
    timesLeft = @count
    func.call this, jim while timesLeft--
