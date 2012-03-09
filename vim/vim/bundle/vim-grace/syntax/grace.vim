" Vim syntax file
" Language   : Grace (http://grace-lang.org/)

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match
syn sync minlines=50

" most Grace keywords
syn keyword graceKeyword object class method return var def type
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
syn keyword graceClass class nextgroup=graceClassName skipwhite
syn keyword graceObject object skipwhite
syn keyword graceTrait trait nextgroup=graceClassName skipwhite
syn match graceDefName "[^ =:;{}()[]\+" contained nextgroup=graceDefSpecializer skipwhite
syn match graceDefName "[^ =:;{}()[]\+" contained
syn match graceVarName "[^ =:;{}()[]\+" contained 
syn region graceVarName start="`" end="`"
syn match graceClassName "[^ =:;{}()\[]\+" contained nextgroup=graceClassSpecializer skipwhite
syn region graceDefSpecializer start="\[" end="\]" contained contains=graceDefSpecializer
syn region graceClassSpecializer start="\[" end="\]" contained contains=graceClassSpecializer

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

syn region graceBlock start="{" end="}" transparent fold
" syntax region graceBlock start="^\z(\s*\)method .\+ {" end="^\z1}" transparent fold

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
hi link graceError Error
hi link graceWSError Error
hi link graceBuiltinMethod Identifier
hi link graceKeyword Keyword
hi link gracePackage Include
hi link graceImport Include
hi link graceBoolean Boolean
hi link graceOperator Normal
hi link graceNumber Number
hi link graceEmptyString String
hi link graceString String
hi link graceChar String
hi link graceStringEscape Special
hi link graceSymbol Special
hi link graceUnicode Special
hi link graceComment Comment
hi link graceLineComment Comment
hi link graceTodo Todo
hi link graceType Type
hi link graceTypeSpecializer graceType
hi link graceVar Keyword
hi link graceDef Keyword
hi link graceClass Keyword
hi link graceObject Keyword
hi link graceTrait Keyword
hi link graceDefName Function
hi link graceDefSpecializer Function
hi link graceClassName Special
hi link graceClassSpecializer Special
hi link graceInterpolationDelimiter	Delimiter

let b:current_syntax = "grace"

