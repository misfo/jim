# This is a pretty standard key-to-command keymap except for a few details:
#
# * It has some built-in Vim-like smarts about the concepts of motions and
#   operators and if/how they should be available in each mode
# * It differentiates between invalid commands (`gz`) and partial commands (`g`)
class Keymap

  constructor: ->
    @normal = {}
    @visual = {}
    @operatorPending = {}


  # Mapping commands
  # ----------------

  mapIntoObject = (object, keys, command) ->
    for key in keys[0..-2]
      object[key] or= {}
      object = object[key]
    object[keys[keys.length-1]] = command

  # Map the `commandClass` to the `keys` sequence.  Map it as a visual command as well
  # if the class has a `::visualExec`.
  mapCommand: (keys, commandClass) ->
    if commandClass::exec
      mapIntoObject @normal, keys, commandClass
    if commandClass::visualExec
      mapIntoObject @visual, keys, commandClass

  # Map `motionClass` to the `keys` sequence.
  mapMotion: (keys, motionClass) ->
    mapIntoObject @normal,          keys, motionClass
    mapIntoObject @visual,          keys, motionClass
    mapIntoObject @operatorPending, keys, motionClass

  # Map `operatorClass` to the `keys` sequence.
  mapOperator: (keys, operatorClass) ->
    mapIntoObject @normal, keys, operatorClass
    mapIntoObject @visual, keys, operatorClass


# Exports
# -------
module.exports = Keymap
