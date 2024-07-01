import math

proc detectHintOverflow*(lineLength: int, hint: seq[int]): bool = 
  return (lineLength < sum(hint) + len(hint) - 1)
