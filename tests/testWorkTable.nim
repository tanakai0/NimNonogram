import std/[unittest, os]
import NimNonogrampkg/[nonogram, workTable, constants]

suite "WorkTable Tests":

  test "test updateCellState":
    var
      nono: Nonogram = loadPuzzle(constants.ExamplePuzzlePath)
      wt: WorkTable = newWorkTable(nono)

    check(wt.totalUnknown == 64)
    check(wt.rowUnknown == @[8, 8, 8, 8, 8, 8, 8, 8])
    check(wt.colUnknown == @[8, 8, 8, 8, 8, 8, 8, 8])
    
    check(updateCellState(wt, 0, 0, CellState.white) == true)
    check(wt.nonogram.grid[0][0] == CellState.white)
    check(wt.totalUnknown == 64 - 1)
    check(wt.rowUnknown == @[7, 8, 8, 8, 8, 8, 8, 8])
    check(wt.colUnknown == @[7, 8, 8, 8, 8, 8, 8, 8])
    
    check(updateCellState(wt, 0, 0, CellState.white) == false)  # Already set, should return false
    check(wt.nonogram.grid[0][0] == CellState.white)  # No change
    check(wt.totalUnknown == 64 - 1)
    check(wt.rowUnknown == @[7, 8, 8, 8, 8, 8, 8, 8])
    check(wt.colUnknown == @[7, 8, 8, 8, 8, 8, 8, 8])

test "test stopTimer":
  var
    nono: Nonogram = loadPuzzle(constants.ExamplePuzzlePath)
    wt: WorkTable = newWorkTable(nono)
    
  # Simulate some work by sleeping for 1 second
  sleep(100)  
  stopTimer(wt)

  check((0.1 <= wt.endTime) and (wt.endTime <= 0.2))
