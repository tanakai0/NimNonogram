#[
nonogram solvers with heuristic logic
References
[1] S. Salcedo-Sanz et al. "Solving Japanese puzzles with heuristics."
Proc of the 2007 IEEE Symposium on Computational Intelligence and Games, 2007.
]#

import math
import solvers
import ../[utils, nonogram, workTable]

type
  HeuristicPreprocessingSolver* = ref object of NonogramSolver

proc newHeuristicPreprocessingSolver*(workTable: var WorkTable): HeuristicPreprocessingSolver = 
  result = HeuristicPreprocessingSolver(workTable: workTable)
  return result

proc preprocessingLine(workTable: var WorkTable, lineIndex: int, asRow: bool) = 
  var
    hint: seq[int]
    lineLength: int
  if asRow:
    hint = workTable.nonogram.rowHints[lineIndex]
    lineLength = workTable.nonogram.numCols
  else:
    hint = workTable.nonogram.colHints[lineIndex]
    lineLength = workTable.nonogram.numRows
  var
    states: seq[CellState] = newSeq[CellState](lineLength)
  
  # When the all cells are white
  if hint == []:
    for i in 0 ..< lineLength:
      states[i] = white
    discard workTable.updateLineStates(lineIndex, states, asRow)
    return

  # When the description just fit in the line.
  if sum(hint) + len(hint) - 1 == lineLength:
    var index = 0
    for i, h in hint:
      for j in 0..<h:
        states[index] = black
        index += 1
      if i != len(hint) - 1:
        states[index] = white
        index += 1
    discard workTable.updateLineStates(lineIndex, states, asRow)
    return

  # Other cases

  #     l_l, l_d = len(line), len(d)
#     z = l_l - sum(d) - l_d + 1
    
#     # z < 0 means that it is inconsistent
#     if z < 0:
#         return(-1)
    
#     new_line = line
#     ls, le, rs = 0, 0, 0
#     for k in range(l_d):
#         ls = 0 if k == 0 else le + 2
#         le = ls + d[k] - 1
#         rs = ls + z
#         for x in range(rs, le + 1):
#             new_line[x] = black
            
#     return new_line

method solve*(solver: HeuristicPreprocessingSolver): bool = 
  for row in 0 ..< solver.workTable.nonogram.numRows:
    preprocessingLine(solver.workTable, row, true)
  return solver.workTable.nonogram.isSolved()


    
#     Returns
#     -------
#     new_line : list of int, or -1
#         1-dimensional line which is filled by this function.
#         if there is an inconsistency, then return -1.
        
#     Example
#     -------
#     x:blank, 1:black
#     xxxxxxxxxxxxxxxxxxxx length of the line m = 20(index 0-19), d = [1,10,4] = [d0,d1,d2]
    
#     step1
#     1xxxxxxxxxxxxxxxxxxx left packing [1]
#     xxx1x1111111111x1111 right packing [1,10,4]
#     ls0 = 0, le0 = ls0 + d0 -1 = 0, rs0 = m - sum(d) - len(d) + 1 = 3 = z
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
#     """

        
#     l_l, l_d = len(line), len(d)
#     z = l_l - sum(d) - l_d + 1
    
#     # z < 0 means that it is inconsistent
#     if z < 0:
#         return(-1)
    
#     new_line = line
#     ls, le, rs = 0, 0, 0
#     for k in range(l_d):
#         ls = 0 if k == 0 else le + 2
#         le = ls + d[k] - 1
#         rs = ls + z
#         for x in range(rs, le + 1):
#             new_line[x] = black
            
#     return new_line
