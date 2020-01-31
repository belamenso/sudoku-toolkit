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

  Counts* = seq[int] # todo something other than int? what abount count of zeros?
