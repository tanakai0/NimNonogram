import std/[sequtils, strutils, os]
import types
import constants

proc parseHintLine(line: string): seq[int] =
  var hints: seq[int] = @[]
  for hint in line.split(','):
    let number = parseInt(hint[0..^1])
    hints.add(number)
  return hints

proc loadPuzzle*(filePath: string): Nonogram =
  var n: Nonogram
  var line: string
  var inRows: bool = false
  var inCols: bool = false
  var f : File
  try:
    f = open(filePath, FileMode.fmRead)
  except :
    echo "cannot open file"
  while f.endOfFile == false :
    line = strip(f.readLine())
    echo line
    if line.startsWith("width"):
      n.numCols = parseInt(line.split(' ')[1])
    elif line.startsWith("height"):
      n.numRows = parseInt(line.split(' ')[1])
    # elif line == "rows":
    #   inRows = true
    #   inCols = false
    #   n.rowHints = @[]
    # elif line == "columns":
    #   inRows = false
    #   inCols = true
    #   n.colHints = @[]
    # elif line == "goal":
    #   break  # goal 以降は無視する
    # elif inRows:
    #   n.rowHints.add(parseHintLine(line))
    # elif inCols:
    #   n.colHints.add(parseHintLine(line))

#   n.grid = newSeqOfCap[seq[CellState]](n.numRows)
#   for i in 0..<n.numRows:
#     n.grid.add(newSeqOfCap[CellState](n.numCols))
#     for j in 0..<n.numCols:
#       n.grid[i].add(CellState.unknown)

  return n

when isMainModule:
  var
    non: Nonogram = loadPuzzle(ExamplePuzzlePath)
