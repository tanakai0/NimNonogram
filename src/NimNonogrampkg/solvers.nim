import nonogram, coloringOrder

type
  NonogramSolver* = ref object of RootObj
    nonogram*: Nonogram
    coloringOrder*: ColoringOrder
    
proc solve*(filePath: string) =
  echo "Solving puzzle from file: ", filePath

## solve proc. starts to solve puzzle
## This proc. will be overloaded by a subclass of NonogramSolver
method solve*(solver: NonogramSolver): bool {.base.} = 
  return false
