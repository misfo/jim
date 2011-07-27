module 'Ace: visual mode',
  setup: setupAceTests
  
test 'motions', ->
  @press 'v3Gd'
  deepEqual @adaptor.position(), [0, 0]
  eq @adaptor.lineText(), 'eturn {'

  @press 'v2ly'
  eq @jim.registers['"'], 'etu'
  deepEqual @adaptor.position(), [0, 0]

test 'making a backwards selection', ->
  @press 'Wvhhy'
  eq @jim.registers['"'], 'y ='

test 'transition from a backwards selection to forwards', ->
  @press 'Wvhllly'
  eq @jim.registers['"'], '= f'

test 'linewise selections', ->
  @press 'lllVjd'
  eq @adaptor.lastRow(), 13
  eq @adaptor.lineText(), "    return {"

  @press 'jjjV2kd'
  eq @adaptor.lastRow(), 10
  eq @adaptor.row(), 1

test 'linewise changes', ->
  eq @adaptor.lastRow(), 15
  @press 'Vjcnew line!', @esc
  eq @adaptor.lastRow(), 14
  deepEqual @adaptor.position(), [0, 8]
  eq @adaptor.lineText(0), 'new line!'

test 'p, P', ->
  # p and P do the same thing in visual mode
  @press 'xlvep'
  eq @adaptor.lineText(), '._ = function(obj, iterator, context) {'

  @press 'wv3P'
  eq @adaptor.lineText(), '._ sortBysortBysortBy function(obj, iterator, context) {'

test 'J', ->
  @press 'vjJ'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) { return _.pluck(_.map(obj, function(value, index, list) {'
  deepEqual @adaptor.position(), [0, 45]

  @press 'jVjjjJ'
  eq @adaptor.lineText(), '    return { value : value, criteria : iterator.call(context, value, index, list) };'
  deepEqual @adaptor.position(), [1, 81]

  #TODO special case for lines starting with ")"?!?!?!

test 'gJ', ->
  @press 'vlgJ'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {  return _.pluck(_.map(obj, function(value, index, list) {'
  deepEqual @adaptor.position(), [0, 45]

  @press 'jv3jgJ'
  eq @adaptor.lineText(), '    return {      value : value,      criteria : iterator.call(context, value, index, list)    };'
  deepEqual @adaptor.position(), [1, 91]
