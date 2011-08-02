module 'Ace: undo',
  setup: setupAceTests

test 'undoing commands', ->
  @press 'xxu'
  eq @adaptor.lineText(), '.sortBy = function(obj, iterator, context) {'

test 'undoing inserts', ->
  @press 'Aend', @esc, 'Ibegin', @esc
  eq @adaptor.lineText(), 'begin_.sortBy = function(obj, iterator, context) {end'
  @press 'u'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {end'
  @press 'u'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {'

test 'undoing replaces', ->
  @press 'Rundo', @esc, '2WRthing', @esc
  eq @adaptor.lineText(), 'undortBy = thingion(obj, iterator, context) {'

  @press 'u'
  eq @adaptor.lineText(), 'undortBy = function(obj, iterator, context) {'

  @press 'u'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {'

test 'undoing visual operators', ->
  @press 'Wv>u'
  eq @adaptor.lineText(), '_.sortBy = function(obj, iterator, context) {'
