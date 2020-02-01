import
  sugar, sequtils
import
  types

let harderBoard*: Board = @[
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


let exampleBoard*: Board = @[
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