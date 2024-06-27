import std/deques
import nonogram

# CellIndexColor is a tuple that contains the cell's index and color.
type
  CellIndexColor* = tuple[rowInd: int, colInd: int, color: CellState]

## ColoringOrder represents order of drawing colos in each cell.
type
  ColoringOrder* = Deque[CellIndexColor]  


# Function to create a new ColoringOrder
proc newColoringOrder*(n: Nonogram): ColoringOrder =
  result = initDeque[CellIndexColor](initialSize = n.numRows * n.numCols)
  return result

