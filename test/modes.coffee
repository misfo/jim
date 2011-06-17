test 'normal mode regex parses commands correctly', ->
  regex = modes.normal.regex

  m = "i".match regex
  eq "i", m[0]
  eq "i", m[1]

  m = "j".match regex
  eq "j", m[0]
  eq "j", m[3]

  m = "2".match(regex)
  eq "2", m[0]
  eq "2", m[2]
  m = "2k".match(regex)
  eq "2k", m[0]
  eq "2",  m[2]
  eq "k",  m[3]

  m = "G".match(regex)
  eq "G", m[0]
  eq "G", m[4]
  m = "13G".match(regex)
  eq "13G", m[0]
  eq "13",  m[2]
  eq "G",   m[4]
