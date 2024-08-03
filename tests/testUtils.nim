import std/unittest
import NimNonogrampkg/[nonogram, constants, utils]

suite "Utils Tests":

  test "correct line2Hint":
    let
      row1: seq[CellState] = @[white, white, black, black, black, black, white, white]
      row2: seq[CellState] = @[white, black, black, white, white, black, black, black]
      row3: seq[CellState] = @[black, black, black, black, black, black, black, black]
      row4: seq[CellState] = @[white, white, white, white, white, white, white, white]
    
    check(line2Hint(row1) == @[4])
    check(line2Hint(row2) == @[2, 3])
    check(line2Hint(row3) == @[8])
    check(line2Hint(row4) == newSeq[int]())

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

  test "correct grid2GoalPattern":
    let
      rowHints = @[@[1], @[1]]
      colHints = @[@[1], @[1]]
      goalPattern = $constants.BlackSymbol & $constants.WhiteSymbol & $constants.WhiteSymbol & $constants.BlackSymbol  
    var nono = newNonogram(2, 2, rowHints, colHints)
    nono.grid[0][0] = CellState.black
    nono.grid[0][1] = CellState.white
    nono.grid[1][0] = CellState.white
    nono.grid[1][1] = CellState.black
    check(nono.grid2GoalPattern() == goalPattern)

    nono.grid[0][0] = CellState.unknown
    doAssertRaises(ValueError):
      discard nono.grid2GoalPattern()

  test "correct grid2GoalPattern":
    let goal = loadGoalFromDB(constants.ExamplePuzzlePath)
    check(goal == "0011110001100110110000111111111111000000110000110110011000111100")
