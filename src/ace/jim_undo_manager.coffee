define (require, exports, module) ->
  {UndoManager} = require 'ace/undomanager'

  class JimUndoManager extends UndoManager
    # override so that the default undo (button and keyboard shortcut)
    # will skip over Jim's bookmarks and behave as they usually do
    undo: (dontSelect) ->
      @silentUndo() if @isJimMark @lastOnUndoStack()
      super dontSelect

    isJimMark: (entry) ->
      deltas = entry?.deltas
      typeof deltas is 'string' and matchingMark[deltas]?

    lastOnUndoStack: -> @$undoStack[@$undoStack.length-1]

    markUndoPoint: (doc, markName) ->
      @execute args: [{group: 'doc', deltas: markName}, doc]

    silentUndo: ->
      deltas = @$undoStack.pop()
      @$redoStack.push deltas if deltas

    matchingMark:
      jimInsertEnd:  'jimInsertStart'
      jimReplaceEnd: 'jimReplaceStart'

    jimUndo: ->
      lastDeltasOnStack = @lastOnUndoStack()?.deltas
      if typeof lastDeltasOnStack is 'string' and startMark = @matchingMark[lastDeltasOnStack]
        startIndex = null
        for i in [(@$undoStack.length-1)..0]
          if @$undoStack[i]?.deltas is startMark
            startIndex = i
            break

        if startIndex?
          @silentUndo() # pop the end off
          @undo() for i in [(@$undoStack.length-1)...startIndex]
          @silentUndo() # pop the start off
        else
          console.log "found a \"#{lastDeltasOnStack}\" on the undoStack, but no \"#{startMark}\""
      else
        @undo()
