module 'Ace: operators',
  setup: setupAceTests
  
test 'c', ->
  @press 'cWsorta', @esc
  eq @adaptor.lineText(), "sorta = function(obj, iterator, context) {"

  @adaptor.moveTo 0, 21
  @press '2c2bfunky(', @esc
  eq @adaptor.lineText(), "sorta = funky( iterator, context) {"

  eq @adaptor.lastRow(), 15
  @adaptor.moveTo 6, 0
  @press 'ckkablammo!'
  eq @adaptor.lineText(), "kablammo!"
  eq @adaptor.lastRow(), 14

test 'd', ->
  @adaptor.moveTo 0, 11
  @press 'd11W'
  eq @adaptor.lineText(), "_.sortBy = {"

  eq @adaptor.lastRow(), 13
  @press 'dj'
  eq @adaptor.lastRow(), 11

test 'y', ->
  @press 'y3W'
  eq @jim.registers['"'], "_.sortBy = function(obj, "

  @press 'yj'
  eq endings(@jim.registers['"']), """
    _.sortBy = function(obj, iterator, context) {
      return _.pluck(_.map(obj, function(value, index, list) {

  """

  @press '$hy4l'
  eq @jim.registers['"'], ' {'

test '>', ->
  @press '>3G'
  eq @adaptor.lineText(0), '  _.sortBy = function(obj, iterator, context) {'
  eq @adaptor.lineText(1), '    return _.pluck(_.map(obj, function(value, index, list) {'
  eq @adaptor.lineText(2), '      return {'
  deepEqual @adaptor.position(), [0, 2]

test '<', ->
  @press 'j<j'
  eq @adaptor.lineText(1), 'return _.pluck(_.map(obj, function(value, index, list) {'
  eq @adaptor.lineText(2), '  return {'
  deepEqual @adaptor.position(), [1, 0]