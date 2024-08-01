import std/deques
import nonogram

# CellIndexColor is a tuple that contains the cell's index and color.
type
  CellIndexColor* = tuple[row: int, col: int, color: CellState]

## ColoringLog represents order of drawing colos in each cell.
type
  ColoringLog* = Deque[CellIndexColor]  


# Function to create a new ColoringLog
proc newColoringLog*(n: Nonogram): ColoringLog =
  result = initDeque[CellIndexColor](initialSize = n.numRows * n.numCols)
  return result

proc push*(coloringLog: var ColoringLog, row: int, col: int, color: CellState) = 
  if color == unknown:
    raise newException(ValueError, "ColoringLog cannot contain unknown.")
  coloringLog.addLast((row: row, col: col, color: color))

# Function to get the last n elements from the ColoringLog
proc getLastN*(coloringLog: ColoringLog, n: int): seq[CellIndexColor] =
  if coloringLog.len < n:
    raise newException(ValueError, "Not enough elements in ColoringLog to retrieve last n elements.")
  result = @[]
  for i in 0..<n:
    result.add(coloringLog[coloringLog.len - i - 1])


when isMainModule:
  let nono = newNonogram(2, 2, @[@[1], @[1]], @[@[1], @[1]])
  var log = newColoringLog(nono)
  
  log.push(0, 0, black)
  log.push(1, 1, white)
  log.push(2, 2, black)
  
  try:
    let lastTwo = log.getLastN(1)
    echo lastTwo
  except ValueError as e:
    echo e.msg
