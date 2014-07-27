import nake
import os

const
  ROOT_TEST_DIR = "tests"
  TESTFILES = ["test_config.nim", "test_scoping.nim"]

task "test", "Run unittests":
  for testf in TESTFILES:
    shell("nimrod", "c", "--verbosity:0", "-r", os.joinPath(ROOT_TEST_DIR, testf))