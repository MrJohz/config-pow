import macros

type
  ConfigOption* = object of TObject
    name*: PNimrodNode
    confType*: PNimrodNode
    default*: PNimrodNode
    test*: PNimrodNode
    hasDefault*: bool

proc USERFINE(): PNimrodNode {.compileTime.} =
  return newIdentNode("true")

proc readType(opt: PNimrodNode): PNimrodNode {.compileTime.} =
  expectKind(opt, nnkIdent)
  case $opt
  of "string":
    result = newIdentNode("string")
  of "int":
    result = newIdentNode("BiggestInt")
  of "float":
    result = newIdentNode("BiggestFloat")
  of "bool":
    result = newIdentNode("bool")
  else:
    error("Type " & $opt & " not of [string, int, float, bool]")

proc inferType(opt: PNimrodNode): PNimrodNode {.compileTime.} =
  case opt.kind
  of nnkCharLit..nnkInt64Lit:
    result = newIdentNode("BiggestInt")
  of nnkFloatLit..nnkFloat64Lit:
    result = newIdentNode("BiggestFloat")
  of nnkStrLit..nnkTripleStrLit:
    result = newIdentNode("string")
  of nnkIdent:  # Can only be a bool, probably
    result = newIdentNode("bool")
  else:
    error("Unrecognised literal " & $opt)

proc setColonExpr(option: var ConfigOption; node: PNimrodNode) {.compileTime.} =
  expectKind(node, nnkExprColonExpr)
  expectKind(node[0], nnkIdent)

  case $node[0]
  of "default":
    if option.confType.kind == nnkNilLit:
      option.confType = inferType(node[1])
    assert((option.confType.ident == inferType(node[1]).ident), "Default value '" & node[1].treeRepr & " of incorrect type")
    option.default = node[1]
    option.hasDefault = true
  of "test":
    option.test = node[1]
  else:
    error("Invalid option in colonexpr: " & $node[0])

proc makeFromBracket(name: PNimrodNode, opt: PNimrodNode): ConfigOption {.compileTime.} =
  var option = ConfigOption()
  option.name = name
  option.default = newEmptyNode()
  option.hasDefault = false
  option.test = USERFINE()

  for child in opt.children():
    case child.kind
    of nnkIdent:  # type declaration
      option.confType = readType(child)
    of nnkExprColonExpr:
      setColonExpr(option, child)
    else:
      error("Option " & $name & " of invalid form")

  return option

proc makeOption*(name: PNimrodNode, opt: PNimrodNode): ConfigOption {.compileTime.} = 
  result.name = name
  result.default = newEmptyNode()
  result.hasDefault = false
  result.test = USERFINE()

  case opt.kind
  of nnkLiterals:  # This is a default value - infer type and continue
    result.confType = inferType(opt)
    result.default = opt
    result.hasDefault = true
  of nnkIdent:  # This is a type - but it might not be (need to confirm)
    if $opt == "true" or $opt == "false":
      result.confType = inferType(opt)
      result.default = opt
      result.hasDefault = true
    else:
      result.confType = readType(opt)
  of nnkBracket:
    result = makeFromBracket(name, opt)
  else:
    error("Option " & $name & " of invalid form")