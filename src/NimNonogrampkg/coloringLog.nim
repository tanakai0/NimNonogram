import std/deques
import nonogram

# CellIndexColor is a tuple that contains the cell's index and color.
type
  CellIndexColor* = tuple[rowInd: int, colInd: int, color: CellState]

## ColoringLog represents order of drawing colos in each cell.
type
  ColoringLog* = Deque[CellIndexColor]  


# Function to create a new ColoringLog
proc newColoringLog*(n: Nonogram): ColoringLog =
  result = initDeque[CellIndexColor](initialSize = n.numRows * n.numCols)
  return result

