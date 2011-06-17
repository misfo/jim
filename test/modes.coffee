test 'normal mode regex parses commands correctly', ->
  regex = modes.normal.regex

  eq "i", "i".match(regex)[0]
  eq "i", "i".match(regex)[1]

  eq "j", "j".match(regex)[0]
  eq "j", "j".match(regex)[3]

  eq "2", "2".match(regex)[0]
  eq "2", "2".match(regex)[2]
  eq "2k", "2k".match(regex)[0]
  eq "2",  "2k".match(regex)[2]
  eq "k",  "2k".match(regex)[3]

  eq "G", "G".match(regex)[0]
  eq "G", "G".match(regex)[4]
  eq "13G", "13G".match(regex)[0]
  eq "13",  "13G".match(regex)[2]
  eq "G",   "13G".match(regex)[4]
