import
  sugar, sequtils
import
  sudoku, examples

type
  InvalidityKind* = enum
    RepeatedValue
  
  Invalidity* = object
    case kind*: InvalidityKind:
    of RepeatedValue:
      idx1*: I99
      idx2*: I99
      sameRow, sameCol, sameBlock: bool


proc newRepeatedValue(idx1, idx2: I99): Invalidity =
  Invalidity(
    kind: RepeatedValue,
    idx1: idx1, idx2: idx2,
    sameRow: idx1.x == idx2.x,
    sameCol: idx1.y == idx2.y,
    sameBlock: idx1.I99_I33 == idx2.I99_I33)


iterator report(seen: var seq[(I99,I99)], idx1, idx2: I99): Invalidity =
  if (idx1, idx2) notin seen:
    seen.add (idx1, idx2)
    seen.add (idx2, idx1)
    yield newRepeatedValue(idx1, idx2)


iterator invalidities*(board: Board): Invalidity =
  var seen: seq[(I99,I99)]
  let mask = fullMask().filter((idx, _) => board[idx] != 0)

  for idx, v in board.elementsI99(mask):
    for idx1, v1 in board.rowI99(idx.x, mask):
      if idx != idx1 and v == v1:
        for x in report(seen, idx, idx1): yield x
    for idx1, v1 in board.columnI99(idx.y, mask):
      if idx != idx1 and v == v1:
        for x in report(seen, idx, idx1): yield x
    for idx1, v1 in board.blockI99(idx.I99_I33, mask):
      if idx != idx1 and v == v1:
        for x in report(seen, idx, idx1): yield x


iterator invaliditiesInRow*(board: Board, ri: I9): Invalidity =
  var seen: seq[(I99,I99)]
  let mask = fullMask().filter((idx, _) => board[idx] != 0)

  for idx, v in board.rowI99(ri, mask):
    for idx1, v1 in board.rowI99(ri, mask):
      if idx != idx1 and v == v1:
        for x in report(seen, idx, idx1): yield x


iterator invaliditiesInColumn*(board: Board, ci: I9): Invalidity =
  var seen: seq[(I99,I99)]
  let mask = fullMask().filter((idx, _) => board[idx] != 0)

  for idx, v in board.columnI99(ci, mask):
    for idx1, v1 in board.columnI99(ci, mask):
      if idx != idx1 and v == v1:
        for x in report(seen, idx, idx1): yield x
      

iterator invaliditiesInBlock*(board: Board, bi: I33): Invalidity =
  var seen: seq[(I99,I99)]
  let mask = fullMask().filter((idx, _) => board[idx] != 0)

  for idx, v in board.blockI99(bi, mask):
    for idx1, v1 in board.blockI99(bi, mask):
      if idx != idx1 and v == v1:
        for x in report(seen, idx, idx1): yield x


proc valid*(board: Board): bool =
  for _ in invalidities(board):
    return false
  true

proc validRow*(board: Board, ri: I9): bool =
  for _ in invaliditiesInRow(board, ri):
    return false
  true

proc validColumn*(board: Board, ci: I9): bool =
  for _ in invaliditiesInColumn(board, ci):
    return false
  true

proc validBlock*(board: Board, bi: I33): bool =
  for _ in invaliditiesInBlock(board, bi):
    return false
  true

when isMainModule:
  for x in invalidities(harderBoard):
    echo x
