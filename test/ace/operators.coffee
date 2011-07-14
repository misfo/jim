module 'Ace: operators',
  setup: setupAceTests
  
test 'c', ->
  @press 'cWsorta', @esc
  eq @adaptor.lineText(), "sorta = function(obj, iterator, context) {"

  @adaptor.moveTo 0, 21
  @press 'c4bfunky(', @esc
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
  eq @jim.registers['"'].replace(/\r\n/gm, "\n"), """
    _.sortBy = function(obj, iterator, context) {
      return _.pluck(_.map(obj, function(value, index, list) {

  """
