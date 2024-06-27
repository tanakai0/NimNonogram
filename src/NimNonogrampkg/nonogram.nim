import std/strutils
import math

## CellState represents the state of a cell in the Nonogram puzzle.
type
  CellState* = enum
    white = 0  # The cell is white (empty).
    black = 1  # The cell is black (filled).
    unknown = 2  # The cell's state is not yet determined.

## Nonogram represents the Nonogram puzzle.
type
  Nonogram* = object
    numRows: int  # Number of rows
    numCols: int  # Number of colmuns
    grid*: seq[seq[CellState]]  # Matrix of puzzle
    rowHints: seq[seq[int]]    # Hints of rows
    colHints: seq[seq[int]]  # Hints of colmuns

#" getters for hide values
proc numRows*(n: Nonogram): int {.inline.} =
  n.numRows
proc numCols*(n: Nonogram): int {.inline.} =
  n.numCols
proc rowHints*(n: Nonogram): seq[seq[int]] {.inline.} =
  n.rowHints
proc colHints*(n: Nonogram): seq[seq[int]] {.inline.} =
  n.colHints

proc setCellState*(nonogram: var Nonogram, row: int, col: int, state: CellState): bool = 
  if nonogram.grid[row][col] == unknown:
    nonogram.grid[row][col] = state
    return true
  else:
    return false


proc checkMinimalHints*(nono: Nonogram): bool =
  if nono.rowHints.len != nono.numRows or nono.colHints.len != nono.numCols:
    raise newException(ValueError, "len(rowHints) != numRows or len(colHints) != numCols")
  
  # Check obvious contradiction about length of elements
  for hint in nono.rowHints:
    if sum(hint) + len(hint) - 1 > nono.numCols:
      raise newException(ValueError, "Contradiction about row description!")
  
  for hint in nono.colHints:
    if sum(hint) + len(hint) - 1 > nono.numRows:
      raise newException(ValueError, "Contradiction about column description!")
  
  return true


## newNonogram creates a new Nonogram with the specified number of rows and columns.
##
## Parameters:
## - `numRows`: The number of rows in the puzzle.
## - `numCols`: The number of columns in the puzzle.
## - `rowHints`: The hints for each row.
## - `colHints`: The hints for each column.
##
## Returns:
## A new Nonogram object initialized with the specified dimensions.
proc newNonogram*(numRows: int, numCols: int, rowHints: seq[seq[int]], colHints: seq[seq[int]]): Nonogram =
  result.numRows = numRows
  result.numCols = numCols
  result.rowHints = rowHints
  result.colHints = colHints
  discard checkMinimalHints(result)
  result.grid = newSeqOfCap[seq[CellState]](numRows)
  for i in 0..<numRows:
    result.grid.add(newSeqOfCap[CellState](numCols))
    for j in 0..<numCols:
      result.grid[i].add(CellState.unknown)
  return result

## parseHintLine parses the string to make a hint in a line
proc parseHintLine(line: string): seq[int] =
  var hints: seq[int] = @[]
  for hint in line.split(','):
    var number = parseInt(hint)
    hints.add(number)
  if hints == @[0]:
    return @[]
  else:
    return hints

## loadPuzzle makes Nonogram instance from a .non data file
proc loadPuzzle*(filePath: string): Nonogram =
  var 
    n: Nonogram
    numRows: int
    numCols: int
    rowHints: seq[seq[int]]
    colHints: seq[seq[int]]
    line: string
    inRows: bool = false
    inCols: bool = false
    f : File
  try:
    f = open(filePath, FileMode.fmRead)
  except :
    echo "cannot open file"
  while f.endOfFile == false :
    line = strip(f.readLine())
    if line == "":
      continue
    if line.startsWith("width"):
      numCols = parseInt(line.split(' ')[1])
    elif line.startsWith("height"):
      numRows = parseInt(line.split(' ')[1])
    elif line == "rows":
      inRows = true
      inCols = false
    elif line == "columns":
      inRows = false
      inCols = true
    elif line.contains("goal"):
      break
    elif inRows:
      rowHints.add(parseHintLine(line))
    elif inCols:
      colHints.add(parseHintLine(line))
  n = newNonogram(numRows, numCols, rowHints, colHints)
  discard checkMinimalHints(result)
  return n


## Converts the Nonogram object to a string representation.
##
## Returns:
## A string representing the Nonogram.
proc toString*(n: Nonogram): string =
  result = "Nonogram(rows: " & $n.numRows & ", columns: " & $n.numCols & ")\n"
  for row in n.grid:
    for cell in row:
      case cell
      of CellState.white: result.add("0 ")
      of CellState.black: result.add("1 ")
      of CellState.unknown: result.add("2 ")
    result.add("\n")
  return result

proc rendering*(n: Nonogram): string =
  result = "Nonogram(rows: " & $n.numRows & ", columns: " & $n.numCols & ")\n"
  for row in n.grid:
    for cell in row:
      case cell
      of CellState.white: result.add("\u{2591}\u{2591}")
      of CellState.black: result.add("\u{2593}\u{2593}")
      of CellState.unknown: result.add("  ")
    result.add("\n")
  return result

## countStateInRow counts the number of specific state in a row.
proc countStateInRow*(n: Nonogram, state: CellState, i : int): int = 
  for cell in n.grid[i]:
    if cell == state:
      result += 1
  return result

## countStateInRow counts the number of specific state in a column.
proc countStateInColumn*(n: Nonogram, state: CellState, j : int): int = 
  for i in 0..<n.numRows:
    if n.grid[i][j] == state:
      result += 1
  return result

## countStateInGrid counts the number of specific state in a grid.
proc countStateInGrid*(n: Nonogram, state: CellState): int = 
  for i in 0..<n.numRows:
    for j in 0..<n.numCols:
      if n.grid[i][j] == state:
        result += 1
  return result

proc getCol*(grid: seq[seq[CellState]], col: int): seq[CellState] =
  result = newSeqOfCap[CellState](grid.len)
  for row in grid:
    result.add(row[col])


when isMainModule:
  import constants
  var
    non: Nonogram = loadPuzzle(constants.ExamplePuzzlePath)
  echo non.numRows
  echo non.numCols
  echo non.rowHints
  echo non.colHints
