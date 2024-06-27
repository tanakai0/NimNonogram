import std/deques
import ../[nonogram, coloringLog]

type
  NonogramSolver* = ref object of RootObj

type
  TestNonogramSolver* = ref object of NonogramSolver
    param1*: string


proc newTestNonogramSolver*(param1: string): TestNonogramSolver = 
  result = TestNonogramSolver(param1: param1)
  result.param1 = param1
  return result

## solve proc. starts to solve puzzle
## This proc. will be overloaded by a subclass of NonogramSolver
method solve*(solver: NonogramSolver): bool {.base.} = 
  return false

method solve*(solver: TestNonogramSolver): bool = 
  echo "solve in TestNonogramSolver"
  return true

proc setAndLogCellState*(nonogram: var Nonogram, coloringLog: var ColoringLog, row: int, col: int, state: CellState): bool = 
  if nonogram.setCellState(row, col, state):
    coloringLog.addLast((rowInd: row, colInd: col, color: state))
    return true
  else:
    return false
