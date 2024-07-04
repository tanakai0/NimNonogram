import std/unittest
import NimNonogrampkg/[constants, nonogram, workTable, utils]
import NimNonogrampkg/solverspkg/heuristicLogicSolver

suite "heuristicLogicSolver Tests":
  test "correct preprocessingLineLogic":
    #     Example
    #     -------
    #     x:blank, 1:black
    #     xxxxxxxxxxxxxxxxxxxx length of the line m = 20(index 0-19), d = [1,10,4] = [d0,d1,d2]
        
    #     step1
    #     1xxxxxxxxxxxxxxxxxxx left packing [1]
    #     xxx1x1111111111x1111 right packing [1,10,4]
    #     ls0 = 0, le0 = ls0 + d0 -1 = 0, rs0 = m - sum(hint) - hintNums + 1 = 3 = z
    #     z > 0 is consistent. Set black from index rs0(=3) to le0(=0) (but no cell is set)
        
    #     step2
    #     1x1111111111xxxxxxxx left packing [1,10]
    #     xxxxx1111111111x1111 right packing [10,4]
    #     ls1 = le0 + 2 = 2, le1 = ls1 + d1 -1 = 11, rs1 = ls1 + z = 5
    #     Set black from index rs1(=5) to le1(=11)
        
    #     step3
    #     1x1111111111x1111xxx left packing [1,10,4]
    #     xxxxxxxxxxxxxxxx1111 right packing [4]
    #     ls2 = le1 + 2 = 13, le2 = ls2 + d2 -1 = 16, rs2 = ls2 + z = 16
    #     Set black from index rs2(=16) to le2(=16)
    #     Thus,
    #     xxxxx1111111xxxx1xxx
    let
      rowHints = @[@[1, 10, 4]]
      colHints = @[@[], @[], @[1], @[], @[1], @[1], @[1], @[1], @[1], @[1], @[1], @[1], @[1], @[1], @[], @[1], @[1], @[1], @[1], @[]]
      preprocessedGrid: seq[seq[CellState]] = 
        @[@[unknown, unknown, unknown, unknown, unknown, black, black, black, black, black, 
          black, black, unknown, unknown, unknown, unknown, black, unknown, unknown, unknown]]
    var
      nono = newNonogram(1, 20, rowHints, colHints)
      wt = newWorkTable(nono)
    preprocessingLine(wt, 0, true)
    check(wt.nonogram.grid == preprocessedGrid)

  test "correct HeuristicPreprocessingSolver":
    var
      solver: HeuristicPreprocessingSolver = newHeuristicPreprocessingSolver(constants.ExamplePuzzlePath)
      preprocessedGrid: seq[seq[CellState]] = 
        @[@[unknown, unknown, unknown, unknown, unknown, unknown, unknown, unknown], 
          @[unknown, unknown, black  , unknown, unknown, black  , unknown, unknown], 
          @[unknown, black  , unknown, unknown, unknown, unknown, black  , unknown], 
          @[black  , black  , black  , black  , black  , black  , black  , black  ], 
          @[unknown, black  , unknown, unknown, unknown, unknown, unknown, unknown],
          @[unknown, black  , unknown, unknown, unknown, unknown, unknown, unknown], 
          @[unknown, unknown, black  , unknown, unknown, black  , unknown, unknown], 
          @[unknown, unknown, unknown, unknown, unknown, unknown, unknown, unknown]]
    discard solver.solve()
    check (solver.workTable.nonogram.grid == preprocessedGrid)

  test "correct enumerateAllColoring":
    let
      correctAnswer1: seq[seq[CellState]] = @[@[black, white, black, black, white], 
                                              @[black, white, white, black, black]]
      correctAnswer2: seq[seq[CellState]] = @[@[black, white, black, black, white, black, white], 
                                              @[black, white, black, black, white, white, black],
                                              @[black, white, white, black, black, white, black]]
      correctAnswer3: seq[seq[CellState]] = @[]
      line: seq[CellState] = @[unknown, unknown, unknown, unknown, unknown, unknown, unknown]
      hint: seq[int] = @[1, 1, 1]
    var
      answer1: seq[seq[CellState]]
      answer2: seq[seq[CellState]]
      answer3: seq[seq[CellState]]
    
    for x in enumerateAllColoring(@[black, unknown, unknown, black, unknown], @[1, 2]):
      answer1.add(x)
    check(answer1 == correctAnswer1)
    
    for x in enumerateAllColoring(@[black, unknown, unknown, black, unknown, unknown, unknown], @[1, 2, 1]):
      answer2.add(x)
    check(answer2 == correctAnswer2)

    # Contradictional case
    for x in enumerateAllColoring(@[black, unknown, black], @[1, 2]):
      answer2.add(x)
    check(answer3 == correctAnswer3)
    
    # Check only the number of patterns
    var count: int = 0
    for x in enumerateAllColoring(line, hint):
      inc(count)
    check(degreeOfFreedom(len(line), hint) == count)

  test "correct leftMostJustification and rightMostJustification":
    let
      correctAnswer1: seq[CellState] = @[black, white, black, black, white, black, white]
      correctAnswer2: seq[CellState] = @[black, white, white, black, black, white, black]
      correctAnswer3: seq[CellState] = @[]
    
    check(leftMostJustification(@[black, unknown, unknown, black, unknown, unknown, unknown], @[1, 2, 1]) == correctAnswer1)
    check(rightMostJustification(@[black, unknown, unknown, black, unknown, unknown, unknown], @[1, 2, 1]) == correctAnswer2)
    
    # Contradictional case
    check(leftMostJustification(@[black, unknown, black], @[1, 2]) == correctAnswer3)
    check(rightMostJustification(@[black, unknown, black], @[1, 2]) == correctAnswer3)
