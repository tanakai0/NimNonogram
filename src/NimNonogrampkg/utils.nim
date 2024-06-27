import nonogram


proc row2hint*(row: seq[CellState]): seq[int] =
  var
    hint: seq[int] = @[]
    count = 0
    black = CellState.black
    white = CellState.white

  for cell in row:
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
    if row2hint(nono.grid[i]) != nono.rowHints[i]:
      return false
  for i in 0..<nono.numCols:
    if row2hint(nono.grid.getCol(i)) != nono.colHints[i]:
      return false
  return true


