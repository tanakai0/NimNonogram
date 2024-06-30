import std/unittest
import NimNonogrampkg/[nonogram, constants, utils]

suite "Utils Tests":

  test "correct line2hint":
    let
      row1: seq[CellState] = @[white, white, black, black, black, black, white, white]
      row2: seq[CellState] = @[white, black, black, white, white, black, black, black]
      row3: seq[CellState] = @[black, black, black, black, black, black, black, black]
      row4: seq[CellState] = @[white, white, white, white, white, white, white, white]
    
    check(line2hint(row1) == @[4])
    check(line2hint(row2) == @[2, 3])
    check(line2hint(row3) == @[8])
    check(line2hint(row4) == newSeq[int]())

  test "correct isSolved":
    var
      nono: Nonogram = loadPuzzle(constants.ExamplePuzzlePath)
      answer: seq[CellState] = @[
        white, white, black, black, black, black, white, white,
        white, black, black, white, white, black, black, white,
        black, black, white, white, white, white, black, black,
        black, black, black, black, black, black, black, black,
        black, black, white, white, white, white, white, white,
        black, black, white, white, white, white, black, black,
        white, black, black, white, white, black, black, white,
        white, white, black, black, black, black, white, white
      ]
    for i in 0..<nono.numRows:
      for j in 0..<nono.numCols:
        nono.grid[i][j] = answer[i * nono.numCols + j]
    check(isSolved(nono) == true)
    nono.grid[0][0] = black
    check(isSolved(nono) == false)

  test "correct degreeOfFreedom":
    var
      dimension: int = 10
      hint: seq[int] = @[2, 3]
    check(degreeOfFreedom(dimension, hint) == 15)
