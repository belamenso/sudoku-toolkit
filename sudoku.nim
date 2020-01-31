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

when isMainModule:
  var b = harderBoard
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
        if ev.kind == Found:
          echo ev
          b[ev.idx] = i.Value
          echo render(b, fullMask())
          echo ""
          c = true
