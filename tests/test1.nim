# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import std/[unittest, strutils]
import NimNonogrampkg/types

suite "Nonogram Tests":

  test "correct countStateInRow":
    var n = newNonogram(5, 5)
    n.grid[0][0] = CellState.black
    n.grid[0][1] = CellState.black
    n.grid[0][2] = CellState.white
    n.grid[0][3] = CellState.unknown
    n.grid[0][4] = CellState.black
    
    check(countStateInRow(n, CellState.black, 0) == 3)
    check(countStateInRow(n, CellState.white, 0) == 1)
    check(countStateInRow(n, CellState.unknown, 0) == 1)

  test "correct countStateInColumn":
    var n = newNonogram(5, 5)
    n.grid[0][0] = CellState.black
    n.grid[1][0] = CellState.black
    n.grid[2][0] = CellState.white
    n.grid[3][0] = CellState.unknown
    n.grid[4][0] = CellState.black
    
    check(countStateInColumn(n, CellState.black, 0) == 3)
    check(countStateInColumn(n, CellState.white, 0) == 1)
    check(countStateInColumn(n, CellState.unknown, 0) == 1)

  test "correct countStateInGrid":
    var n = newNonogram(5, 5)
    n.grid[0][0] = CellState.black
    n.grid[1][1] = CellState.black
    n.grid[2][2] = CellState.white
    n.grid[3][3] = CellState.unknown
    n.grid[4][4] = CellState.black
    
    check(countStateInGrid(n, CellState.black) == 3)
    check(countStateInGrid(n, CellState.white) == 1)
    check(countStateInGrid(n, CellState.unknown) == 25 - 4)

  test "toString produces correct output":
    var n = newNonogram(2, 2)
    n.grid[0][0] = CellState.black
    n.grid[0][1] = CellState.white
    n.grid[1][0] = CellState.unknown
    n.grid[1][1] = CellState.black
    
    let output: string = n.toString()
    check(output.contains("Nonogram(rows: 2, columns: 2)\n"))
    check(output.contains("1 0 \n"))
    check(output.contains("2 1 \n"))

# To run these tests, simply execute `nimble test`.
