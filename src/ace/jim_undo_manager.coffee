define (require, exports, module) ->
  {UndoManager} = require 'ace/undomanager'

  class JimUndoManager extends UndoManager
    # override so that the default undo (button and keyboard shortcut)
    # will skip over Jim's bookmarks and behave as they usually do
    undo: (dontSelect) ->
      @silentUndo() if @isJimMark @lastOnUndoStack()
      super dontSelect

    isJimMark: (entry, markName) ->
      deltas = entry?.deltas
      return false unless typeof deltas is 'string'
      if markName
        deltas is markName
      else
        /^jim/.test deltas

    lastOnUndoStack: -> @$undoStack[@$undoStack.length-1]

    markInsertStartPoint: (doc) ->
      options = args: [{group: 'doc', deltas: 'jimInsertStart'}, doc]
      @execute options

    # Jim functions
    markInsertEndPoint: (doc) ->
      options = args: [{group: 'doc', deltas: 'jimInsertEnd'}, doc]
      @execute options

    silentUndo: ->
      deltas = @$undoStack.pop()
      @$redoStack.push deltas if deltas

    jimUndo: ->
      if @isJimMark @lastOnUndoStack(), 'jimInsertEnd'
        startIndex = null
        for i in [(@$undoStack.length-1)..0]
          if @isJimMark @$undoStack[i], 'jimInsertStart'
            startIndex = i
            break

        if startIndex?
          @silentUndo() # pop the end off
          @undo() for i in [(@$undoStack.length-1)...startIndex]
          @silentUndo() # pop the start off
        else
          console.log "found a jimInsertEnd on the undoStack, but no jimInsertStart'"
      else
        @undo()
