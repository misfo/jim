module 'Ace: motions',
  setup: ->
    @editor = new Editor(new MockRenderer(), new EditSession js_code)
    @jim = aceModule.startup env: {editor: @editor}

test 'h', ->
  @editor.navigateTo 1, 14

  deepEqual cursorPositionAfter(@editor, 'h'), row: 1, column: 13
  deepEqual cursorPositionAfter(@editor, 'h'), row: 1, column: 12
  deepEqual cursorPositionAfter(@editor, '12h'), row: 1, column: 0
  deepEqual cursorPositionAfter(@editor, 'h'), row: 1, column: 0

test 'j', ->
  deepEqual cursorPositionAfter(@editor, 'j'), row: 1, column: 0
  deepEqual cursorPositionAfter(@editor, 'j'), row: 2, column: 0
  deepEqual cursorPositionAfter(@editor, '12j'), row: 14, column: 0
  #deepEqual cursorPositionAfter(@editor, 'j'), row: 14, column: 0

test 'k', ->
  @editor.navigateTo 5, 0

  deepEqual cursorPositionAfter(@editor, 'k'), row: 4, column: 0
  deepEqual cursorPositionAfter(@editor, 'k'), row: 3, column: 0
  deepEqual cursorPositionAfter(@editor, '3k'), row: 0, column: 0
  deepEqual cursorPositionAfter(@editor, 'k'), row: 0, column: 0

test 'l', ->
  deepEqual cursorPositionAfter(@editor, 'l'), row: 0, column: 1
  deepEqual cursorPositionAfter(@editor, 'l'), row: 0, column: 2
  deepEqual cursorPositionAfter(@editor, '42l'), row: 0, column: 44
  deepEqual cursorPositionAfter(@editor, 'l'), row: 0, column: 44

test 'E', ->
  deepEqual cursorPositionAfter(@editor, 'E'), row: 0, column: 7
  deepEqual cursorPositionAfter(@editor, 'E'), row: 0, column: 9
  deepEqual cursorPositionAfter(@editor, 'E'), row: 0, column: 23
  deepEqual cursorPositionAfter(@editor, '3E'), row: 0, column: 44
  deepEqual cursorPositionAfter(@editor, 'E'), row: 1, column: 7
  deepEqual cursorPositionAfter(@editor, '21E'), row: 7, column: 6

test 'W', ->
  deepEqual cursorPositionAfter(@editor, 'W'), row: 0, column: 9
  deepEqual cursorPositionAfter(@editor, 'W'), row: 0, column: 11
  deepEqual cursorPositionAfter(@editor, 'W'), row: 0, column: 25
  deepEqual cursorPositionAfter(@editor, '2W'), row: 0, column: 44
  deepEqual cursorPositionAfter(@editor, 'W'), row: 1, column: 2
  deepEqual cursorPositionAfter(@editor, '18W'), row: 6, column: 2

test 'B', ->
  @editor.navigateTo 4, 15

  deepEqual cursorPositionAfter(@editor, 'B'), row: 4, column: 6
  deepEqual cursorPositionAfter(@editor, 'B'), row: 3, column: 14
  deepEqual cursorPositionAfter(@editor, '12B'), row: 0, column: 35

test 'e', ->
  deepEqual cursorPositionAfter(@editor, 'e'), row: 0, column: 1
  deepEqual cursorPositionAfter(@editor, 'e'), row: 0, column: 7
  deepEqual cursorPositionAfter(@editor, 'e'), row: 0, column: 9
  deepEqual cursorPositionAfter(@editor, 'e'), row: 0, column: 18
  deepEqual cursorPositionAfter(@editor, 'e'), row: 0, column: 19
  deepEqual cursorPositionAfter(@editor, 'e'), row: 0, column: 22
  deepEqual cursorPositionAfter(@editor, '6e'), row: 0, column: 44
  deepEqual cursorPositionAfter(@editor, 'e'), row: 1, column: 7
  deepEqual cursorPositionAfter(@editor, '28e'), row: 4, column: 24

test 'w', ->
  deepEqual cursorPositionAfter(@editor, 'w'), row: 0, column: 1
  deepEqual cursorPositionAfter(@editor, 'w'), row: 0, column: 2
  deepEqual cursorPositionAfter(@editor, 'w'), row: 0, column: 9
  deepEqual cursorPositionAfter(@editor, 'w'), row: 0, column: 11
  deepEqual cursorPositionAfter(@editor, '8w'), row: 0, column: 44
  deepEqual cursorPositionAfter(@editor, 'w'), row: 1, column: 2
  deepEqual cursorPositionAfter(@editor, '3w'), row: 1, column: 11
  deepEqual cursorPositionAfter(@editor, 'w'), row: 1, column: 16
  deepEqual cursorPositionAfter(@editor, 'w'), row: 1, column: 17

test 'b', ->
  @editor.navigateTo 4, 15

  deepEqual cursorPositionAfter(@editor, 'b'), row: 4, column: 6
  deepEqual cursorPositionAfter(@editor, 'b'), row: 3, column: 19
  deepEqual cursorPositionAfter(@editor, 'b'), row: 3, column: 14
  deepEqual cursorPositionAfter(@editor, 'b'), row: 3, column: 12
  deepEqual cursorPositionAfter(@editor, 'b'), row: 3, column: 6
  deepEqual cursorPositionAfter(@editor, 'b'), row: 2, column: 11
  deepEqual cursorPositionAfter(@editor, '17b'), row: 1, column: 16

test '$', ->
  deepEqual cursorPositionAfter(@editor, '$'), row: 0, column: 44

test '0', ->
  @editor.navigateTo 0, 7
  deepEqual cursorPositionAfter(@editor, '0'), row: 0, column: 0

test 'G', ->
  deepEqual cursorPositionAfter(@editor, '3G'), row: 2, column: 4
  deepEqual cursorPositionAfter(@editor, 'G'), row: 14, column: 0
  deepEqual cursorPositionAfter(@editor, '1G'), row: 0, column: 0
