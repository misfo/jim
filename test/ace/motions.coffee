module 'Ace: motions',
  setup: setupAceTests

test 'h', ->
  @adaptor.moveTo 1, 14

  @press 'h'
  deepEqual @adaptor.position(), [1, 13]
  @press 'h'
  deepEqual @adaptor.position(), [1, 12]
  @press '12h'
  deepEqual @adaptor.position(), [1, 0]
  @press 'h'
  deepEqual @adaptor.position(), [1, 0]

test 'j', ->
  @press 'j'
  deepEqual @adaptor.position(), [1, 0]
  @press 'j'
  deepEqual @adaptor.position(), [2, 0]
  @press '12j'
  deepEqual @adaptor.position(), [14, 0]
  #@press 'j'
  #deepEqual @adaptor.position(), [14, 0]

test 'k', ->
  @adaptor.moveTo 5, 0

  @press 'k'
  deepEqual @adaptor.position(), [4, 0]
  @press 'k'
  deepEqual @adaptor.position(), [3, 0]
  @press '3k'
  deepEqual @adaptor.position(), [0, 0]
  @press 'k'
  deepEqual @adaptor.position(), [0, 0]

test 'l', ->
  @press 'l'
  deepEqual @adaptor.position(), [0, 1]
  @press 'l'
  deepEqual @adaptor.position(), [0, 2]
  @press '42l'
  deepEqual @adaptor.position(), [0, 44]
  @press 'l'
  deepEqual @adaptor.position(), [0, 44]

test 'E', ->
  @press 'E'
  deepEqual @adaptor.position(), [0, 7]
  @press 'E'
  deepEqual @adaptor.position(), [0, 9]
  @press 'E'
  deepEqual @adaptor.position(), [0, 23]
  @press '3E'
  deepEqual @adaptor.position(), [0, 44]
  @press 'E'
  deepEqual @adaptor.position(), [1, 7]
  @press '21E'
  deepEqual @adaptor.position(), [7, 6]

test 'W', ->
  @press 'W'
  deepEqual @adaptor.position(), [0, 9]
  @press 'W'
  deepEqual @adaptor.position(), [0, 11]
  @press 'W'
  deepEqual @adaptor.position(), [0, 25]
  @press '2W'
  deepEqual @adaptor.position(), [0, 44]
  @press 'W'
  deepEqual @adaptor.position(), [1, 2]
  @press '18W'
  deepEqual @adaptor.position(), [6, 2]

test 'B', ->
  @adaptor.moveTo 4, 15

  @press 'B'
  deepEqual @adaptor.position(), [4, 6]
  @press 'B'
  deepEqual @adaptor.position(), [3, 14]
  @press '12B'
  deepEqual @adaptor.position(), [0, 35]

test 'e', ->
  @press 'e'
  deepEqual @adaptor.position(), [0, 1]
  @press 'e'
  deepEqual @adaptor.position(), [0, 7]
  @press 'e'
  deepEqual @adaptor.position(), [0, 9]
  @press 'e'
  deepEqual @adaptor.position(), [0, 18]
  @press 'e'
  deepEqual @adaptor.position(), [0, 19]
  @press 'e'
  deepEqual @adaptor.position(), [0, 22]
  @press '6e'
  deepEqual @adaptor.position(), [0, 44]
  @press 'e'
  deepEqual @adaptor.position(), [1, 7]
  @press '28e'
  deepEqual @adaptor.position(), [4, 24]

test 'w', ->
  @press 'w'
  deepEqual @adaptor.position(), [0, 1]
  @press 'w'
  deepEqual @adaptor.position(), [0, 2]
  @press 'w'
  deepEqual @adaptor.position(), [0, 9]
  @press 'w'
  deepEqual @adaptor.position(), [0, 11]
  @press '8w'
  deepEqual @adaptor.position(), [0, 44]
  @press 'w'
  deepEqual @adaptor.position(), [1, 2]
  @press '3w'
  deepEqual @adaptor.position(), [1, 11]
  @press 'w'
  deepEqual @adaptor.position(), [1, 16]
  @press 'w'
  deepEqual @adaptor.position(), [1, 17]

test 'b', ->
  @adaptor.moveTo 4, 15

  @press 'b'
  deepEqual @adaptor.position(), [4, 6]
  @press 'b'
  deepEqual @adaptor.position(), [3, 19]
  @press 'b'
  deepEqual @adaptor.position(), [3, 14]
  @press 'b'
  deepEqual @adaptor.position(), [3, 12]
  @press 'b'
  deepEqual @adaptor.position(), [3, 6]
  @press 'b'
  deepEqual @adaptor.position(), [2, 11]
  @press '17b'
  deepEqual @adaptor.position(), [1, 16]

test '$', ->
  @press '$'
  deepEqual @adaptor.position(), [0, 44]

test '0', ->
  @adaptor.moveTo 0, 7
  @press '0'
  deepEqual @adaptor.position(), [0, 0]

test 'G', ->
  @press '3G'
  deepEqual @adaptor.position(), [2, 4]
  @press 'G'
  deepEqual @adaptor.position(), [14, 0]
  @press '1G'
  deepEqual @adaptor.position(), [0, 0]
