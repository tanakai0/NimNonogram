import std/parseopt
import nonogram, puzzleMaker, help, solverspkg/solvers, workTable

proc solveNonogram*(filePath: string) = 
    var
        nonogram: Nonogram = loadPuzzle(filePath)
        workTable: WorkTable = newWorkTable(nonogram)
        solver: NonogramSolver = newTestNonogramSolver(workTable, "test")
    echo "nonogram size = (", solver.workTable.nonogram.numRows, ", ", solver.workTable.nonogram.numCols, ")"

proc cli*() =
  var
    filePath: string = ""
    imagePath: string = ""
    helpFlag: bool = false
    solveFlag: bool = false
    makePuzzleFlag: bool = false
    argCtr: int = 0

  for kind, key, value in getOpt():
    case kind
    of cmdArgument:
      echo "# Positional argument ", argCtr, ": \"", key, "\""
      argCtr.inc
    of cmdLongOption, cmdShortOption:
      case key
      of "solve":
        solveFlag = true
        filePath = value
      of "make_puzzle":
        makePuzzleFlag = true
        imagePath = value
      of "help", "h":
        helpFlag = true
      else:
        echo "Unknown option: ", key
        showHelp()
        quit(1)
    of cmdEnd:
      discard

  if helpFlag or (not solveFlag and not makePuzzleFlag):
    showHelp()
  elif solveFlag:
    if filePath == "":
      echo "Error: --solve requires a file path."
      showHelp()
      quit(1)
    solveNonogram(filePath)
  elif makePuzzleFlag:
    if imagePath == "":
      echo "Error: --make_puzzle requires an image path."
      showHelp()
      quit(1)
    makePuzzle(imagePath)
