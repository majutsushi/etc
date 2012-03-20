" Vim syntax file
" Language   : Grace (http://grace-lang.org/)

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match
syn sync minlines=5000

" foldable blocks
syn region graceMethodDef start="\s*\<method\>" end="{"he=e-1 contains=graceStatementMethod,graceType,graceKeyword
syn keyword graceStatementMethod method contained
syn region graceMethodFold start="^\z(\s*\)\<method\>.*[^}]$" end="^\z1}\s*\(//.*\)\=$" transparent fold keepend extend
syn region graceTypeDef start="\s*\<type\>" end="{"he=e-1 contains=graceStatementType,graceKeyword
syn keyword graceStatementType type contained
syn region graceTypeFold start="^\z(\s*\)\<type\>.*[^}]$" end="^\z1}\s*\(//.*\)\=$" transparent fold keepend extend
syn region graceClassDef start="\s*\<class\>" end="{"he=e-1 contains=graceClass,graceClassName,graceClassSpecializer,graceClassParams,graceType
syn keyword graceClass class contained nextgroup=graceClassName
syn match graceClassName "[^ =:;{}()\[]\+" contained nextgroup=graceClassSpecializer skipwhite
syn region graceClassSpecializer start="\[" end="\]" contained contains=graceClassSpecializer nextgroup=GraceClassParams
syn region graceClassParams start="(" end=")" contained contains=graceType
syn region graceClassFold start="^\z(\s*\)\<class\>.*[^}]$" end="^\z1}\s*\(//.*\)\=$" transparent fold keepend extend

" most Grace keywords
syn keyword graceKeyword object return var def
syn match graceKeyword "->"
syn match graceKeyword ":="

syn match graceOperator ":\{2,\}" "this is not a type


" package and import statements
syn keyword gracePackage package nextgroup=graceFqn skipwhite
syn keyword graceImport import nextgroup=graceFqn skipwhite
syn match graceFqn "\<[._$a-zA-Z0-9,]*" contained

" boolean literals
syn keyword graceBoolean true false

" definitions
syn keyword graceDef def nextgroup=graceDefName skipwhite
syn keyword graceVar var nextgroup=graceVarName skipwhite
syn keyword graceObject object skipwhite
syn keyword graceTrait trait nextgroup=graceClassName skipwhite
syn match graceDefName "[^ =:;{}()[]\+" contained nextgroup=graceDefSpecializer skipwhite
syn match graceDefName "[^ =:;{}()[]\+" contained
syn match graceVarName "[^ =:;{}()[]\+" contained
syn region graceVarName start="`" end="`"
syn region graceDefSpecializer start="\[" end="\]" contained contains=graceDefSpecializer

" method call
syn match graceRoot "\<[a-zA-Z][_$a-zA-Z0-9]*\."me=e-1
syn match graceMethodCall "\.[a-z][_$a-zA-Z0-9]*"ms=s+1

" type declarations in var/def
syn match graceType ":\s*\([a-zA-Z0-9]\+\s*|\s*\)*[a-zA-Z0-9]\+"

" comments
syn match graceTodo "[tT][oO][dD][oO]" contained
syn match graceLineComment "//.*" contains=graceTodo
syn case match

syn match graceEmptyString "\"\""

" string literals with escapes
syn region graceString start="\"" skip="\\\"" end="\"" contains=graceStringEscape,graceWSError,graceInterpolation,graceNoInterpolation
syn match graceStringEscape "\\u[0-9a-fA-F]\{4}" contained
syn match graceStringEscape "\\U[0-9a-fA-F]\{6}" contained
syn match graceStringEscape "\\[nrtfvb{\\\"]" contained

syn region graceInterpolation	      matchgroup=graceInterpolationDelimiter start="{" end="}" contained contains=graceVarName,graceBoolean,graceNumber,graceOperator,graceString
syn region graceNoInterpolation	      start="\\{" end="}"            contained
syn match  graceNoInterpolation	      "\\{"		      display contained

" number literals
syn match graceNumber "\<\(\([2-9]\|[1-9][0-9]\)x[0-9a-z]\+\|0x\x\+\|\d\+\)[lL]\=\>"
syn match graceNumber "\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match graceNumber "\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match graceNumber "\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"

syn sync fromstart

" known errors
syn match graceWSError "\t"
syn match graceWSError "\t" contained
" These containeds are necessary to get the error highlighting on
" if foo { to work while still allowing if/then to be highlighted.
"syn match graceError "if \_[^{}]\+\(then \)\@<!{"
"syn match graceOK "if \_[^{}]\+then {" contains=graceBuiltinMethod
syn keyword graceBuiltinMethod if then for each while do contained
syn keyword graceBuiltinMethod for each while do if then else elseif

" map grace groups to standard groups
hi def link graceError Error
hi def link graceWSError Error
hi def link graceBuiltinMethod Identifier
hi def link graceKeyword Keyword
hi def link graceStatementMethod graceKeyword
hi def link graceStatementType graceKeyword
hi def link gracePackage Include
hi def link graceImport Include
hi def link graceBoolean Boolean
hi def link graceOperator Normal
hi def link graceNumber Number
hi def link graceEmptyString String
hi def link graceString String
hi def link graceChar String
hi def link graceStringEscape Special
hi def link graceSymbol Special
hi def link graceUnicode Special
hi def link graceComment Comment
hi def link graceLineComment Comment
hi def link graceTodo Todo
hi def link graceType Type
hi def link graceTypeSpecializer graceType
hi def link graceVar Keyword
hi def link graceDef Keyword
hi def link graceClass Keyword
hi def link graceObject Keyword
hi def link graceTrait Keyword
hi def link graceDefName Function
hi def link graceDefSpecializer Function
hi def link graceClassName Special
hi def link graceClassSpecializer Special
hi def link graceInterpolationDelimiter Delimiter

let b:current_syntax = "grace"

