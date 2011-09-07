module 'Ace: dot command',
  setup: setupAceTests

test 'repeating basic commands', ->
  @press 'x..'
  eq @adaptor.lineText(), 'ortBy = function(obj, iterator, context) {'

test 'repeating commands with arbitrary chars', ->
  @press 'r 2W.W.'
  eq @adaptor.lineText(), ' .sortBy    unction(obj, iterator, context) {'

test 'repeating operations', ->
  @press 'dw..'
  eq @adaptor.lineText(), '= function(obj, iterator, context) {'

test 'repeating commands that are Change operations', ->
  @press '4WCwham!', @esc, 'j.'
  eq @adaptor.lineText(), '  return _.pluck(_.map(obj, function(vawham!' # vawham!!!11

test 'repeating inserts', ->
  @press 'AtheEnd', @esc, 'j.'
  eq @adaptor.lineText(), '  return _.pluck(_.map(obj, function(value, index, list) {theEnd'

  @press 'j^cwwhoa', @esc, 'j.'
  eq @adaptor.lineText(), '      vwhoa : value,'

test 'repeating inserts in which the users arrows around', ->
  @press 'Cfirstline', @down, 'secondLine', @esc, 'j^.'
  eq @adaptor.lineText(), '    secondLinereturn {'

test 'repeating inserts that have been undone', ->
  @press 'isomething', @esc, 'uW.'
  eq @adaptor.lineText(), '_.sortBy something= function(obj, iterator, context) {'

test 'repeating linewise changes', ->
  @press 'cjone line now', @esc, 'j.'
  eq @adaptor.lineText(), 'one line now'
  eq @adaptor.lastRow(), 13

test 'repeating characterwise visual commands', ->
  @press 'WvjdW.'
  eq @adaptor.lineText(), '_.sortBy .pluck(_.map(obj,  {'

test 'repeating single line characterwise visual commands', ->
  @press 'v10ld10l.'
  eq @adaptor.lineText(), 'function(or, context) {'

test 'repeating linewise visual commands', ->
  @press 'VjjJj.'
  eq @adaptor.lineText(), '      value : value, criteria : iterator.call(context, value, index, list) };'

test 'repeating linewise visual operators', ->
  @press 'Vj>j.'
  eq @adaptor.lineText(0), '  _.sortBy = function(obj, iterator, context) {'
  eq @adaptor.lineText(1), '      return _.pluck(_.map(obj, function(value, index, list) {'
  eq @adaptor.lineText(2), '      return {'
  eq @adaptor.lineText(3), '      value : value,'

test 'repeating words that have some deletion', ->
  @press 'iExtra punctuation.!', @backspace, @esc
  eq @adaptor.lastInsert().string, 'Extra punctuation.'

  @press 'iI am misspelleed', @backspace, @backspace, 'd', @esc
  eq @adaptor.lastInsert().string, 'I am misspelled'

  @press 'iWill be. deleted'
  @press @backspace, @backspace, @backspace, @backspace, @backspace, @backspace, @backspace, @backspace
  @press @esc
  eq @adaptor.lastInsert().string, 'Will be.'

  @press 'i bc', @esc, 'O', @esc, 'iabc', @down, @backspace, @backspace, 'bc', @esc
  eq @adaptor.lastInsert().string, 'bc'

  @press 'iabc\nbc', @backspace, @backspace, 'de', @esc
  eq endings(@adaptor.lastInsert().string), 'abc\nde'
