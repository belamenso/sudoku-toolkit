import
  sequtils, sugar, terminal

import
  types, counts, examples,
  strategies/shadow

### PRINTING

proc colored(s: string) =
  setForegroundColor(stdout, fgGreen)
  stdout.write(s)
  setForegroundColor(stdout, fgDefault)

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

proc print*(board: Board, mask = fullMask()) =

  proc writeValue(v: Value, m: bool) =
    if v == 0:
      if m: setForegroundColor(fgRed)
      stdout.write(if m: "▪" else: " ")
      setForegroundColor(fgWhite)
    else:
      if m: setForegroundColor(fgRed)
      stdout.write(v)
      setForegroundColor(fgWhite)

  stdout.write("┌───────┬───────┬───────┐\n")
  for i in 0..8:
    for j in 0..8:
      if j == 0: stdout.write("│")
      stdout.write(" ")
      if mask[9*i+j]:
        setForegroundColor(stdout, fgRed)
        writeValue(board[9*i+j], true)
        setForegroundColor(stdout, fgWhite)
      else:
        writeValue(board[9*i+j], false)
      if j in {2,5,8}: stdout.write(" │")
    if i in {2,5}: stdout.write("\n│───────┼───────┼───────│")
    stdout.write("\n")
  stdout.write("└───────┴───────┴───────┘\n")
  stdout.flushFile()

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
  b = exampleBoard

  echo "START"
  print(b)
  echo ""

  var c = true
  var oi = 0
  var m = fullMask()
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
          print(b, m)
          echo ""
          c = true
        if ev.kind == LastMask:
          m = ev.lastMask
    # THIS CRASHED THE COMPILER
    # for xxx in shadow(b, 5.ProperValue):
    #  discard
