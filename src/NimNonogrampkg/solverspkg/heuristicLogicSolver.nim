#[
nonogram solvers with heuristic logic
References
[1] S. Salcedo-Sanz et al. "Solving Japanese puzzles with heuristics."
Proc of the 2007 IEEE Symposium on Computational Intelligence and Games, 2007.
]#

import solvers
import ../[utils, nonogram, workTable]

type
  PreprocessingLogicSolver* = ref object of NonogramSolver

proc newPreprocessingLogicSolver*(workTable: WorkTable): PreprocessingLogicSolver = 
  result = PreprocessingLogicSolver(workTable: workTable)
  return result

proc preprocessingLogicRow(workTable: WorkTable, row: int) = 
  echo workTable.endTime

method solve*(solver: PreprocessingLogicSolver): bool = 
  for row in 0 ..< solver.workTable.nonogram.numRows:
    preprocessingLogicRow(solver.workTable, row)
  return solver.workTable.nonogram.isSolved()



# def preprocessing_logic(puzzle):
#     """
#     This sets obvious values for a grid, not considering colored cells.

#     Parameters
#     ----------
#     puzzle : nonogram.Puzzle
#         Target puzzle.
    
#     Returns
#     -------
#     None
#     """ 
#     for i in range(puzzle.m):
#         row, d = puzzle.copy_row(i), puzzle.get_dr(i)
#         new_row = preprocessing_logic_line(row, d, puzzle.black, puzzle.white)
#         if new_row == -1:
#             raise ValueError("dr[{}] isn't appropriate by function preprocessing_logic".format(i))
#         puzzle.set_row(i, new_row)
#     for j in range(puzzle.n):
#         col, d = puzzle.copy_col(j), puzzle.get_dc(j)
#         new_col = preprocessing_logic_line(col, d, puzzle.black, puzzle.white)
#         if new_col == -1:
#             raise ValueError("dc[{}] isn't appropriate by function preprocessing_logic".format(j))
#         puzzle.set_col(j, new_col)

        
# def preprocessing_logic_line(line, d, black, white):
#     """
#     This sets obvious values for a one line (row or colmun), not considering colored cells.

#     Parameters
#     ----------
#     line : list of int
#         1-dimensional list which express the row or column.
#     d    : list of list of int
#         Description of the line.
#     black : int
#         Symbol of a cell that is colored black.
#     white : int
#         Symbol of a cell that is colored white.
    
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
    
#     # when the all cells are white 
#     if d == []:
#         return [white for _ in range(len(line))]
    
#     # when the description only fit in line
#     if sum(d) + len(d) - 1 == len(line):
#         ret = []
#         for (i, d_i) in enumerate(d):
#             for j in range(d_i):
#                 ret.append(black)
#             if i != len(d) - 1:
#                 ret.append(white)
#         return ret
        
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
