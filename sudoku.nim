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

proc parse*(s: string): Board =
  result = emptyBoard()
  var i = 0
  for c in s:
    if c notin '0'..'9':
      continue
    result[i] = c.int() - '0'.int()
    inc i

when isMainModule:
  var b = exampleBoard
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
