import ../[nonogram, coloringOrder]

type
  NonogramSolver* = ref object of RootObj
    nonogram*: Nonogram
    coloringOrder*: ColoringOrder

type
  TestNonogramSolver* = ref object of NonogramSolver
    param1*: string


proc newTestNonogramSolver*(param1: string): TestNonogramSolver = 
  result = TestNonogramSolver(param1: param1)
  result.param1 = param1
  return result
    
proc solve*(filePath: string) =
  echo "Solving puzzle from file: ", filePath

## solve proc. starts to solve puzzle
## This proc. will be overloaded by a subclass of NonogramSolver
method solve*(solver: NonogramSolver): bool {.base.} = 
  return false

method solve*(solver: TestNonogramSolver): bool = 
  echo "solve in TestNonogramSolver"
  return true
