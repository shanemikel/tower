-- Create Ramses build script.
--
-- (c) 2015 Galois, Inc.
--

module Tower.AADL.Build.Common where

import Data.Char
import Text.PrettyPrint.Leijen hiding ((</>))

import Tower.AADL.Config (AADLConfig(..))

data Required
  = Req
  | Opt
  deriving (Read, Show, Eq)

data Assign
  = Equals
  | ColonEq
  | QuestionEq
  | PlusEq
  deriving (Read, Show, Eq)

data Export
  = NoExport
  | Export
  deriving (Read, Show, Eq)

data MkStmt
  = Include Required FilePath
  | Var Export String Assign String
  | Target String [String] [String]
  | Comment String
  deriving (Read, Show, Eq)


-- Combinators to make building make statements easier ------------------------
include :: FilePath -> MkStmt
include fname = Include Req fname

includeOpt :: FilePath -> MkStmt
includeOpt fname = Include Opt fname

infixr 4 ?=, =:, +=, ===

(?=) :: String -> String -> MkStmt
var ?= val = Var NoExport var QuestionEq val

(=:) :: String -> String -> MkStmt
var =: val = Var NoExport var ColonEq val

(+=) :: String -> String -> MkStmt
var += val = Var NoExport var PlusEq val

(===) :: String -> String -> MkStmt
var === val = Var NoExport var Equals val

export :: MkStmt -> MkStmt
export (Var _ var assign val) = Var Export var assign val
export s                      = s
-------------------------------------------------------------------------------

-- Makefile pretty printer ----------------------------------------------------
renderExport :: Export -> Doc
renderExport NoExport = empty
renderExport Export   = text "export "

renderAssign :: Assign -> Doc
renderAssign Equals     = char '='
renderAssign ColonEq    = text " := "
renderAssign QuestionEq = text " ?= "
renderAssign PlusEq     = text " += "

renderMkStmt :: MkStmt -> Doc
renderMkStmt (Include Req fp) = text "include"  <+> text fp
renderMkStmt (Include Opt fp) = text "-include" <+> text fp
renderMkStmt (Var expt var assign val)  =
  renderExport expt <> text var <> renderAssign assign <> text val
renderMkStmt (Target name deps actions) =
     text name <> text ":" <+> hsep (map text deps)
  <> foldr (\str acc -> linebreak <> char '\t' <> text str <> acc) empty actions
  <> linebreak
renderMkStmt (Comment msg) = char '#' <+> text msg

renderMkStmts :: [MkStmt] -> String
renderMkStmts stmts = show $
  foldr (\mkstmt acc -> renderMkStmt mkstmt <> linebreak <> linebreak <> acc) empty stmts
-------------------------------------------------------------------------------

ramsesMakefileName :: String
ramsesMakefileName = "ramses.mk"

aadlFilesMk :: String
aadlFilesMk = "AADL_FILES.mk"

componentLibsName :: String
componentLibsName = "componentlibs.mk"

mkLib :: AADLConfig -> [String] -> String
mkLib c aadlFileNames =
  unlines (map go aadlFileNames) ++ []
  where
  go m = m ++ "_LIBS += " ++ configLibDir c

makefileName :: String
makefileName = "Makefile"

--------------------------------------------------------------------------------
-- Helpers

shellVar :: String -> String
shellVar = map toUpper
