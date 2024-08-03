#[
nonogram solvers with heuristic logic
References
[1] S. Salcedo-Sanz et al. "Solving Japanese puzzles with heuristics."
Proc of the 2007 IEEE Symposium on Computational Intelligence and Games, 2007.
]#

import std/[algorithm, macros]
import math
import solvers
import ../[utils, nonogram, workTable, coloringLog]

type
  HeuristicPreprocessingSolver* = ref object of NonogramSolver
  HeuristicLogicSolver* = ref object of NonogramSolver

proc newHeuristicPreprocessingSolver*(workTable: WorkTable): HeuristicPreprocessingSolver = 
  result = HeuristicPreprocessingSolver(workTable: workTable)
  return result

proc newHeuristicPreprocessingSolver*(filePath: string): HeuristicPreprocessingSolver = 
  var wt: WorkTable = newWorkTable(filePath)
  result = HeuristicPreprocessingSolver(workTable: wt)
  return result

proc newHeuristicLogicSolver*(workTable: WorkTable): HeuristicLogicSolver = 
  result = HeuristicLogicSolver(workTable: workTable)
  return result

proc newHeuristicLogicSolver*(filePath: string): HeuristicLogicSolver = 
  var wt: WorkTable = newWorkTable(filePath)
  result = HeuristicLogicSolver(workTable: wt)
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

## enumerateAndFillConsensusColors enumerates all coloring patterns for the line and colors cells which have the same color among all patterns.
proc enumerateAndFillConsensusColors*(line: seq[CellState], hint: seq[int]): seq[CellState] = 
  var
    lineLength: int = len(line)
  for i in 0 ..< lineLength:
    result.add(unknown)
  var contradictions: seq[bool] = newSeq[bool](lineLength)
  for pattern in enumerateAllColoring(line, hint):
    for i in 0 ..< lineLength:
      if not contradictions[i]:
        if (result[i] == unknown):
          result[i] = pattern[i]
        elif (result[i] != unknown) and (result[i] != pattern[i]):
          contradictions[i] = true
          result[i] = unknown
  return result


## nameSections assigns each cell a number corresponding to its section.
## Sections are consecutive cells which have the same color.
## The first white section is named 0. The second white section is named 2. The third white sectuib is named 4, ... .
## The first black section is named 1. The second black section is named 3. The third black section is named 5, ... .
## Note that the section #0 does not exist when the most left cell is colored in black.
## For example,
## 0010100 -> 0012344
## 1100111 -> 1122333 (0 is disappeared).
proc nameSections*(line: seq[CellState]): seq[int] = 
  var
    number: int
    color: CellState

  # If the line is empty, then return the empty list.
  if line == @[]:
    return result
  
  if line[0] == white:
    number = 0
  else:
    number = 1
  color = line[0]

  for c in line:
    if c != color:
      color = c
      inc(number)
    result.add(number)
  
  return result

## sectionMatch colors the cells that have the same section number between left-most justification and right-most justificatoin
## Example
## 0: white, 1: black, x : unknown
## lineLength = 21 (index 0-20), hint = [2, 2, 2, 3, 1]
## 0 1 1 0 x 0 x x x 0 x x 1 x x x x 1 x 0 1  original
## 0 1 1 2 2 2 3 3 4 4 4 5 5 6 6 7 7 7 8 8 9  section numbers of the left-most justification
## 0 1 1 2 2 2 2 3 3 4 4 4 5 5 6 6 7 7 7 8 9  section numbers of the right-most justification
## 0 1 1 0 0 0 x 1 x 0 0 x 1 x 0 x 1 1 x 0 1  result
##         ^     ^     ^       ^   ^          cells filled by this method
proc sectionMatch*(line: seq[CellState], hint: seq[int], leftSections: seq[int], rightSections: seq[int]): seq[CellState] = 
  for i in 0 ..< len(line):
    if leftSections[i] == rightSections[i]:
      if leftSections[i] mod 2 == 0:
        result.add(white)
      else:
        result.add(black)
    else:
      result.add(line[i])
  return result

## sectionNearBoundaries colors cells in black near (black, white) or (white, black) boundaries
## Example
## 0: white, 1: black, x : unknown
## lineLength = 26 (index 0-25), hint = [2, 3, 2, 3, 1, 1] = [h0, h1, h2, h3, h4, h5]
## 0 1 1 0 x x x x x x x 0 1 x x x x 1  x  x  x  x  0  x  0  1  original
## 0 1 1 2 3 3 3 4 5 5 6 6 7 7 7 8 8 9 10 10 10 10 10 10 10 11  section numbers of the left-most justification
## 0 1 1 2 2 2 2 2 2 2 2 2 3 3 3 4 5 5  6  7  7  7  8  9 10 11  section numbers of the right-most justification
## 0 1 1 0 x x x x x x x 0 1 1 x x x 1  x  x  x  x  0  x  0  1  result
##                       ^ ^  This is a (0, 1) boundary
## (the number of colored cells) = min(h1(= section #3), h2(= section #5), h3(= section #7)) = min(3, 2, 3) = 2
proc sectionNearBoundaries*(line: seq[CellState], hint: seq[int], leftSections: seq[int], rightSections: seq[int]): seq[CellState] = 
  let
    lineLength: int = len(line)
  var
    # bwBoundaries contains black positions in the boundary (black, white).
    # For example, 0 1 x 1 0 x x 0 1 x 0 x x x 1 0 1 -> [3, 14]
    # wbBoondaries contains black positions in the boundary (white, black).
    # For example, 0 1 x 1 0 x x 0 1 x 0 x x x 1 0 1 -> [1, 8, 16]
    bwBoundaries: seq[int]
    wbBoundaries: seq[int]
  result = line
  for i in 0 ..< lineLength - 1:
    if (line[i] == black) and (line[i+1] == white):
      bwBoundaries.add(i)
  for i in 1 ..< lineLength:
    if (line[i-1] == white) and (line[i] == black):
      wbBoundaries.add(i)
  
  for b in bwBoundaries:
    for i in 1 ..< min(hint[(rightSections[b] div 2) ..< (leftSections[b] div 2) + 1]):
      result[b-i] = black
  for b in wbBoundaries:
    for i in 1 ..< min(hint[(rightSections[b] div 2) ..< (leftSections[b] div 2) + 1]):
      result[b+i] = black
  
  return result


## sectionConsecutiveUnknowns colors some consecutive unknown cells in white.
## 0: white, 1: black, x : unknown
## lineLength = 29 (index 0-28), hint = [2, 1, 2, 2, 2, 2, 1] = [h0, h1, h2, h3, h4, h5]
## 1 1 0 x 0 x x x x x x x 1  0  x  0  x  0  x  x  x  x  x  x  x  x  0  1  0  original
## 1 1 2 3 4 5 5 6 7 7 8 9 9 10 10 10 10 10 11 11 12 12 12 12 12 12 12 13 14  section numbers of the left-most justification
## 1 1 2 2 2 2 2 2 2 3 4 5 5  6  6  6  6  6  7  7  8  9  9 10 11 11 12 13 14  section numbers of the right-most justification
## 1 1 0 x 0 x x x x x x x 1  0  0  0  0  0  x  x  x  x  x  x  x  x  0  1  0  result
##                               ^     ^   Two cells are colored in white
proc sectionConsecutiveUnknowns*(line: seq[CellState], hint: seq[int], leftSections: seq[int], rightSections: seq[int]): seq[CellState] = 
  # wuw is the list of information about consecutive unknowns with white at both sides of the part
  # The element of wuw is (index of the left white cell, index of the right white cell, length of the consecutive unknowns)
  # For the above example, wuw = [(2, 4, 1), (13, 15, 1), (15, 17, 1), (17, 26, 8)]
  type UnknownsBetweenWhites = tuple
    leftWhiteIndex: int
    rightWhiteIndex: int
    unknownLength: int
  var
    wuw: seq[UnknownsBetweenWhites]
    whiteIndexes: seq[int]
    leftWhiteIndex: int
    rightWhiteIndex: int
    length: int
    hl: int
    hr: int
  result = line
  for i in 0 ..< len(line):
    if line[i] == white:
      whiteIndexes.add(i)
  for i in 0 ..< len(whiteIndexes) - 1:
    leftWhiteIndex = whiteIndexes[i]
    rightWhiteIndex = whiteIndexes[i+1]
    length = rightWhiteIndex - leftWhiteIndex - 1
    if (not line[leftWhiteIndex + 1 ..< rightWhiteIndex].contains(black)) and (length >= 1):
      wuw.add((leftWhiteIndex: leftWhiteIndex, rightWhiteIndex: rightWhiteIndex, unknownLength: length))
  for u in wuw:
    # hl : the index of the hint located immediately left of the consecutive unknown cells, nearest to those unknowns when applying right-most justification.
    # hr : the index of the hint located immediately right of the consecutive unknown cells, nearest to those unknowns when applying left-most justification.
    # Note that the k-th hint hk corresponds with the section #(2k+1).
    # Example
    # 1 1 0 x 0 x x x x x x x 1  0  x  0  x  0  x  x  x  x  x  x  x  x  0  1  0  original
    #       ^                       ^     ^     ^  ^  ^  ^  ^  ^  ^  ^
    #     wuw[0]                  wuw[1] wuw[2]          wuw[3]
    # 1 1 2 3 4 5 5 6 7 7 8 9 9 10 10 10 10 10 11 11 12 12 12 12 12 12 12 13 14  section numbers of the left-most justification
    #           ^ ^                             ^  ^                       ^
    #           hr=2                            hr=5                     hr=6
    # 1 1 2 2 2 2 2 2 2 3 4 5 5  6  6  6  6  6  7  7  8  9  9 10 11 11 12 13 14  section numbers of the right-most justification
    # ^ ^                   ^ ^                                   
    # hl=0                  hl=2
    # wuw[0]=( 2, 4,1), hl = 0 (#1), hr = 2 (#5)
    # wuw[1]=(13,15,1), hl = 2 (#5), hr = 5 (#11)
    # wuw[2]=(15,17,1), hl = 2 (#5), hr = 5 (#11)
    # wuw[3]=(17,26,8), hl = 2 (#5), hr = 6 (#13)
    # If original[27] == x, wuw contains (26,28,1). hl = 6 (#13), hr = 7 (#15), but this does not exist!
    # If the length of consecutive unknowns < min(hl+1, hl+2, ..., hr-2, hr-1), then the unkowns can be colored in white
    hl = (rightSections[u.leftWhiteIndex] - 1) div 2
    hr = (leftSections[u.rightWhiteIndex] + 1) div 2
    if (hr - hl) >= 2:
      if u.unknownLength < min(hint[hl+1 ..< hr]):
        for i in u.leftWhiteIndex + 1 ..< u.rightWhiteIndex:
          result[i] = white
  return result


## sectionMethods use the three sub procedures that use the left-most justification and right-most justification
## The three sub procedures are;
## 1: sectionMatch,
## 2: sectionNearBoundaries, and
## 3: sectionConsecutiveUnknowns.
proc sectionMethods*(line: seq[CellState], hint: seq[int]): seq[CellState] = 
  let
    lmj: seq[CellState] = leftMostJustification(line, hint)
    rmj: seq[CellState] = rightMostJustification(line, hint)
    lsec: seq[int] = nameSections(lmj)
    rsec: seq[int] = nameSections(rmj)
  
  # If there are not any justification patterns, then return the empty list.
  if (lmj == @[]) or (rmj == @[]):
    return result

  result = sectionMatch(line, hint, lsec, rsec)
  result = sectionNearBoundaries(result, hint, lsec, rsec)
  result = sectionConsecutiveUnknowns(result, hint, lsec, rsec)

  return result


## selectCellToFill propose a cell index to fill.
proc selectCellToFill*(nono: Nonogram, rowIndicesToCheck: set[int16], colIndicesToCheck: set[int16]): (int, bool) = 
  var
    maxUnknownNum: int = 0
    lineUnknownNum: int
    asRow: bool = false
    lineIndex: int = -1

  for row in rowIndicesToCheck:
    lineUnknownNum = nono.countStateInRow(unknown, row)
    if maxUnknownNum < lineUnknownNum:
      asRow = true
      lineIndex = row
      maxUnknownNum = lineUnknownNum
  for col in colIndicesToCheck:
    lineUnknownNum = nono.countStateInCol(unknown, col)
    if maxUnknownNum < lineUnknownNum:
      asRow = false
      lineIndex = col
      maxUnknownNum = lineUnknownNum

  return (lineIndex, asRow)

## solve procedures for a HeuristicLogicSolver type.
## This applies logistic ad hoc heuristic methods until this cannot color any cells.
method solve*(solver: HeuristicLogicSolver): bool = 
  var
    rowIndicesToCheck: set[int16] = {}
    colIndicesToCheck: set[int16] = {}
    lineIndex: int
    asRow: bool
    updatedLine: seq[CellState]
    updatedNum: int
  
  for row in 0 ..< solver.workTable.nonogram.numRows:
    if solver.workTable.nonogram.countStateInRow(unknown, row) != 0:
      rowIndicesToCheck.incl(int16(row))
  for col in 0 ..< solver.workTable.nonogram.numCols:
    if solver.workTable.nonogram.countStateInCol(unknown, col) != 0:
      colIndicesToCheck.incl(int16(col))
  
  while (rowIndicesToCheck != {}) or (colIndicesToCheck != {}):
    echo "rowIndicesToCheck: ", rowIndicesToCheck, "\ncolIndicesToCheck: ", colIndicesToCheck
    (lineIndex, asRow) = selectCellToFill(solver.workTable.nonogram, rowIndicesToCheck, colIndicesToCheck)
    echo "lineIndex: ", lineIndex, "\nasRow: ", asRow
    updatedLine = sectionMethods(solver.workTable.nonogram.getLine(lineIndex, asRow),
                                 solver.workTable.nonogram.lineHint(lineIndex, asRow))
    updatedLine = enumerateAndFillConsensusColors(updatedLine, 
                                                  solver.workTable.nonogram.lineHint(lineIndex, asRow))
    updatedNum = solver.workTable.updateLineStates(lineIndex, updatedLine, asRow)

    if asRow:
      rowIndicesToCheck.excl(int16(lineIndex))
      for (row, col, color) in solver.workTable.coloringLog.getLastN(updatedNum):
        if solver.workTable.nonogram.countStateInCol(unknown, col) == 0:
          colIndicesToCheck.excl(int16(col))
        else:
          colIndicesToCheck.incl(int16(col))
    else:
      colIndicesToCheck.excl(int16(lineIndex))
      for (row, col, color) in solver.workTable.coloringLog.getLastN(updatedNum):
        if solver.workTable.nonogram.countStateInRow(unknown, row) == 0:
          rowIndicesToCheck.excl(int16(row))
        else:
          rowIndicesToCheck.incl(int16(row))
  return solver.workTable.nonogram.isSolved()


when isMainModule:
  echo "Use case 1"
  let allColoring = enumerateAllColoring(@[black, unknown, unknown, black, unknown, unknown, unknown], @[1, 2, 1])
  for x in allColoring():
    echo x

  echo "Use case 2"
  for x in enumerateAllColoring(@[unknown, unknown, unknown, unknown, unknown, unknown, unknown], @[1, 1, 1]):
    echo x

  echo "Use case 3"
  let allColoring2 = enumerateAllColoring(@[unknown, unknown, unknown, black, unknown, black, unknown, unknown, unknown, unknown], @[3, 3])
  for x in allColoring2():
    echo x
  echo enumerateAndFillConsensusColors(@[unknown, unknown, unknown, black, unknown, black, unknown, unknown, unknown, unknown], @[3, 3])

  echo "Use case 4"
  echo nameSections(@[white, white, black, white, black, white, white])
  echo nameSections(@[black, black, white, white, black, black, black])

  echo "temp"
  import ../constants
  var solver1: HeuristicPreprocessingSolver = newHeuristicPreprocessingSolver(constants.ExamplePuzzlePath)
  discard solver1.solve()
  echo solver1.workTable.nonogram.toString()
  var solver2: HeuristicLogicSolver = newHeuristicLogicSolver(solver1.workTable)
  discard solver2.solve()
  echo solver2.workTable.nonogram.toString()
