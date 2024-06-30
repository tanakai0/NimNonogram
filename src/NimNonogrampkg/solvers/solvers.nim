import ../workTable

type
  NonogramSolver* = ref object of RootObj
    workTable*: WorkTable

type
  TestNonogramSolver* = ref object of NonogramSolver
    param1*: string

proc newNonogramSolver*(workTable: WorkTable): NonogramSolver = 
  result = NonogramSolver(workTable: workTable)
  return result 

proc newTestNonogramSolver*(workTable: WorkTable, param1: string): TestNonogramSolver = 
  result = TestNonogramSolver(workTable: workTable, param1: param1)
  return result

## solve proc. starts to solve puzzle
## This proc. will be overloaded by a subclass of NonogramSolver
method solve*(solver: NonogramSolver): bool {.base.} = 
  return false

method solve*(solver: TestNonogramSolver): bool = 
  echo "solve in TestNonogramSolver"
  return true

when isMainModule:
  let wt = WorkTable()
  let solver = newTestNonogramSolver(wt, "test")
  discard solver.solve()
