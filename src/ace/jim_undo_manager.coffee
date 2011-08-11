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

    lastInsert: ->
      return '' if @lastOnUndoStack() isnt 'jim:insert:end'

      startPosition = null
      stringParts = []
      isContiguousInsert = (delta) ->
        return false unless delta.action is 'insertText'
        not startPosition or delta.range.isEnd startPosition...

      for i in [(@$undoStack.length - 2)..0]
        break if typeof @$undoStack[i] is 'string'
        for j in [(@$undoStack[i].length - 1)..0]
          for k in [(@$undoStack[i][j].deltas.length - 1)..0]
            item = @$undoStack[i][j]
            delta = item.deltas[k]
            if item is 'jim:insert:start' or item is 'jim:insert:afterSwitch'
              return string: stringParts.join(''), contiguous: true
            else if isContiguousInsert delta
              stringParts.unshift delta.text
              startPosition = [delta.range.start.row, delta.range.start.column]
            else
              return string: stringParts.join(''), contiguous: false
      string: stringParts.join(''), contiguous: true
