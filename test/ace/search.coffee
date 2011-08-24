module 'Ace: search',
  setup: ->
    setupAceTests.call this
    @windowPrompt = window.prompt

  teardown: ->
    window.prompt = @windowPrompt

test '/', ->
  window.prompt = -> "or"
  @press '/'
  deepEqual @adaptor.position(), [0, 3]

  @press 'n'
  deepEqual @adaptor.position(), [0, 31]

test '*', ->
  @adaptor.moveTo 0, 14
  @press '*'
  deepEqual @adaptor.position(), [1, 28]

  @press 'n'
  deepEqual @adaptor.position(), [6, 10]

  @press 'N'
  deepEqual @adaptor.position(), [1, 28]
  
  @press '2*'
  deepEqual @adaptor.position(), [0, 11]

  @adaptor.moveTo 7, 8
  @press '*'
  # asserting that only whole word are matched and not just any instance of "a"
  deepEqual @adaptor.position(), [8, 11]

  @press '2n'
  deepEqual @adaptor.position(), [7, 8]

test '#', ->
  @adaptor.moveTo 1, 4
  @press '#'
  deepEqual @adaptor.position(), [8, 4]

  @press 'n'
  deepEqual @adaptor.position(), [2, 4]

  @press 'N'
  deepEqual @adaptor.position(), [8, 4]

  @press '2#'
  deepEqual @adaptor.position(), [1, 2]

  @adaptor.moveTo 7, 8
  @press '#'
  # asserting that only whole word are matched and not just any instance of "a"
  deepEqual @adaptor.position(), [8, 24]

  @press 'N'
  deepEqual @adaptor.position(), [7, 8]


# there are four different rules for what search Vim uses for * and #
# http://vimdoc.sourceforge.net/htmldoc/pattern.html#star

# rule #1
test '* or # will match the keyword under the cursor', ->
  # match the underscore
  @press '#'
  deepEqual @adaptor.position(), [1, 17]

# rule #2
test '* or # will match the keyword after the cursor', ->
  @adaptor.moveTo 0, 8
  # match "function" since the equals sign and spaces aren't keywords
  @press '*'
  deepEqual @adaptor.position(), [1, 28]

# rule #3
test '* or # will match the non-blank word under the cursor', ->
  @adaptor.moveTo 5, 4
  # match "};", since there aren't any keywords on the line after the cursor
  @press '#'
  deepEqual @adaptor.position(), [10, 0]

# rule #4
test '* or # will match the non-blank word after the cursor', ->
  @adaptor.moveTo 0, 43
  # match the curly brace, since there aren't any keywords on the line after the cursor
  # and the curly brace is a non-blank
  @press '*'
  deepEqual @adaptor.position(), [1, 57]
