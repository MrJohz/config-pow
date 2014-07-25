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
  inferredWithTest = [int, default: 4, test: x < 54]
  listWithNullable = [?string, default: "hello"]

dumpTree:
  discard
  
type
  powConfig = object
    filename*: string
    inferredWithTest*: BiggestInt
    defaultVal*: string
    defaultInferred*: BiggestInt
    age*: BiggestInt

dumpTree:
  #when false: 
  # type
  #   TestConfigType = object
  #     filename*: string
  #     age*: int
  #     defaultVal: string
  #     defaultInferred: int
  #     inferredWithTest: int

  proc fromFile(T: typedesc[powConfig], filename: string): T =
    discard

  #     if x == nil:
  #       return false
  #     elif not "b" in x:
  #       return false

  #   block:
  #     let x = val.inferredWithTest

  #     if x == nil:
  #       return false
  #     elif not x < 54:
  #       return false

  # proc new(T: typedesc[TestConfigType], file: string, format: TConfigFormat): TestConfigType =
  #   result = T()
  #   result.loadDefaults()
  #   result.loadFromFile(file, format)

  # proc loadDefaults(c: TestConfigType) =
  #   # load from defaults

  # proc loadFromFile(c: TestConfigType, file: string, format: TConfigFormat) =
  #   # load from File

dumpTree:
  "hello"

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
  Asgn
    Ident !"listWithNullable"
    Bracket
      Prefix
        Ident !"?"
        Ident !"string"
      ExprColonExpr
        Ident !"default"
        StrLit hello
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
  ProcDef
    Ident !"new"
    Empty
    Empty
    FormalParams
      Ident !"TestConfigType"
      IdentDefs
        Ident !"T"
        BracketExpr
          Ident !"typedesc"
          Ident !"TestConfigType"
        Empty
      IdentDefs
        Ident !"file"
        Ident !"string"
        Empty
      IdentDefs
        Ident !"format"
        Ident !"TConfigFormat"
        Empty
    Empty
    Empty
    StmtList
      Asgn
        Ident !"result"
        Call
          Ident !"T"
      Call
        DotExpr
          Ident !"result"
          Ident !"loadDefaults"
      Call
        DotExpr
          Ident !"result"
          Ident !"loadFromFile"
        Ident !"file"
        Ident !"format"
  ProcDef
    Ident !"loadDefaults"
    Empty
    Empty
    FormalParams
      Empty
      IdentDefs
        Ident !"c"
        Ident !"TestConfigType"
        Empty
    Empty
    Empty
    StmtList
      CommentStmt
  ProcDef
    Ident !"loadFromFile"
    Empty
    Empty
    FormalParams
      Empty
      IdentDefs
        Ident !"c"
        Ident !"TestConfigType"
        Empty
      IdentDefs
        Ident !"file"
        Ident !"string"
        Empty
      IdentDefs
        Ident !"format"
        Ident !"TConfigFormat"
        Empty
"""
