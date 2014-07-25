import tables
import macros

import "lib/options"
import "lib/construction"
#import "lib/runtimeoptions"

import "lib/errors"
export errors.invalidConfError

macro config*(name: expr, body: stmt): stmt {.immediate.} =
  var optionTable = initTable[string, ConfigOption]()

  for child in body.children():
    expectKind(child, nnkAsgn)
    expectLen(child, 2)

    optionTable[ $child[0] ] = makeOption(child[0], child[1])

  #var runtimeOpts = convertOptions(name, optionTable)

  result = newStmtList()
  result.add(constructType(name, optionTable))
  result.add(constructFromRuntime(name, optionTable, makeFromFile=true))
  result.add(constructFromRuntime(name, optionTable, makeFromFile=false))

#proc fromFile*[T](supTyp: typedesc[T], filename: string): T =
#  return T()