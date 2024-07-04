#[
nonogram solvers with heuristic logic
References
[1] S. Salcedo-Sanz et al. "Solving Japanese puzzles with heuristics."
Proc of the 2007 IEEE Symposium on Computational Intelligence and Games, 2007.
]#

import std/[algorithm, macros]
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



# Ref: https://nim-lang.org/docs/manual.html#iterators-and-the-for-statement-firstminusclass-iterators
macro toIterator(x: ForLoopStmt): untyped =
  let expr = x[0]
  let call = x[1][1] # Get foo out of toItr(foo)
  let body = x[2]
  result = quote do:
    block:
      let itr = `call`
      for `expr` in itr():
          `body`

## enumerateAllColoring enumerates all coloring pattern in the line considering the hint using recursive
## line : seq[CellState]
## hint : seq[int]
## pos : int
##   Position of the line (used only for recursive) 
## hintIndex : int
##   Index of the hint (used only for recursive)
## pastLine : seq[int]
##   Temporary coloring (used only for recursive)

proc enumerateAllColoring*(line: seq[CellState], hint: seq[int], pos: int = 0, hintIndex: int = 0, pastLine: seq[CellState] = @[]): iterator (): seq[CellState] =
  result = iterator (): seq[CellState] =

    ## Initialization
    var
      tempLine: seq[CellState] = @[]
      lineLength: int = len(line)
    if pastLine == @[]:
      for _ in 0 ..< lineLength:
        tempLine.add(CellState.unknown)
    else:
      tempLine = pastLine
    # echo "pos = ", pos, " hintIndex = ", hintIndex, " tempLine = ", tempLine
    
    # When all elements of the hint was adopted.
    if hintIndex == len(hint):
      # If the solution is valid, then yield it.
      if (not templine.contains(unknown)) and (utils.line2hint(tempLine) == hint):
        yield tempLine
        
    # When some elements of the description wasn't adopted.
    else:
      var
        copiedTempLine: seq[CellState] = tempLine
        blackRange: int = pos + hint[hintIndex]
      
      # If hintIndex is the last index of the hint.
      if hintIndex == len(hint) - 1:
        # Obvious inconsistent check without coloring any cell
        if blackRange <= lineLength:
          if line[pos] == black:
            # Obvious inconsistent check without coloring any cell
            if (not line[pos + 1 ..< blackRange].contains(white)) and (not line[blackRange .. ^1].contains(black)):
              for i in pos ..< blackRange:
                tempLine[i] = black
              for i in blackRange ..< lineLength:
                tempLine[i] = white
              for e in toIterator(enumerateAllColoring(line, hint, lineLength, hintIndex + 1, tempLine)):
                yield e
          elif line[pos] == white:
            tempLine[pos] = white
            for e in toIterator(enumerateAllColoring(line, hint, pos + 1, hintIndex, tempLine)):
              yield e
          elif line[pos] == unknown:
            # try to color the cell in black color.
            if (not line[pos + 1 ..< blackRange].contains(white)) and (not line[blackRange .. ^1].contains(black)):
              for i in pos ..< blackRange:
                tempLine[i] = black
              for i in blackRange ..< lineLength:
                tempLine[i] = white
              for e in toIterator(enumerateAllColoring(line, hint, lineLength, hintIndex + 1, tempLine)):
                yield e
            # If the black color is inconsistent, then color the cell in white color
            tempLine = copiedTempLine
            tempLine[pos] = white
            for e in toIterator(enumerateAllColoring(line, hint, pos + 1, hintIndex, tempLine)):
              yield e
      else:  # If hintIndex is not the last index of the hint.
        # Obvious inconsistent check without coloring any cell
        if pos + sum(hint[hintIndex .. ^1]) + len(hint) - hintIndex - 1 <= lineLength:
          if line[pos] == black:
            # Obvious inconsistent check without coloring any cell
            if (not line[pos + 1 ..< blackRange].contains(white)) and (line[blackRange] != black):
              for i in pos ..< blackRange:
                tempLine[i] = black
              tempLine[blackRange] = white
              for e in toIterator(enumerateAllColoring(line, hint, blackRange + 1, hintIndex + 1, tempLine)):
                yield e
          elif line[pos] == white:
            tempLine[pos] = white
            for e in toIterator(enumerateAllColoring(line, hint, pos + 1, hintIndex, tempLine)):
                yield e
          elif line[pos] == unknown:
            # try to color the cell in black color.
            if (not line[pos + 1 ..< blackRange].contains(white)) and (line[blackRange] != black):
              for i in pos ..< blackRange:
                tempLine[i] = black
              tempLine[blackRange] = white
              for e in toIterator(enumerateAllColoring(line, hint, blackRange + 1, hintIndex + 1, tempLine)):
                yield e
            # If the black color is inconsistent, then color the cell in white color
            tempLine = copiedTempLine
            tempLine[pos] = white
            for e in toIterator(enumerateAllColoring(line, hint, pos + 1, hintIndex, tempLine)):
              yield e
      tempLine = copiedTempLine


iterator enumerateAllColoring*(line: seq[CellState], hint: seq[int]): seq[CellState] {.closure.} = 
  for x in toIterator(enumerateAllColoring(line, hint)):
    yield x

## left_most_justification returns the left-most justigication for one line
## Example
## -------
## 0 : white, 1 : black, 2 : blank, 
## length of the line is 21 (index 0-20), d = [2,2,2,3,1] = [d0,d1,d2,d3,d4]
## 011020222022122221201  original
## 011000110001100111001  left most justification
## 
proc leftMostJustification*(line: seq[CellState], hint: seq[int]): seq[CellState] = 
  if hint == []:
    for _ in 0 ..< len(line):
      result.add(white)
      return result
  else:
    let allColoring = enumerateAllColoring(line, hint)
    # The first element of allColoring is the left-most justification.
    # If there is not the left-most justification, the return the empty list (that equals with the initialized output type of the iterator).
    return allColoring()

proc rightMostJustification*(line: seq[CellState], hint: seq[int]): seq[CellState] = 
  if hint == []:
    for _ in 0 ..< len(line):
      result.add(white)
      return result
  else:
    let allColoring = enumerateAllColoring(reversed(line), reversed(hint))
    # The first element of allColoring is the right-most justification.
    # If there is not the right-most justification, the return the empty list (that equals with the initialized output type of the iterator).
    return reversed(allColoring())


when isMainModule:
  echo "Use case 1"
  let allColoring = enumerateAllColoring(@[black, unknown, unknown, black, unknown, unknown, unknown], @[1, 2, 1])
  for x in allColoring():
    echo x

  echo "Use case 2"
  for x in enumerateAllColoring(@[black, unknown, unknown, black, unknown, unknown, unknown], @[1, 2, 1]):
    echo x
