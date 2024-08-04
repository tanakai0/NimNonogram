#[
Nonogram solver using backtracking
]#

import solvers, heuristicLogicSolver
import ../[utils, nonogram, workTable, coloringLog]

type BacktrackingHeuristicLogicSolver* = ref object of NonogramSolver

proc newBacktrackingHeuristicLogicSolver*(workTable: WorkTable): BacktrackingHeuristicLogicSolver = 
  result = BacktrackingHeuristicLogicSolver(workTable: workTable)
  return result

proc newBacktrackingHeuristicLogicSolver*(filePath: string): BacktrackingHeuristicLogicSolver = 
  var wt: WorkTable = newWorkTable(filePath)
  result = BacktrackingHeuristicLogicSolver(workTable: wt)
  return result


method solve*(solver: BacktrackingHeuristicLogicSolver): bool = 
  echo "test"
  return solver.workTable.nonogram.isSolved()


when isMainModule:
  echo "Use case 1"
