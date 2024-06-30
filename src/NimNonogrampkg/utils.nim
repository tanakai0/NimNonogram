import math

import nonogram

proc line2hint*(line: seq[CellState]): seq[int] =
  var
    hint: seq[int] = @[]
    count: int = 0
    black: CellState = CellState.black
    white: CellState = CellState.white

  for cell in line:
    if cell == black:
      count += 1
    elif cell == white and count > 0:
      hint.add(count)
      count = 0

  if count > 0:
    hint.add(count)

  return hint


proc isSolved*(nono: Nonogram): bool = 
  if nono.countStateInGrid(unknown) != 0:
    return false
  for i in 0..<nono.numRows:
    if line2hint(nono.grid[i]) != nono.rowHints[i]:
      return false
  for i in 0..<nono.numCols:
    if line2hint(nono.grid.getCol(i)) != nono.colHints[i]:
      return false
  return true


proc degreeOfFreedom*(dimension: int, hint: seq[int]): int =
  let
    k = hint.len
    b = sum(hint)
  return fac(dimension-b+1) div (fac(dimension - b + 1 - k) * fac(k))
