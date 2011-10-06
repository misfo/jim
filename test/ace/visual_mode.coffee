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
  eq @jim.mode.name, 'normal'

  @press 'jjjV2kd'
  eq @adaptor.lastRow(), 10
  eq @adaptor.row(), 1
  eq @jim.mode.name, 'normal'

test 'characterwise changes', ->
  @press '2WvEchi!', @esc
  eq @adaptor.lineText(0), '_.sortBy = hi! iterator, context) {'
  eq @jim.mode.name, 'normal'

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
  eq @jim.mode.name, 'normal'

  @press 'wv3P'
  eq @adaptor.lineText(), '._ sortBysortBysortBy function(obj, iterator, context) {'
  eq @jim.mode.name, 'normal'

test 'J', ->
  @press 'vjJ'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) { return _.pluck(_.map(obj, function(value, index, list) {'
  deepEqual @adaptor.position(), [0, 45]
  eq @jim.mode.name, 'normal'

  @press 'jVjjjJ'
  eq @adaptor.lineText(), '    return { value : value, criteria : iterator.call(context, value, index, list) };'
  deepEqual @adaptor.position(), [1, 81]
  eq @jim.mode.name, 'normal'

  #TODO special case for lines starting with ")"?!?!?!

test 'gJ', ->
  @press 'vlgJ'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {  return _.pluck(_.map(obj, function(value, index, list) {'
  deepEqual @adaptor.position(), [0, 45]
  eq @jim.mode.name, 'normal'

  @press 'jv3jgJ'
  eq @adaptor.lineText(), '    return {      value : value,      criteria : iterator.call(context, value, index, list)    };'
  deepEqual @adaptor.position(), [1, 91]
  eq @jim.mode.name, 'normal'

test 'linewise paste over a linewise selection', ->
  firstLine = @adaptor.lineText 0
  fourthLine = @adaptor.lineText 3
  lastRow = @adaptor.lastRow()

  # replace lines 2 & 3 with line 1 (threw the `l`'s in there fo fun)
  @press 'yyjlllVjp'
  eq @adaptor.lineText(1), firstLine
  eq @adaptor.lineText(2), fourthLine
  eq @adaptor.lastRow(), lastRow - 1

test 'linewise gJ', ->
  lastRow = @adaptor.lastRow()

  @press 'lllVjgJ'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {  return _.pluck(_.map(obj, function(value, index, list) {'
  eq @adaptor.lastRow(), lastRow - 1

test 'toggle visual mode', ->
  @press 'vW'
  eq @jim.mode.name, 'visual'
  ok not @jim.mode.linewise

  @press 'Vj'
  eq @jim.mode.name, 'visual'
  ok @jim.mode.linewise

  @press 'vy'
  eq endings(@jim.registers['"']), '_.sortBy = function(obj, iterator, context) {\n  return _'

  @press 'vv'
  eq @jim.mode.name, 'normal'

  @press 'VV'
  eq @jim.mode.name, 'normal'

  @press 'WVvy'
  eq @jim.registers['"'], '='

  @press 'vjVy'
  eq endings(@jim.registers['"']), """
    _.sortBy = function(obj, iterator, context) {
      return _.pluck(_.map(obj, function(value, index, list) {

  """

test 'selection with arrow keys', ->
  @press 'v', @down, @right, @up, @left, 'y'
  eq @jim.registers['"'], '_.'

  @adaptor.moveTo 4, 6

  @press 'vw', @right, @right, 'Wy'
  eq @jim.registers['"'], 'criteria : iterator.call(context, v'

test 'x, X, and delete with selection', ->
  @press 'vWx'
  eq @jim.registers['"'], '_.sortBy ='

  @press 'vWX'
  eq endings(@jim.registers['"']), ' function(obj, iterator, context) {\n'

  @press 'jvl', @delete
  eq @jim.registers['"'], '  r'

test 'visual mode o', ->
  @adaptor.moveTo 3, 6
  @press 'vjo'
  deepEqual @adaptor.position(), [3, 6]

  @press 'o'
  deepEqual @adaptor.position(), [4, 6]

  @press 'o', @esc
  deepEqual @adaptor.position(), [3, 6]

  @press 'veo'
  deepEqual @adaptor.position(), [3, 6]

  @press 'o'
  deepEqual @adaptor.position(), [3, 10]

  @press 'o', @esc
  deepEqual @adaptor.position(), [3, 6]
