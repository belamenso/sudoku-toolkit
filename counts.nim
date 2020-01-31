import
  sequtils, sugar

import
  types, examples

iterator trivial(board: Board): Value {.closure.} =
  for i in 0..80:
    yield board[i]

proc counts*(board: Board, it: iterator(_:Board): Value = trivial): Counts =
  result = newSeqWith(10, 0)
  for v in it(board):
    inc result[v]

when isMainModule:
  # TODO better syntax for this
  echo counts(harderBoard, iterator(b: Board): Value {.closure.} =
    for y in b.row(8): yield y
  )
