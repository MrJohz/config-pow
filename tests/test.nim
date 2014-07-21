import macros

macro myDumpTree(name:expr, body:stmt): stmt {.immediate.} =
  echo treeRepr(name)
  echo "------"
  echo treeRepr(body)
  echo "------"

myDumpTree "TestConfigType" :
  
  filename = string
  age = ?int  # nullable
  defaultVal = [string, default: "hello", test: "b" in x]
  defaultInferred = 4
  inferredWithTest = [default: 4, test: x < 54]


dumpTree:
  
  type
    TestConfigType = object of TConfig
      filename*: string not nil
      age*: int
      defaultVal: string
      defaultInferred: int
      inferredWithTest: int

  proc testTestConfigType(val: TestConfigType): bool =
    block:
      let x = val.defaultVal

      if not "b" in x:
        return false

    block:
      let x = val.inferredWithTest

      if not x < 54:
        return false

discard """
StrLit TestConfigType
------
StmtList
  Asgn
    Ident !"filename"
    Ident !"string"
  Asgn
    Ident !"age"
    Prefix
      Ident !"?"
      Ident !"int"
  Asgn
    Ident !"defaultVal"
    Bracket
      Ident !"string"
      ExprColonExpr
        Ident !"default"
        StrLit hello
      ExprColonExpr
        Ident !"test"
        Infix
          Ident !"in"
          StrLit b
          Ident !"x"
  Asgn
    Ident !"defaultInferred"
    IntLit 4
  Asgn
    Ident !"inferredWithTest"
    Bracket
      ExprColonExpr
        Ident !"default"
        IntLit 4
      ExprColonExpr
        Ident !"test"
        Infix
          Ident !"<"
          Ident !"x"
          IntLit 54
------
StmtList
  TypeSection
    TypeDef
      Ident !"TestConfigType"
      Empty
      ObjectTy
        Empty
        OfInherit
          Ident !"TConfig"
        RecList
          IdentDefs
            Postfix
              Ident !"*"
              Ident !"filename"
            Infix
              Ident !"not"
              Ident !"string"
              NilLit nil
            Empty
          IdentDefs
            Postfix
              Ident !"*"
              Ident !"age"
            Ident !"int"
            Empty
          IdentDefs
            Ident !"defaultVal"
            Ident !"string"
            Empty
          IdentDefs
            Ident !"defaultInferred"
            Ident !"int"
            Empty
          IdentDefs
            Ident !"inferredWithTest"
            Ident !"int"
            Empty
  ProcDef
    Ident !"testTestConfigType"
    Empty
    Empty
    FormalParams
      Ident !"bool"
      IdentDefs
        Ident !"val"
        Ident !"TestConfigType"
        Empty
    Empty
    Empty
    StmtList
      BlockStmt
        Empty
        StmtList
          LetSection
            IdentDefs
              Ident !"x"
              Empty
              DotExpr
                Ident !"val"
                Ident !"defaultVal"
          IfStmt
            ElifBranch
              Infix
                Ident !"in"
                Prefix
                  Ident !"not"
                  StrLit b
                Ident !"x"
              StmtList
                ReturnStmt
                  Ident !"false"
      BlockStmt
        Empty
        StmtList
          LetSection
            IdentDefs
              Ident !"x"
              Empty
              DotExpr
                Ident !"val"
                Ident !"inferredWithTest"
          IfStmt
            ElifBranch
              Infix
                Ident !"<"
                Prefix
                  Ident !"not"
                  Ident !"x"
                IntLit 54
              StmtList
                ReturnStmt
                  Ident !"false"
"""
