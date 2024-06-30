import times
import std/deques
import nonogram, coloringLog

## WorkTable collects information to solve a puzzle.
type
  WorkTable* = object
    nonogram*: Nonogram
    startTime: float  # Start time for time measurement
    endTime: float  # End time for time measurement
    coloringLog*: ColoringLog
    totalUnknown*: int  # The number of unkown cells in the grid
    rowUnknown*: seq[int]  # The number of unkown cells in each row
    colUnknown*: seq[int]  # The number of unkown cells in each column

#" getters for hide values
proc endTime*(wt: WorkTable): float {.inline.} =
  wt.endTime

## Function to create a new WorkTable
proc newWorkTable*(nonogram: Nonogram): WorkTable =
  result.nonogram = nonogram
  result.startTime = cpuTime()
  result.endTime = 0.0
  result.coloringLog = newColoringLog(nonogram)
  result.totalUnknown = nonogram.numRows * nonogram.numCols
  result.rowUnknown = newSeq[int](nonogram.numRows)
  result.colUnknown = newSeq[int](nonogram.numCols)
  
  for row in 0..<nonogram.numRows:
    result.rowUnknown[row] = nonogram.numCols
  for col in 0..<nonogram.numRows:
    result.colUnknown[col] = nonogram.numRows

  return result

## stopTime measures the elapsed time
proc stopTimer*(workTable: var WorkTable) =
  workTable.endTime = cpuTime() - workTable.startTime

## updateCellState will do three jobs
## 1. Change the cell state from unkown to black or white
## 2. Record the coloringLog
## 3. Update the counts of unkown cells
proc updateCellState*(workTable: var WorkTable, row: int, col: int, state: CellState): bool = 
  if workTable.nonogram.setCellState(row, col, state):
    workTable.coloringLog.push(row, col, state)
    workTable.totalUnknown -= 1
    workTable.rowUnknown[row] -= 1
    workTable.colUnknown[col] -= 1
    return true
  else:
    return false
