## CellState represents the state of a cell in the Nonogram puzzle.
type
  CellState* = enum
    white = 0  # The cell is white (empty).
    black = 1  # The cell is black (filled).
    unknown = 2  # The cell's state is not yet determined.

## Nonogram represents the Nonogram puzzle.
type
  Nonogram* = object
    numRows: int  # Number of rows
    numCols: int  # Number of colmuns
    grid*: seq[seq[CellState]]  # Matrix of puzzle
    rowHints: seq[seq[int]]    # Hints of rows
    colHints: seq[seq[int]]  # Hints of colmuns

#" getters for hide values
proc numRows*(n: Nonogram): int {.inline.} =
  n.numRows
proc numCols*(n: Nonogram): int {.inline.} =
  n.numCols
proc rowHints*(n: Nonogram): seq[seq[int]] {.inline.} =
  n.rowHints
proc colHints*(n: Nonogram): seq[seq[int]] {.inline.} =
  n.colHints


## newNonogram creates a new Nonogram with the specified number of rows and columns.
##
## Parameters:
## - `numRows`: The number of rows in the puzzle.
## - `numCols`: The number of columns in the puzzle.
##
## Returns:
## A new Nonogram object initialized with the specified dimensions.
proc newNonogram*(numRows, numCols: int): Nonogram =
  result.numRows = numRows
  result.numCols = numCols
  result.grid = newSeqOfCap[seq[CellState]](numRows)
  for i in 0..<numRows:
    result.grid.add(newSeqOfCap[CellState](numCols))
    for j in 0..<numCols:
      result.grid[i].add(CellState.unknown)
  return result

## Converts the Nonogram object to a string representation.
##
## Returns:
## A string representing the Nonogram.
proc toString*(n: Nonogram): string =
  result = "Nonogram(rows: " & $n.numRows & ", columns: " & $n.numCols & ")\n"
  for row in n.grid:
    for cell in row:
      case cell
      of CellState.white: result.add("0 ")
      of CellState.black: result.add("1 ")
      of CellState.unknown: result.add("2 ")
    result.add("\n")
  return result

## countStateInRow counts the number of specific state in a row.
proc countStateInRow*(n: Nonogram, state: CellState, i : int): int = 
  for cell in n.grid[i]:
    if cell == state:
      result += 1
  return result

## countStateInRow counts the number of specific state in a column.
proc countStateInColumn*(n: Nonogram, state: CellState, j : int): int = 
  for i in 0..<n.numRows:
    if n.grid[i][j] == state:
      result += 1
  return result

## countStateInGrid counts the number of specific state in a grid.
proc countStateInGrid*(n: Nonogram, state: CellState): int = 
  for i in 0..<n.numRows:
    for j in 0..<n.numCols:
      if n.grid[i][j] == state:
        result += 1
  return result



