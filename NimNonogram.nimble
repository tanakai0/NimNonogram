# Package

version       = "0.1.0"
author        = "tanakai0"
description   = "Nonogram solver"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["NimNonogram"]


# Dependencies

requires "nim >= 2.0.4"

# tasks
# `nimble tasks`

# `nimble task CLIsolve`
task CLIsolve, "This is a test of CLI":
  exec ".\\NimNonogram.exe --solve:db/example.non"
