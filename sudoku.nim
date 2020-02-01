import
  sequtils, sugar

import
  types, counts, examples,
  strategies/shadow

### PRINTING

proc render*(board: Board, mask = fullMask()): string =
  for i in 0..8:
    for j in 0..8:
      if mask[9*i+j]:
        result &= $board[9*i+j]
      else:
        result &= " "
      if j in {2,5}: result &= "|"
    if i in {2,5}: result &= "\n--- --- ---\n"
    elif i != 8: result &= "\n"

proc parse*(s: string, zero: char = '0'): Board =
  result = emptyBoard()
  var i = 0
  for c in s:
    if c notin {'1'..'9'} + {zero}:
      continue
    if c in {'1'..'9'}:
      result[i] = c.int() - '0'.int()
    else:
      result[i] = 0
    inc i
  doAssert(i == 81, "Invalid number of symbols in the string")

when isMainModule:
  var b = parse("""
  060 078 500
  900 005 040
  000 000 900

  000 000 400
  051 006 080
  006 500 090

  280 000 000
  000 040 030
  400 710 000
  """)

  echo "START"
  echo render(b, fullMask())
  echo ""

  var c = true
  var oi = 0
  while c:
    c = false
    inc oi
    echo "outer iteration ", oi
    echo "counts: ", counts(b)

    for i in 1..9:
      for ev in shadow(b, i.ProperValue):
        if ev.kind == FoundValue:
          echo ev
          b[ev.idx] = ev.v
          echo render(b, fullMask())
          echo ""
          c = true
    # THIS CRASHED THE COMPILER
    # for xxx in shadow(b, 5.ProperValue):
    #  discard
