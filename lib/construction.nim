import tables
import macros
import json

import "./options"
import "./errors"

proc constructType*(name: PNimrodNode, options: TTable): PNimrodNode {.compileTime.} =

  result = newNimNode(nnkTypeSection)
  var typedef = newNimNode(nnkTypeDef)
  var obj = newNimNode(nnkObjectTy)

  var params = newNimNode(nnkRecList)

  for key, option in options.pairs():
    var ident = newNimNode(nnkIdentDefs)
    ident.add(postFix(ident(key), "*"))
    ident.add(option.confType)
    ident.add(newEmptyNode())

    params.add(ident)

  obj.add(newEmptyNode(), newEmptyNode(), params)
  typedef.add(name, newEmptyNode(), obj)
  result.add(typedef)


proc constructFromRuntime*(name: PNimrodNode, options: TTable, makeFromFile=true): PNimrodNode {.compileTime.} =

  proc jsonFileParse(file:string): PJsonNode =
    return json.parseFile(file)

  proc jsonJsonParse(text:string): PJsonNode =
    return json.parseJson(text)

  proc jsonGetFrom(jsn: PJsonNode, name: string): PJsonNode =
    result = `[]`(jsn, name)

  proc jsonCompare(jsn: PJsonNode, strKind: string): bool =

    case strKind
    of "string":
      return jsn.kind == json.JString
    of "int":
      return jsn.kind == json.JInt
    of "float":
      return jsn.kind == json.JFloat
    of "bool":
      return jsn.kind == json.JBool
  
  var jsParse = if makeFromFile: bindSym"jsonFileParse" else: bindSym"jsonJsonParse"
  var jsGet = bindSym"jsonGetFrom"
  var jsComp = bindSym"jsonCompare"
  
  var prc = parseStmt"""
    proc fromFile(T: typedesc[TYPENAME], file: string): TYPENAME =
      var jsn = FILEPARSE(file)

      block:
        let
          keyname = "TEMPKEY"
          default = "DEFAULT"
          defkind = "string"

          j = GETFROM(jsn, keyname)

        var x: string

        if j != nil:
          x = j.str

        if j != nil and COMPKIND(j, defkind) and "VALIDITYTEST":
          result.TEMPKEY = x
        elif true:
          result.TEMPKEY = default
        else:
          raise newException(invalidConfError, "Invalid key " & keyname)
    """

  if not makeFromFile:
    prc[0][0].ident = !"fromString"

  prc[0][3][0] = name.copyNimNode
  prc[0][3][1][1][1] = name.copyNimNode

  prc[0][6][0][0][2][0] = jsParse
  prc[0][6][1][1][0][3][2][0] = jsGet
  prc[0][6][1][1][3][0][0][1][2][0] = jsComp

  var blockSection = prc[0][6][1].copyNimTree
  prc[0][6].del(1) # Get rid of original, temporary block node

  var blocks: seq[PNimrodNode] = @[]

  for key, opt in options.pairs:
    var optBlock = blockSection.copyNimTree

    # TEMPKEY
    optBlock[1][0][0][2].strVal = key

    # defkind
    case $opt.confType
    of "string":
      optBlock[1][0][2][2].strVal = "string"
      optBlock[1][1][0][1] = newIdentNode("string")
      optBlock[1][2][0][1][0][1][1] = newIdentNode("str")
    of "BiggestInt":
      optBlock[1][0][2][2].strVal = "int"
      optBlock[1][1][0][1] = newIdentNode("BiggestInt")
      optBlock[1][2][0][1][0][1][1] = newIdentNode("num")
    of "BiggestFloat":
      optBlock[1][0][2][2].strVal = "float"
      optBlock[1][1][0][1] = newIdentNode("BiggestFloat")
      optBlock[1][2][0][1][0][1][1] = newIdentNode("fnum")
    of "bool":
      optBlock[1][0][2][2].strVal = "bool"
      optBlock[1][1][0][1] = newIdentNode("bool")
      optBlock[1][2][0][1][0][1][1] = newIdentNode("bval")
    else:
      discard

    # VALIDITYTEST
    optBlock[1][3][0][0][2] = opt.test.copyNimTree

    # TEMPKEY
    optBlock[1][3][0][1][0][0][1].ident = !key
    optBlock[1][3][1][1][0][0][1].ident = !key

    # DEFAULT & default test
    if opt.hasDefault:
      optBlock[1][0][1][2] = opt.default.copyNimNode
    else:
      optBlock[1][0].del(1)
      optBlock[1][3].del(1)

    blocks.add(optBlock)

  prc[0][6].add(blocks)

  return prc[0]
  #"""