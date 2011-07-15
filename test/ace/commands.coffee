module 'Ace: commands',
  setup: setupAceTests

test 'A', ->
  @press 'Aend'
  eq @adaptor.lineText()[-3..-1], 'end'

test 'C', ->
  @adaptor.moveTo 0, 11

  @press 'Cawesomes'
  eq @adaptor.lineText(), "_.sortBy = awesomes"

test 'D', ->
  @adaptor.moveTo 0, 11

  @press 'D'
  eq @adaptor.lineText(), "_.sortBy = "

test 'I', ->
  @press 'Istart', @esc
  eq @adaptor.lineText()[0..5], 'start_'

  @press 'jIstart', @esc
  eq @adaptor.lineText()[0..7], '  startr'

test 'p', ->
  @press '3p'
  eq @adaptor.lineText(), "_.sortBy = function(obj, iterator, context) {"

  @jim.registers['"'] = '!?'
  @press '2p'
  eq @adaptor.lineText(), "_!?!?.sortBy = function(obj, iterator, context) {"

test 's', ->
  @press 'sunderscore', @esc
  eq @adaptor.lineText(), "underscore.sortBy = function(obj, iterator, context) {"
  @press '3sy', @esc
  eq @adaptor.lineText(), "underscoryortBy = function(obj, iterator, context) {"
  @press '$sdo', @esc
  eq @adaptor.lineText(), "underscoryortBy = function(obj, iterator, context) do"

test 'x', ->
  @press 'x'
  eq @adaptor.lineText(), ".sortBy = function(obj, iterator, context) {"
  @press '3x'
  eq @adaptor.lineText(), "rtBy = function(obj, iterator, context) {"
  @press '$x'
  eq @adaptor.lineText(), "rtBy = function(obj, iterator, context) "
  @press '$3x'
  eq @adaptor.lineText(), "rtBy = function(obj, iterator, context)"

test 'X', ->
  @adaptor.moveTo 2, 11

  @press 'X'
  eq @adaptor.lineText(), "    return{"
  @press 'X'
  eq @adaptor.lineText(), "    retur{"
  @press '9X'
  eq @adaptor.lineText(), "{"
  @press 'X'
  eq @adaptor.lineText(), "{"

test 'o,O', ->
  @press 'Onew line', @esc
  eq @adaptor.lineText(), "new line"
  eq @adaptor.row(), 0
  eq @adaptor.lastRow(), 16

  @press 'oanother line', @esc
  eq @adaptor.lineText(), 'another line'
  eq @adaptor.row(), 1
  eq @adaptor.lastRow(), 17

test 'cc', ->
  @press 'ccdifferent line', @esc
  eq @adaptor.lineText(), 'different line'
  deepEqual @adaptor.position(), [0, 13], 'cc should leave the cursor at the end of the insert'
  eq @adaptor.lastRow(), 15

  @press '2ccbetter', @esc
  eq @adaptor.lineText(), 'better'
  deepEqual @adaptor.position(), [0, 5], 'cc should leave the cursor at the end of the insert'
  eq @adaptor.lineText(1), '    return {'
  eq @adaptor.lastRow(), 14

test 'dd', ->
  @press '2Wdd'
  deepEqual @adaptor.position(), [0, 2], 'dd should leave the cursor on the first non-blank after the deletion'
  eq @adaptor.lastRow(), 14

  @press '3dd'
  deepEqual @adaptor.position(), [0, 6], 'dd should leave the cursor on the first non-blank after the deletion'
  eq @adaptor.lastRow(), 11

test 'yy', ->
  @press 'Wyy'
  deepEqual @adaptor.position(), [0, 9], "yy should leave the cursor where it started"
  eq endings(@jim.registers['"']), "_.sortBy = function(obj, iterator, context) {\n"

  @press '2yy'
  deepEqual @adaptor.position(), [0, 9], "yy should leave the cursor where it started"
  eq endings(@jim.registers['"']), """
    _.sortBy = function(obj, iterator, context) {
      return _.pluck(_.map(obj, function(value, index, list) {

  """
