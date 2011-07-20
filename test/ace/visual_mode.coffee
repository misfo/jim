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

test 'p, P', ->
  # p and P do the same thing in visual mode
  @press 'xlvep'
  eq @adaptor.lineText(), '._ = function(obj, iterator, context) {'

  @press 'wv3P'
  eq @adaptor.lineText(), '._ sortBysortBysortBy function(obj, iterator, context) {'
