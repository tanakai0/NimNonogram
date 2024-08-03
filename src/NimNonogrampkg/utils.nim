import std/strutils
import math

import constants
import nonogram

proc line2Hint*(line: seq[CellState]): seq[int] =
  var
    hint: seq[int] = @[]
    count: int = 0
    black: CellState = CellState.black
    white: CellState = CellState.white

  for cell in line:
    if cell == black:
      count += 1
    elif cell == white and count > 0:
      hint.add(count)
      count = 0

  if count > 0:
    hint.add(count)

  return hint


proc isSolved*(nono: Nonogram): bool = 
  if nono.countStateInGrid(unknown) != 0:
    return false
  for i in 0..<nono.numRows:
    if line2hint(nono.grid[i]) != nono.rowHints[i]:
      return false
  for i in 0..<nono.numCols:
    if line2hint(nono.getCol(i)) != nono.colHints[i]:
      return false
  return true


proc degreeOfFreedom*(dimension: int, hint: seq[int]): int =
  let
    k = hint.len
    b = sum(hint)
  return fac(dimension-b+1) div (fac(dimension - b + 1 - k) * fac(k))


proc grid2GoalPattern*(nono: Nonogram): string = 
  if not nono.isSolved():
    raise newException(ValueError, "The nonogram is not solved.")
  
  var goalPattern = ""
  
  for row in nono.grid:
    for cell in row:
      case cell
      of black:
        goalPattern.add($constants.BlackSymbol)
      of white:
        goalPattern.add($constants.WhiteSymbol)
      of unknown:
        goalPattern.add($constants.UnknownSymbol)
  
  return goalPattern


proc loadGoalFromDB*(filePath: string): string =
  var
    f: File
    line: string
  # Open and read the file
  try:
    f = open(filePath, FileMode.fmRead)
  except :
    echo "cannot open file"

  while f.endOfFile == false :
    line = strip(f.readLine())
    if line == "":
      continue
    if line.startsWith("goal"):
      # Extract and return the goal string
      return (line.split(' ', 2)[1]).strip(chars = {'\"'})

  # If the goal pattern is not found, raise an exception
  raise newException(ValueError, "Goal pattern not found in the file.")
