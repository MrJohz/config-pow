import unittest
import typeinfo
import sets
import os

import "../configPow"

const CONFIGDIR = "tests/configs" #os.joinDirs("tests", "configs")

{.hints: off.}

suite "Sets up config class":
  setup:
    config powConfig :
      filename = string
      age = int
      defaultVal = [string, default: "hello", test: x.len < 100]
      defaultInferred = 4
      inferredWithTest = [default: 4, test: x < 54]
      boolVal = true
      noDefaultWithTest = [float, test: x >= 4.0]

  test "Has all correct attributes":

    var confClass = powConfig()

    var c = confClass.toAny()
    var children = initSet[string](8)
    for name, val in c.fields:
      children.incl(name)

    check:
      @["filename", "age", "defaultVal", "defaultInferred", "inferredWithTest", "boolVal", "noDefaultWithTest"].toSet() == children

  test "All children are correct types":

    var confClass = powConfig()

    var biggy: BiggestInt = 0
    var biggyF: BiggestFloat = 0

    var c = confClass.toAny()
    for name, val in c.fields:
      case name
      of "filename":
        assert (val.kind == akString)
      of "age":
        assert val.kind == biggy.toAny().kind
      of "defaultVal":
        assert val.kind == akString
      of "defaultInferred":
        assert val.kind == biggy.toAny().kind
      of "inferredWithTest":
        assert val.kind == biggy.toAny().kind
      of "boolVal":
        assert val.kind == akBool
      of "noDefaultWithTest":
        assert val.kind == biggyF.toAny().kind
      else:
        assert false, "Can't recognise key " & name

  test "`fromFile` works basically":

    var conf = powConfig.fromFile(CONFIGDIR & "/all_present.json") #os.joinDirs(CONFIGDIR, "all_present.json"))
    check:
      conf.filename == "f.txt"
      conf.age == 45
      conf.defaultVal == "contains 'b'"
      conf.defaultInferred == 43
      conf.inferredWithTest == 53
      conf.boolVal == false

  test "`fromString` works basically":
    
    var conf = powConfig.fromString("{\"filename\": \"f.txt\", \"age\": 45, \"noDefaultWithTest\": 5.0}")
    check:
      conf.filename == "f.txt"
      conf.age == 45

  test "Substitute default if the test fails":

    var conf = powConfig.fromFile(CONFIGDIR & "/all_with_test_failure.json")
    check:
      conf.inferredWithTest == 4

  test "Substitute default if missing values":

    var conf = powConfig.fromFile(CONFIGDIR & "/missing_default_values.json")
    check:
      conf.defaultVal == "hello"
      conf.inferredWithTest == 4

  test "Raise error if non-default argument fails a test":
    expect invalidConfError:
      var conf = powConfig.fromFile(CONFIGDIR & "/nondefault_fails_test.json")

  test "Raise error if non-default argument is missing":
    expect invalidConfError:
      var conf = powConfig.fromFile(CONFIGDIR & "/nondefault_not_present.json")





#powConfig.fromFile("filename.json")
#powConfig.fromString("{}")
#powConfig.ctFromFile("compile_opts.json")
#powConfig.ctFromString("{}")