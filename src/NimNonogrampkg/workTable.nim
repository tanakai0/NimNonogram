import times
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


## 
## updateCellState performs three tasks:
## 1. Changes the cell state from unknown to black or white.
## 2. Records the coloring in the coloringLog.
## 3. Updates the counts of unknown cells in the WorkTable.
##
## Parameters:
## - workTable: The WorkTable object.
## - row: The row index of the cell to be updated.
## - col: The column index of the cell to be updated.
## - state: The desired state to set the cell.
##
## Returns:
## - bool: True if the cell state was successfully updated and logged, false otherwise.
proc updateCellState*(workTable: var WorkTable, row: int, col: int, state: CellState): bool = 
  if workTable.nonogram.setCellState(row, col, state):
    workTable.coloringLog.push(row, col, state)
    workTable.totalUnknown -= 1
    workTable.rowUnknown[row] -= 1
    workTable.colUnknown[col] -= 1
    return true
  else:
    return false

## updateRowStates updates the states of an entire row in the Nonogram grid.
## It uses updateCellState to set each cell in the row and update the WorkTable accordingly.
##
## Parameters:
## - workTable: The WorkTable object.
## - row: The row index of the cells to be updated.
## - states: A sequence of CellState values to set for the specified row.
##
## Returns:
## - bool: True if at least one cell state was successfully updated, false otherwise.
proc updateRowStates*(workTable: var WorkTable, row: int, states: seq[CellState]): bool = 
  var
    updateAtLeastOne: bool = false
    updateResult: bool
  for col in 0 ..< workTable.nonogram.numCols:
    updateResult = workTable.updateCellState(row, col, states[col])
    updateAtLeastOne = (updateAtLeastOne or updateResult)
    # updateAtLeastOne = (updateAtLeastOne or workTable.updateCellState(row, col, states[col]))  will not work as the way you want.
    # Nim uses the short-circuit evaluation?
    # If the updateAtLeastOne is true, workTable.updateCellState(row, col, states[col]) is not evaluated. So the proc will not be activated.
  return updateAtLeastOne

## updateColStates updates the states of an entire col in the Nonogram grid.
## It uses updateCellState to set each cell in the col and update the WorkTable accordingly.
##
## Parameters:
## - workTable: The WorkTable object.
## - col: The col index of the cells to be updated.
## - states: A sequence of CellState values to set for the specified col.
##
## Returns:
## - bool: True if at least one cell state was successfully updated, false otherwise.
proc updateColStates*(workTable: var WorkTable, col: int, states: seq[CellState]): bool = 
  var 
    updateAtLeastOne: bool = false
    updateResult: bool
  for row in 0 ..< workTable.nonogram.numRows:
    updateResult = workTable.updateCellState(row, col, states[row])
    updateAtLeastOne = (updateAtLeastOne or updateResult)
  return updateAtLeastOne


proc updateLineStates*(workTable: var WorkTable, lineIndex: int, states: seq[CellState], asRow: bool): bool = 
  if asRow:
    return updateRowStates(workTable, lineIndex, states)
  else:
    return updateColStates(workTable, lineIndex, states)
