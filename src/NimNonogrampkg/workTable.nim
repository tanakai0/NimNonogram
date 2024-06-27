import times
import nonogram, coloringLog, solvers/solvers


## WorkTable collects information to solve a puzzle.
type
  WorkTable* = object
    nonogram*: Nonogram
    startTime: float  # Start time for time measurement
    endTime: float  # End time for time measurement
    coloringLog*: ColoringLog
    solver*: NonogramSolver

# Function to create a new WorkTable
proc newWorkTable*(nonogram: Nonogram, solver: NonogramSolver): WorkTable =
  result.nonogram = nonogram
  result.startTime = cpuTime()
  result.coloringLog = newColoringLog(nonogram)
  result.solver = solver
  return result

# stopTime measures the elapsed time
proc stopTimer*(workTable: var WorkTable) =
  workTable.endTime = cpuTime() - workTable.startTime
