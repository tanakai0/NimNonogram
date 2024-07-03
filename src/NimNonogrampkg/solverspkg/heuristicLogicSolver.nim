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

proc newHeuristicPreprocessingSolver*(workTable: WorkTable): HeuristicPreprocessingSolver = 
  result = HeuristicPreprocessingSolver(workTable: workTable)
  return result

proc newHeuristicPreprocessingSolver*(filePath: string): HeuristicPreprocessingSolver = 
  var wt: WorkTable = newWorkTable(filePath)
  result = HeuristicPreprocessingSolver(workTable: wt)
  return result

proc preprocessingLine*(workTable: var WorkTable, lineIndex: int, asRow: bool) = 
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
    hintNums: int = len(hint)
  for i in 0 ..< lineLength:
    states[i] = unknown
  
  # When the all cells are white
  if hint == []:
    for i in 0 ..< lineLength:
      states[i] = white
    discard workTable.updateLineStates(lineIndex, states, asRow)
    return

  # When the description just fit in the line.
  if sum(hint) + hintNums - 1 == lineLength:
    var index = 0
    for i, h in hint:
      for j in 0..<h:
        states[index] = black
        index += 1
      if i != hintNums - 1:
        states[index] = white
        index += 1
    discard workTable.updateLineStates(lineIndex, states, asRow)
    return

  # Common parts of the left packing and the right packing are blacks
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
  let z: int = lineLength - sum(hint) - hintNums + 1
  var
    ls: int = 0
    le: int = 0
    rs: int = 0
  for k in 0..<hintNums:
    if k == 0:
      ls = 0
    else:
      ls = le + 2
    le = ls + hint[k] - 1
    rs = ls + z
    for i in rs .. le:
      states[i] = black
  discard workTable.updateLineStates(lineIndex, states, asRow)
  return


method solve*(solver: HeuristicPreprocessingSolver): bool = 
  for row in 0 ..< solver.workTable.nonogram.numRows:
    preprocessingLine(solver.workTable, row, true)
  for col in 0 ..< solver.workTable.nonogram.numCols:
    preprocessingLine(solver.workTable, col, false)
  return solver.workTable.nonogram.isSolved()



# https://nim-lang.org/docs/manual.html#iterators-and-the-for-statement-firstminusclass-iterators

# def gen_enumerate_all_coloring(line, d, black, white, blank):
#     """
#     generator that returns all coloring pattern of the line considering restriction of filled cells

#     Parameters
#     ----------
#     line : list of int
#         1-dimensional list which express row or column
#     d    : list of list of int
#         description of the line
#     black : int
#         symbol of a cell that is colored black
#     white : int
#         symbol of a cell that is colored white
#     blank : int
#         symbol of a cell that is not decided yet
    
#     Yield
#     -----
#     filled_line : list of int
#         filled pattern
#     """
#     # set initial value for other function
#     ret = [blank for _ in range(len(line))]
#     yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, 0, 0, ret)
    
# def _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos, d_ind, ret):
#     """
#      generator that returns all coloring pattern of the line using recursive and restriction of filled cells

#     Parameters
#     ----------
#     line : list of int
#         1-dimensional list which express row or column
#     d    : list of list of int
#         description of the line
#     black : int
#         symbol of a cell that is colored black
#     white : int
#         symbol of a cell that is colored white
#     blank : int
#         symbol of a cell that is not decided yet
#     pos : int
#         previous position of line (or ret) (used only for recursive) 
#     d_ind : int
#         previous position of description d (used only for recursive)
#     ret : list of int
#         temporary try of left most justification (used only for recursive)
    
#     Yield
#     -----
#     filled_line : list of int
#         filled pattern
        
#     Notes
#     -----
#     abstract of steps
#     step1 : check if the solution is right and yield ret when it is a consistent pattern
#     step2 : decide the element of the description and try the all positions of the elements 
#     """
#     # print("pos:{} d_ind:{}\n ret:{}\n--------------------------".format(pos, d_ind, ret))
    
#     # set initial values for this function
#     if ret == None:
#         ret = [[blank for _ in range(len(line))]]
        
#     # when all elements of the description was adopted
#     if d_ind == len(d):
#         if blank not in ret and nonogram.Puzzle.line2description(ret, black, white, blank, focus = black) == d:
#             yield deepcopy(ret)
            
#     # when some elements of the description wasn't adopted
#     else:
#         copy_ret = deepcopy(ret)
#         # name value which occurs frequently black_range
#         black_range = pos + d[d_ind]
        
#         # if d_ind is last index
#         if d_ind == len(d) - 1:
#             # obvious inconsistent check without coloring any 
#             if black_range <= len(line):
#                 if line[pos] == black:
#                     # obvious inconsistent check without coloring any cell
#                     if (white not in line[pos + 1: black_range]) and (black not in line[black_range:]):
#                         for i in range(pos, black_range):
#                             ret[i] = black
#                         for i in range(black_range, len(line)):
#                             ret[i] = white
#                         yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos = len(line), d_ind = d_ind + 1, ret = ret)
#                 elif line[pos] == white:
#                     ret[pos] = white
#                     yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos +1 , d_ind = d_ind, ret = ret)
#                 else:
#                     # color black for now
#                     if (white not in line[pos + 1: black_range]) and (black not in line[black_range:]):
#                         for i in range(pos, black_range):
#                             ret[i] = black
#                         for i in range(black_range, len(line)):
#                             ret[i] = white
#                         yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos = len(line), d_ind = d_ind + 1, ret = ret)
#                     # if black is inconsistent, then color white now with modifying coloring
#                     for i in range(len(ret)):
#                         ret[i] = copy_ret[i]
#                     ret[pos] = white
#                     yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos + 1, d_ind = d_ind, ret = ret)
#         # if d_ind isn't last index          
#         else:
#             # obvious inconsistent check without coloring any cell
#             if pos + sum(d[d_ind:]) + len(d) - d_ind - 1 <= len(line):
#                 if line[pos] == black:
#                     # obvious inconsistent check without coloring any cell
#                     if (white not in line[pos + 1: black_range]) and (black != line[black_range]):
#                         for i in range(pos, black_range):
#                             ret[i] = black
#                         ret[black_range] = white
#                         yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos = black_range + 1, d_ind = d_ind + 1, ret = ret)
#                 elif line[pos] == white:
#                     ret[pos] = white
#                     yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos = pos + 1, d_ind = d_ind, ret = ret)
#                 else:
#                     # color black for now
#                     if (white not in line[pos + 1: black_range]) and (black != line[black_range]):
#                         for i in range(pos, black_range):
#                             ret[i] = black
#                         ret[black_range] = white
#                         yield from _rec_gen_enumerate_all_coloring(line, d, black, white, blank, pos = black_range + 1, d_ind = d_ind + 1, ret = ret)


## left_most_justification returns the left-most justigication for one line
## Example
## -------
## 0 : white, 1 : black, 2 : blank, 
## length of the line is 21 (index 0-20), d = [2,2,2,3,1] = [d0,d1,d2,d3,d4]
## 011020222022122221201  original
## 011000110001100111001  left most justification
## 
proc left_most_justification*(line: seq[CellState], hint: seq[int]): seq[CellState] = 
  var
    lineLength: int = len(line)
  if hint == []:
    for _ in 0 ..< lineLength:
      result.add(white)
      return result
#     g = gen_enumerate_all_coloring(line, d, black, white, blank)
#     # first element of g is the left-most justification
#     left_most = None
#     try:
#         left_most = g.__next__()
#     except StopIteration:  # if there isn't left-most justification
#         left_most = -1
#     g.close()
#     return left_most

