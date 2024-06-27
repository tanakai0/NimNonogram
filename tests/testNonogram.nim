# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import std/[unittest, strutils]
import NimNonogrampkg/[nonogram, constants]

suite "Nonogram Tests":

  test "correct countStateInRow":
    var rowHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var colHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var n = newNonogram(5, 5, rowHints, colHints)
    n.grid[0][0] = CellState.black
    n.grid[0][1] = CellState.black
    n.grid[0][2] = CellState.white
    n.grid[0][3] = CellState.unknown
    n.grid[0][4] = CellState.black
    
    check(countStateInRow(n, CellState.black, 0) == 3)
    check(countStateInRow(n, CellState.white, 0) == 1)
    check(countStateInRow(n, CellState.unknown, 0) == 1)

  test "correct countStateInColumn":
    var rowHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var colHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var n = newNonogram(5, 5, rowHints, colHints)
    n.grid[0][0] = CellState.black
    n.grid[1][0] = CellState.black
    n.grid[2][0] = CellState.white
    n.grid[3][0] = CellState.unknown
    n.grid[4][0] = CellState.black
    
    check(countStateInColumn(n, CellState.black, 0) == 3)
    check(countStateInColumn(n, CellState.white, 0) == 1)
    check(countStateInColumn(n, CellState.unknown, 0) == 1)

  test "correct countStateInGrid":
    var rowHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var colHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var n = newNonogram(5, 5, rowHints, colHints)
    n.grid[0][0] = CellState.black
    n.grid[1][1] = CellState.black
    n.grid[2][2] = CellState.white
    n.grid[3][3] = CellState.unknown
    n.grid[4][4] = CellState.black
    
    check(countStateInGrid(n, CellState.black) == 3)
    check(countStateInGrid(n, CellState.white) == 1)
    check(countStateInGrid(n, CellState.unknown) == 25 - 4)

  test "toString produces correct output":
    var rowHints = @[@[], @[1]]
    var colHints = @[@[1], @[]]
    var n = newNonogram(2, 2, rowHints, colHints)
    n.grid[0][0] = CellState.black
    n.grid[0][1] = CellState.white
    n.grid[1][0] = CellState.unknown
    n.grid[1][1] = CellState.black
    
    let output: string = n.toString()
    check(output.contains("Nonogram(rows: 2, columns: 2)\n"))
    check(output.contains("1 0 \n"))
    check(output.contains("2 1 \n"))

  test "loadPuzzle produces correct output":
    var
      non: Nonogram = loadPuzzle(constants.ExamplePuzzlePath)
    check(non.numRows == 8)
    check(non.numCols == 8)
    check(non.rowHints == @[@[4], @[2, 2], @[2, 2], @[8], @[2], @[2, 2], @[2, 2], @[4]])
    check(non.colHints == @[@[4], @[6], @[2, 1, 2], @[1, 1, 1], @[1, 1, 1], @[2, 1, 2], @[3, 2], @[2, 1]])

  test "check checkMinimalHints":
    var rowHints = @[@[2, 2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    var colHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    discard newNonogram(5, 5, rowHints, colHints)

  test "checkMinimalHints raises exception on invalid hints":
    var rowHints = @[@[2, 3], @[2, 1], @[1, 1], @[6], @[1, 1]]  # Invalid row hint
    var colHints = @[@[2], @[2, 1], @[1, 1], @[3], @[1, 1]]
    expect ValueError:
      discard newNonogram(5, 5, rowHints, colHints)



# To run these tests, simply execute `nimble test`.
