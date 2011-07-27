define (require, exports, module) ->
  {UndoManager} = require 'ace/undomanager'

  class JimUndoManager extends UndoManager
    # override so that the default undo (button and keyboard shortcut)
    # will skip over Jim's bookmarks and behave as they usually do
    undo: (dontSelect) ->
      @silentUndo() if @isJimMark @lastOnUndoStack()
      super dontSelect

    isJimMark: (entry) ->
      typeof entry is 'string' and matchingMark[entry]?

    lastOnUndoStack: -> @$undoStack[@$undoStack.length-1]

    markUndoPoint: (doc, markName) ->
      @execute args: [markName, doc]

    silentUndo: ->
      deltas = @$undoStack.pop()
      @$redoStack.push deltas if deltas

    matchingMark:
      jimInsertEnd:  'jimInsertStart'
      jimReplaceEnd: 'jimReplaceStart'

    jimUndo: ->
      lastDeltasOnStack = @lastOnUndoStack()
      if typeof lastDeltasOnStack is 'string' and startMark = @matchingMark[lastDeltasOnStack]
        startIndex = null
        for i in [(@$undoStack.length-1)..0]
          if @$undoStack[i] is startMark
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

    lastRepeatableInsertString: ->
      return '' if @lastOnUndoStack() isnt 'jimInsertEnd'
      console.log '@$undoStack', @$undoStack

      startPosition = null
      stringParts = []
      isContiguousInsert = (delta) ->
        return false unless delta.action is 'insertText'
        not startPosition or delta.range.isEnd startPosition...

      for i in [(@$undoStack.length - 2)..0]
        break if typeof @$undoStack[i] is 'string'
        for j in [(@$undoStack[i].length - 1)..0]
          for k in [(@$undoStack[i][j].deltas.length - 1)..0]
            delta = @$undoStack[i][j].deltas[k]
            if isContiguousInsert delta
              stringParts.unshift delta.text
              startPosition = [delta.range.start.row, delta.range.start.column]
            else
              return stringParts.join ''
      stringParts.join ''
