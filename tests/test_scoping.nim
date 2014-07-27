import unittest
import typeinfo
import os

import "../configPow"

const CONFIGDIR = os.joinPath("tests", "configs")

{.hints: off.}

suite "Sets up config class":
  setup:
    proc testInt(x): bool =
      return x < 100

    config powConfig :
      inferredWithTest = [default: 4, test: testInt(x)]

  test "Scoping default doesn't break":
    
    var conf = powConfig.fromFile(os.joinPath(CONFIGDIR, "scope_default.json"))

    check:
      conf.inferredWithTest == 34

  test "Scoping default works":

    var conf = powConfig.fromFile(os.joinPath(CONFIGDIR, "scope_nodefault.json"))

    check:
      conf.inferredWithTest == 4