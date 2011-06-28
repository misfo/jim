# this is a port of Ace's undo manager:
# github.com/ajaxorg/ace/blob/master/lib/ace/undomanager.js
class UndoManager
  constructor: (options) ->
    @reset()

  execute: (options) ->
    console.log 'UndoManager::execute', options
    deltas = options.args[0]
    @$doc = options.args[1]
    @$undoStack.push deltas
    @$redoStack = []

  undo: (dontSelect) ->
    console.log 'UndoManager::undo', dontSelect
    deltas = @$undoStack.pop()
    undoSelectionRange = null
    if deltas
      undoSelectionRange = @$doc.undoChanges(deltas, dontSelect)
      @$redoStack.push deltas
    undoSelectionRange

  redo: (dontSelect) ->
    console.log 'UndoManager::redo', dontSelect
    deltas = @$redoStack.pop()
    redoSelectionRange = null
    if deltas
      redoSelectionRange = @$doc.redoChanges(deltas, dontSelect)
      @$undoStack.push deltas
    redoSelectionRange

  reset: ->
    console.log 'UndoManager::reset'
    @$undoStack = []
    @$redoStack = []

  hasUndo: -> @$undoStack.length > 0
  hasRedo: -> @$redoStack.length > 0

  # Jim functions
  markInsertStartPoint: ->
    console.log 'UndoManager::markInsertStartPoint'
    options = args: [{group: 'doc', deltas: [{action: 'jimInsertStart'}]}]
    @execute options

  # Jim functions
  markInsertEndPoint: ->
    console.log 'UndoManager::markInsertEndPoint'
    options = args: [{group: 'doc', deltas: 'jimInsertEnd'}]
    @execute options

  jimUndo: ->
    console.log 'UndoManager::jimUndo'
    #FIXME
    deltas = @$undoStack[@$undoStack.length-1]?.deltas
    console.log 'deltas', deltas
    if deltas is 'jimInsertEnd'
      console.log 'roll a bunch of stuff back...'
      #TODO
    else
      @undo true
