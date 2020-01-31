import
  strutils, sequtils, options, sugar

type
  # 0   - no value
  # 1-9 - value
  Value* = range[0..9]
  ProperValue* = range[1..9]

  I3* = range[0..2]
  I33* = tuple[a: I3, b: I3]

  I9* = range[0..8]
  I99* = tuple[x: I9, y: I9] # a,b vs x,y intentionally

  I81* = range[0..80]

  # 81 elements, in order of rows
  Board* = seq[Value]

  # domain of elements 0..80
  Mask* = seq[bool] # of length 81

  Counts* = seq[int] # todo something other than int? what abount count of zeros?

  StrategyEventKind* = enum
    Found, Iteration

  StrategyEvent* = object
    depth*: Natural

    case kind*: StrategyEventKind
    of Found:
      idx*: I99
      v*:   ProperValue
    of Iteration:
      n*: Positive

proc emptyBoard*: Board = newSeqWith(81, 0.Value)

proc emptyMask*: Mask = newSeqWith(81, false)

proc fullMask*: Mask = newSeqWith(81, true)

proc `[]`*(board: Board, idx: I99): Value =
  board[9*idx.x + idx.y]

proc `[]=`*(board: var Board, idx: I99, v: Value) = # TODO return value, problems with discard
  board[9*idx.x + idx.y] = v

proc counts*(board: Board): Counts =
  result = newSeqWith(10, 0)
  for v in board:
    inc result[v]

### CONVERSIONS

proc I99_I81*(x: I99): I81 = 9*x[0]+x[1]

proc I81_I99*(r: I81): I99 = (I9(r div 9), I9(r mod 9))

proc I33_I9*(x: I33): I9 = 3*x[0]+x[1]

proc I9_I33*(r: I9): I33 = (I3(r div 3), I3(r mod 3))

proc I99_I33*(idx: I99): I33 = (I3(idx.x div 3), I3(idx.y div 3))

### ITERATORS

iterator elementsI99*(board: Board, mask = fullMask()): (I99, Value) =
  for i in 0..8:
    for j in 0..8:
      if mask[9*i+j]:
        yield ((i.I9, j.I9), board[9*i+j])


iterator row*(board: Board, ri: I9, mask = fullMask()): Value =
  for i in (9*ri)..<(9*(ri+1)):
    if mask[i]:
      yield board[i]


iterator rowI9*(board: Board, ri: I9, mask = fullMask()): (I9, Value) =
  for i in (9*ri)..<(9*(ri+1)):
    if mask[i]:
      yield ((i - 9*ri).I9, board[i])

iterator rowI99*(board: Board, ri: I9, mask = fullMask()): (I99, Value) =
  for i in (9*ri)..<(9*(ri+1)):
    if mask[i]:
      yield ((ri, (i - 9*ri).I9), board[i])

iterator column*(board: Board, ci: I9, mask = fullMask()): Value =
  for i in countup(ci.int, 80, 9):
    if mask[i]:
      yield board[i]

iterator columnI9*(board: Board, ci: I9, mask = fullMask()): (I9, Value) =
  for i in countup(ci.int, 80, 9):
    if mask[i]:
      yield (((i-ci) div 9).I9, board[i])

iterator columnI99*(board: Board, ci: I9, mask = fullMask()): (I99, Value) =
  for i in countup(ci.int, 80, 9):
    if mask[i]:
      yield ((((i-ci) div 9).I9, ci), board[i])

iterator blockI99*(board: Board, bi: I33, mask = fullMask()): (I99, Value) =
  let
    i = 9*3*bi.a
    j = 3*bi.b
  for di in 0..2:
    for dj in 0..2:
      if mask[(i+9*di) + j+dj]:
        yield (((3*bi.a+di).I9, (j+dj).I9), board[(i+9*di) + j+dj])


# MASK OPERATIONS (monitor changes true -> false in masks)

proc map*(mask: Mask, f: (I99, bool) -> bool, change: var bool): Mask =
  result = mask
  var prev: bool
  for i in 0..80:
    prev = result[i]
    result[i] = f(i.I81.I81_I99, mask[i])
    if prev != result[i] and prev == true:
      change = true

proc map*(mask: Mask, f: (I99, bool) -> bool): Mask =
  var dummy = false
  map(mask, f, dummy)

proc filter*(mask: Mask, pred: (I99, bool) -> bool, change: var bool): Mask =
  mask.map(
    proc (idx: I99, v: bool): bool =
      if pred(idx, v): v
      else: false,
    change)

proc filter*(mask: Mask, pred: (I99, bool) -> bool): Mask =
  var dummy = false
  filter(mask, pred, dummy)

proc remove_row*(mask: Mask, ri: I9): Mask =
  mask.filter((idx, _) => idx.x != ri)

proc remove_column*(mask: Mask, ci: I9): Mask =
  mask.filter((idx, _) => idx.y != ci)

proc remove_block*(mask: Mask, bi: I33): Mask =
  mask.filter((idx, _) => idx.I99_I33 != bi)

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


## STRATEGIES

iterator shadow*(board: Board, value: ProperValue): StrategyEvent =
  var mask = fullMask().filter((idx,_) => board[idx] == 0)

  for idx, v in board.elementsI99:
    if v == value:
      mask = mask.filter(
        (pos, _) => pos.x != idx.x and pos.y != idx.y and pos.I99_I33 != idx.I99_I33)

  var change = true
  var iteration = 0
  while change:
    change = false
    inc iteration
    yield StrategyEvent(kind: Iteration, n: iteration)

    for ri in 0..8:
      var selectedCol = -1
      var ok = true
      for i, _ in board.rowI9(ri.I9, mask):
        if selectedCol != -1:
          ok = false
          break
        else:
          selectedCol = i
      if ok and selectedCol != -1:
        yield StrategyEvent(kind: Found, idx: (ri.I9, selectedCol.I9), v: value)
        mask = mask.filter(
          (idx, _) =>
            idx.x != ri and idx.y != selectedCol and idx.I99_I33 != (ri.I9, selectedCol.I9).I99_I33,
          change)

    for ci in 0..8:
      var selectedRow = -1
      var ok = true
      for i, _ in board.columnI9(ci.I9, mask):
        if selectedRow != -1:
          ok = false
          break
        else:
          selectedRow = i
      if ok and selectedRow != -1:
        yield StrategyEvent(kind: Found, idx: (selectedRow.I9, ci.I9), v: value)
        mask = mask.filter(
          (idx, _) =>
            idx.x != selectedRow and idx.y != ci and idx.I99_I33 != (selectedRow.I9, ci.I9).I99_I33,
          change)

    for ba in 0..2:
      for bb in 0..2:
        let currentBlock = (ba.I3, bb.I3)
        var
          rows: set[I9]
          cols: set[I9]
          selectedRow: I9
          selectedCol: I9
        for idx, _ in board.blockI99((ba.I3, bb.I3), mask):
          rows = rows + {idx.x.I9}
          cols = cols + {idx.y.I9}

        if rows.len() == 1:
          for v in rows: selectedRow = v
          mask = mask.filter(
            (idx, _) => idx.x != selectedRow or idx.I99_I33 == currentBlock,
            change)
        if cols.len() == 1:
          for v in cols: selectedCol = v
          mask = mask.filter(
            (idx, _) => idx.y != selectedCol or idx.I99_I33 == currentBlock,
            change)
        if cols.len() == 1 and rows.len() == 1:
          yield StrategyEvent(kind: Found, depth: 1, idx: (selectedRow.I9, selectedCol.I9), v: value)
          mask = mask.filter(
            (idx, _) =>
              idx.x != selectedRow and idx.y != selectedCol and idx.I99_I33 != currentBlock,
            change)

let exampleBoard: Board = @[
  0,0,0, 0,0,0, 0,0,2,
  0,0,0, 0,0,0, 9,4,0,
  0,0,3, 0,0,0, 0,0,5,

  0,9,2, 3,0,5, 0,7,4,
  8,4,0, 0,0,0, 0,0,0,
  0,6,7, 0,9,8, 0,0,0,

  0,0,0, 7,0,6, 0,0,0,
  0,0,0, 9,0,0, 0,2,0,
  4,0,8, 5,0,0, 3,6,0,
].map(i => i.Value)

let harderBoard: Board = @[
  0,0,0, 0,6,7, 4,0,3,
  8,0,0, 1,0,0, 0,0,9,
  7,2,0, 4,0,0, 0,0,0,
  
  0,0,0, 0,0,0, 0,0,8,
  0,6,0, 2,0,9, 0,3,0,
  4,0,0, 0,0,0, 0,0,0,

  0,0,0, 0,0,2, 0,9,6,
  6,0,0, 0,0,4, 0,0,2,
  1,0,2, 9,5,0, 0,0,0,
].map(i => i.Value)


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
