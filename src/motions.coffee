define (require, exports, module) ->
  map:
    h: 'Left'
    j: 'Down'
    k: 'Up'
    l: 'Right'
    W: 'NextWORD'
    E: 'WORDEnd'
    B: 'BackWORD'
    w: 'NextWord'
    e: 'WordEnd'
    b: 'BackWord'

  #TODO build this from the map
  regex: /[hjklWEBweb]/
