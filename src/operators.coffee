{Command} = require './helpers'
{GoToLine, MoveToFirstNonBlank, MoveToNextBigWord, MoveToNextWord, MoveToBigWordEnd, MoveToWordEnd} = require './motions'

defaultMappings = {}
map = (keys, operatorClass) -> defaultMappings[keys] = operatorClass

class Operation extends Command
  constructor: (@count = 1, @motion) ->
    @motion.operation = this if @motion
  isOperation: true
  isComplete: -> @motion?.isComplete()
  getMotion: -> @motion
  switchToMode: 'normal'
  exec: (jim) ->
    @startingPosition = jim.adaptor.position()
    jim.adaptor.setSelectionAnchor()
    if @count isnt 1
      @motion.count *= @count
      @count = 1
    motion = @getMotion()
    @linewise ?= motion.linewise
    motion.exec jim
    @visualExec jim

  visualExec: (jim) ->
    if @linewise
      jim.adaptor.makeLinewise()
    else if not @getMotion()?.exclusive
      jim.adaptor.includeCursorInSelection()
    @operate jim
    if @repeatableInsert
      jim.adaptor.insert @repeatableInsert.string
    else
      if @switchToMode is 'insert'
        jim.afterInsertSwitch = true
      jim.setMode @switchToMode if @switchToMode


map 'c', class Change extends Operation
  getMotion: ->
    # `cw` actually behaves like `ce`
    switch @motion?.constructor
      when MoveToNextWord    then new MoveToWordEnd @motion.count
      when MoveToNextBigWord then new MoveToBigWordEnd @motion.count
      else                        super
  operate: (jim) ->
    motion = @getMotion()
    jim.adaptor.moveToEndOfPreviousLine() if @linewise
    jim.deleteSelection motion?.exclusive, @linewise
  switchToMode: 'insert'

map 'd', class Delete extends Operation
  operate: (jim) ->
    jim.deleteSelection @motion?.exclusive, @linewise
    new MoveToFirstNonBlank().exec jim if @linewise

map 'y', class Yank extends Operation
  operate: (jim) ->
    jim.yankSelection @motion?.exclusive, @linewise
    jim.adaptor.moveTo @startingPosition... if @startingPosition

map '>', class Indent extends Operation
  operate: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.indentSelection()
    new GoToLine(minRow + 1).exec jim

map '<', class Outdent extends Operation
  operate: (jim) ->
    [minRow, maxRow] = jim.adaptor.selectionRowRange()
    jim.adaptor.outdentSelection()
    new GoToLine(minRow + 1).exec jim

module.exports = {Change, Delete, defaultMappings}
