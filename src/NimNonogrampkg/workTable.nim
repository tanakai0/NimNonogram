import times
import nonogram, coloringOrder, solvers/solvers


## WorkTable collects information to solve a puzzle.
type
  WorkTable* = object
    nonogram*: Nonogram
    startTime: float  # Start time for time measurement
    coloringOrder*: ColoringOrder
    solver*: NonogramSolver



# Function to create a new WorkTable
proc newWorkTable*(nonogram: Nonogram, solver: NonogramSolver): WorkTable =
  result.nonogram = nonogram
  result.startTime = cpuTime()
  result.coloringOrder = newColoringOrder(nonogram)
  result.solver = solver
