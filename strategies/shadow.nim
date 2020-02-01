import sequtils, sugar
import ../types

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
        yield StrategyEvent(kind: FoundValue, idx: (ri.I9, selectedCol.I9), v: value)
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
        yield StrategyEvent(kind: FoundValue, idx: (selectedRow.I9, ci.I9), v: value)
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
          yield StrategyEvent(kind: FoundValue, depth: 1, idx: (selectedRow.I9, selectedCol.I9), v: value)
          mask = mask.filter(
            (idx, _) =>
              idx.x != selectedRow and idx.y != selectedCol and idx.I99_I33 != currentBlock,
            change)
