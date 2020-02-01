import
  sequtils, sugar, random

import
  types, verification

randomize()

## PERMUTATIONS

type
  # of length 9
  Permutation = seq[ProperValue]

proc assertProperPermutation*(pi: Permutation) =
  doAssert pi.len() == 9
  var seen = newSeqWith(9, 0)
  for i in 0..8:
    inc seen[pi[i] - 1]
  doAssert seen.all(v => v == 1)

proc identityPermutation*: Permutation =
  toSeq(1..9).map(i => i.ProperValue)

proc swap*(pi: Permutation, x, y: ProperValue): Permutation =
  result = pi
  swap(result[x-1], result[y-1])

proc `<<`*(pi: Permutation, x: ProperValue): ProperValue = # TODO something better
  pi[x-1]

proc reverse*(pi: Permutation): Permutation =
  result = newSeqWith(9, 1.ProperValue)
  for i in 1..9:
    result[(pi << i) - 1] = i.ProperValue

proc `<<`*(pi: Permutation, board: Board): Board =
  result = board
  for i in 0..80:
    if board[i] != 0:
      result[i] = pi << board[i]

proc randomPermutation*: Permutation =
  result = identityPermutation()
  shuffle(result)

proc canonicalPermutation(board: Board): Permutation =
  doAssert valid(board)
  for _, v in board.blockI99((0.I3, 0.I3)):
    doAssert (v > 0)
  
  result = identityPermutation()
  for idx, v in board.blockI99((0.I3, 0.I3)):
    result[v-1] = 1 + 3*idx.x + idx.y
  
  assertProperPermutation(result)


## ROTATIONS

proc rotateRight*(board: Board, timesN: Natural = 1): Board =
  let times = timesN mod 4
  
  result = board
  for idx, v in board.elementsI99:
    var (x,y)= idx
    for _ in 1..times:
      (x, y) = (y, 8-x)
    result[(x.I9, y.I9)] = v

proc rotateRandom*(board: Board): Board =
  rotateRight(board, rand(0..3))

## FLIPS

proc flipHorizontally*(board: Board): Board =
  result = emptyBoard()
  for idx, v in board.elementsI99:
    result[((8-idx.x).I9, idx.y.I9)] = v

proc flipVertically*(board: Board): Board =
  result = emptyBoard()
  for idx, v in board.elementsI99:
    result[(idx.x.I9, (8-idx.y).I9)] = v

proc flip*(board: Board, v: bool, h: bool): Board =
  result = board
  if v: result = board.flipVertically()
  if h: result = board.flipHorizontally()

proc flipRandom*(board: Board): Board =
  flip(board, rand(0..1) > 0, rand(0..1) > 0)

# All random

proc randomSymmetry*(board: Board): Board =
  randomPermutation() << board.flipRandom().rotateRandom()

import sudoku
when isMainModule:
  let b = """
    684|159|732
    751|832|946
    923|674|185
    --- --- ---
    192|365|874
    845|217|693
    367|498|251
    --- --- ---
    239|746|518
    516|983|427
    478|521|369""".parse()
  let pi = b.canonicalPermutation()
  echo pi
  echo render(pi << b)
