# this is a port of Ace's undo manager:
# github.com/ajaxorg/ace/blob/master/lib/ace/undomanager.js
class UndoManager
  constructor: (options) ->
    @reset()

  execute: (options) ->
    deltas = options.args[0]
    @$doc = options.args[1]
    @$undoStack.push deltas
    @$redoStack = []

  undo: (dontSelect) ->
    deltas = @$undoStack.pop()
    return if @isJimMark deltas
    undoSelectionRange = null
    if deltas
      undoSelectionRange = @$doc.undoChanges(deltas, dontSelect)
      @$redoStack.push deltas
    undoSelectionRange

  redo: (dontSelect) ->
    deltas = @$redoStack.pop()
    redoSelectionRange = null
    if deltas
      redoSelectionRange = @$doc.redoChanges(deltas, dontSelect)
      @$undoStack.push deltas
    redoSelectionRange

  reset: ->
    @$undoStack = []
    @$redoStack = []

  hasUndo: -> @$undoStack.length > 0
  hasRedo: -> @$redoStack.length > 0

  # Jim functions
  isJimMark: (entry, markName) ->
    deltas = entry?.deltas
    return false unless typeof deltas is 'string'
    if markName
      deltas is markName
    else
      /^jim/.test deltas

  markInsertStartPoint: (doc) ->
    options = args: [{group: 'doc', deltas: 'jimInsertStart'}, doc]
    @execute options

  # Jim functions
  markInsertEndPoint: (doc) ->
    options = args: [{group: 'doc', deltas: 'jimInsertEnd'}, doc]
    @execute options

  jimUndo: ->
    deltas = @$undoStack[@$undoStack.length-1]
    if @isJimMark deltas, 'jimInsertEnd'
      startIndex = null
      for i in [(@$undoStack.length-1)..0]
        if @isJimMark @$undoStack[i], 'jimInsertStart'
          startIndex = i
          break

      if startIndex?
        @undo() for i in [(@$undoStack.length-1)..startIndex]
      else
        @undo()
    else
      @undo()
