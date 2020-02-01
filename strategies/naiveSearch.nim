import sequtils, sugar
import ../types, ../examples, ../verification, ../sudoku

proc wouldBeInvalid(b: var Board, idx: I99, v: ProperValue): bool =
  result = false
  block outer:
    b[idx] = v
    if not validRow(b, idx.x):
      result = true
      break outer
    if not validColumn(b, idx.y):
      result = true
      break outer
    if not validBlock(b, idx.I99_I33):
      result = true
      break outer
  b[idx] = 0

iterator naiveSearch*(boardToCopy: Board): StrategyEvent =
  var board = boardToCopy

  proc solve(boad: var Board, start: int = 0) =
    for i in start..80:
      if board[i] == 0:
        for v in 1..9:
          if not wouldBeInvalid(board, i.I81_I99, v):
            board[i] = v
            if i >= 80: raise newException(Exception, "done")
            solve(board, i+1)
          board[i] = 0
        return
  
  try:
    solve(board)
    yield StrategyEvent(kind: StrategyFailed, depth: 0)
  except:
    yield StrategyEvent(kind: FoundBoard, depth: 0, board: board)

  #[var stack: seq[tuple[start, v: int]]
  stack.add( (0, 1) ) # both not yet tried
  var first = nativeStackTraceSupported
  
  block outer:
    while stack.len() > 0:
      block loop:
        while stack.len() > 0:
          var (start, initial_v) = stack.pop()
          for i in start..80:
            #doAssert board[0..(i-1)].all(v => v != 0)
            if i != start or first:
              initial_v = 1
              if board[i] != 0: continue
            first = false
            for v in initial_v..9:
              board[i] = v
              if not valid(board):
                board[i] = 0
                continue
              yield StrategyEvent(kind: Guessed, depth: stack.len(), guessIdx: i.I81_I99, guessV: v)
              if i == 80:
                yield StrategyEvent(kind: FoundBoard, depth: stack.len(), board: board)
                break outer
              stack.add (i, v+1)
              stack.add (i+1, 1)
              break loop
            board[i] = 0]#

when isMainModule:
  for ev in naiveSearch(harderBoard):
    echo ev
    if ev.kind == FoundBoard:
      echo render(ev.board)
