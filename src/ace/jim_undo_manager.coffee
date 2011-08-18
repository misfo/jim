define (require, exports, module) ->
  {UndoManager} = require 'ace/undomanager'

  class JimUndoManager extends UndoManager
    # override so that the default undo (button and keyboard shortcut)
    # will skip over Jim's bookmarks and behave as they usually do
    undo: ->
      @silentUndo() if @isJimMark @lastOnUndoStack()
      super

    isJimMark: (entry) ->
      typeof entry is 'string' and /^jim:/.test entry

    lastOnUndoStack: -> @$undoStack[@$undoStack.length-1]

    markUndoPoint: (doc, markName) ->
      @execute args: [markName, doc]

    silentUndo: ->
      deltas = @$undoStack.pop()
      @$redoStack.push deltas if deltas

    matchingMark:
      'jim:insert:end':  'jim:insert:start'
      'jim:replace:end': 'jim:replace:start'

    jimUndo: ->
      lastDeltasOnStack = @lastOnUndoStack()
      if typeof lastDeltasOnStack is 'string' and startMark = @matchingMark[lastDeltasOnStack]
        startIndex = null
        for i in [(@$undoStack.length-1)..0]
          if @$undoStack[i] is startMark
            startIndex = i
            break

        if not startIndex?
          console.log "found a \"#{lastDeltasOnStack}\" on the undoStack, but no \"#{startMark}\""
          return

        @silentUndo() # pop the end off
        while @$undoStack.length > startIndex + 1
          if @isJimMark @lastOnUndoStack()
            @silentUndo()
          else
            @undo()
        @silentUndo() # pop the start off
      else
        @undo()

    # helper class for figuring out what text was inserted and if it was contiguous
    class InsertedText
      @fromUndoStack: (undoStack) ->
        insertedText = new InsertedText

        for i in [(undoStack.length - 2)..0]
          if typeof undoStack[i] is 'string'
            insertedText.addBookmark undoStack[i]
            return insertedText

          for j in [(undoStack[i].length - 1)..0]
            for k in [(undoStack[i][j].deltas.length - 1)..0]
              continueLooping = insertedText.addDelta undoStack[i][j].deltas[k]
              return insertedText unless continueLooping

      constructor: ->
        # we don't consider it contiguous until it's been "proven"
        @contiguous = no
        @textParts = []

      addBookmark: (bookmark) -> @contiguous = yes if bookmark is 'jim:insert:afterSwitch'

      isContiguousInsert: (delta) ->
        return false unless delta.action is 'insertText'
        not @lastStartPosition or delta.range.isEnd @lastStartPosition...

      addDelta: (delta) ->
        if @isContiguousInsert delta
          @textParts.unshift delta.text
          @lastStartPosition = [delta.range.start.row, delta.range.start.column]
          true

      text: -> @textParts.join ''


    lastInsert: ->
      return {string: '', contiguous: no} if @lastOnUndoStack() isnt 'jim:insert:end'

      insertedText = InsertedText.fromUndoStack @$undoStack

      string: insertedText.text(), contiguous: insertedText.contiguous
