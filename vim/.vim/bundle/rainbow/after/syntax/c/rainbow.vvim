" rainbow.vvim : provides "rainbow-colored" curly braces and parentheses
"               C/C++ language version
"   Author: 	Charles E. Campbell, Jr.
"   Date:		Nov 01, 2009
"   Associated Files:  plugin/RainbowPlugin.vim autoload/Rainbow.vim doc/Rainbow.txt
" ---------------------------------------------------------------------
" non-compatible only: {{{1
if &cp
 finish
endif
let keepcpo= &cpo
let s:work = ''
set cpo&vim

" ---------------------------------------------------------------------
" Default Settings: {{{1
if !exists("g:hlrainbow")
 let g:hlrainbow= '{}()'
endif
"call Decho("g:hlrainbow<".g:hlrainbow.">")

syn clear cParen cCppParen cBracket cCppBracket cBlock cParenError

" Clusters {{{1
syn cluster cParenGroup		contains=cBlock,cCharacter,cComment,cCommentError,cCommentL,cConditional,cConstant,cDefine,cInclude,cLabel,cMulti,cNumbers,cOperator,cPreProc,cRepeat,cSpaceError,cSpecialCharacter,cSpecialError,cStatement,cStorageClass,cString,cStructure,cType
syn cluster cCppParenGroup	contains=cBlock,cCharacter,cComment,cCommentError,cCommentL,cConditional,cConstant,cCppBracket,cCppString,cDefine,cInclude,cLabel,cMulti,cNumbers,cOperator,cPreProc,cRepeat,cSpaceError,cSpecialCharacter,cSpecialError,cStatement,cStorageClass,cStructure,cType
syn cluster cCurlyGroup		contains=cConditional,cConstant,cLabel,cOperator,cRepeat,cStatement,cStorageClass,cStructure,cType,cBitField,cCharacter,cCommentError,cInclude,cNumbers,cPreCondit,cSpaceError,cSpecialCharacter,cSpecialError,cUserCont,cBlock,cComment,cCommentL,cCppOut,cCppString,cDefine,cMulti,cPreCondit,cPreProc,cString,cFoldSpec
if &ft == "cpp"
 syn cluster cCurlyGroup add=cppStatement,cppAccess,cppType,cppExceptions,cppOperator,cppCast,cppStorageClass,cppStructure,cppNumber,cppBoolean,cppMinMax
endif

" Error Syntax {{{1
syn clear cErrInBracket
syn match	cErrInBracket	display contained "[{}]\|<%\|%>"
syn match	cParenError		display ')'
syn match	cBracketError	display ']'
if &ft == "cpp"
 syn cluster cCppBracketGroup	add=cParenError,cErrInBracket,cCurly,cCppParen,cCppBracket
 syn cluster cCppParenGroup		add=cBracketError,cErrInBracket,cCurly,cCppParen,cCppBracket
 syn cluster cBracketGroup		add=cParenError,cErrInBracket,cCurly,cCppParen,cCppBracket
 syn cluster cParenGroup		add=cBracketError,cErrInBracket,cCurly,cCppParen,cCppBracket
 syn cluster cCurlyGroup		add=cParenError,cBracketError,cCurly,cCppParen,cCppBracket
else
 syn cluster cBracketGroup		add=cParenError,cErrInBracket,cCurly,cParen,cBracket
 syn cluster cParenGroup		add=cBracketError,cErrInBracket,cCurly,cParen,cBracket
 syn cluster cCurlyGroup		add=cParenError,cBracketError,cCurly,cParen,cBracket
endif

" ---------------------------------------------------------------------
" supports {} highlighting, too many } error detection, and {{{1
" function folding (when fdm=syntax)
if g:hlrainbow =~ '[{}]'

" call Decho("enabling {} rainbow")
 syn match  cCurlyError	display '}'
 syn region cCurly  fold matchgroup=hlLevel0 start='{' end='}' 			 contains=@cCurlyGroup,cCurly1
 syn region cCurly1		 matchgroup=hlLevel1 start='{' end='}' contained contains=@cCurlyGroup,cCurly2
 syn region cCurly2		 matchgroup=hlLevel2 start='{' end='}' contained contains=@cCurlyGroup,cCurly3
 syn region cCurly3		 matchgroup=hlLevel3 start='{' end='}' contained contains=@cCurlyGroup,cCurly4
 syn region cCurly4		 matchgroup=hlLevel4 start='{' end='}' contained contains=@cCurlyGroup,cCurly5
 syn region cCurly5		 matchgroup=hlLevel5 start='{' end='}' contained contains=@cCurlyGroup,cCurly6
 syn region cCurly6		 matchgroup=hlLevel6 start='{' end='}' contained contains=@cCurlyGroup,cCurly7
 syn region cCurly7		 matchgroup=hlLevel7 start='{' end='}' contained contains=@cCurlyGroup,cCurly8
 syn region cCurly8		 matchgroup=hlLevel8 start='{' end='}' contained contains=@cCurlyGroup,cCurly9
 syn region cCurly9		 matchgroup=hlLevel9 start='{' end='}' contained contains=@cCurlyGroup,cCurly
else
 syn region cCurly	fold start='{' end='}'	contains=@cCurlyGroup
endif

" ---------------------------------------------------------------------
" supports () highlighting and error detection {{{1
if g:hlrainbow =~ '[()]'

 if &ft == "cpp"
"  call Decho("enabling () rainbow for C++")
  syn region	cCppParen	transparent matchgroup=hlLevel0	start='(' end=')' 			contains=@cCppParenGroup,cCppParen1 
  syn region	cCppParen1	transparent matchgroup=hlLevel1	start='(' end=')' contained contains=@cCppParenGroup,cCppParen2 
  syn region	cCppParen2	transparent matchgroup=hlLevel2	start='(' end=')' contained contains=@cCppParenGroup,cCppParen3 
  syn region	cCppParen3	transparent matchgroup=hlLevel3	start='(' end=')' contained contains=@cCppParenGroup,cCppParen4 
  syn region	cCppParen4	transparent matchgroup=hlLevel4	start='(' end=')' contained contains=@cCppParenGroup,cCppParen5 
  syn region	cCppParen5	transparent matchgroup=hlLevel5	start='(' end=')' contained contains=@cCppParenGroup,cCppParen6 
  syn region	cCppParen6	transparent matchgroup=hlLevel6	start='(' end=')' contained contains=@cCppParenGroup,cCppParen7 
  syn region	cCppParen7	transparent matchgroup=hlLevel7	start='(' end=')' contained contains=@cCppParenGroup,cCppParen8 
  syn region	cCppParen8	transparent matchgroup=hlLevel8	start='(' end=')' contained contains=@cCppParenGroup,cCppParen9 
  syn region	cCppParen9	transparent matchgroup=hlLevel9	start='(' end=')' contained contains=@cCppParenGroup,cCppParen
 else
"  call Decho("enabling () rainbow for C")
  syn region	cParen		transparent matchgroup=hlLevel0	start='(' end=')' 			contains=@cParenGroup,cParen1
  syn region	cParen1		transparent matchgroup=hlLevel1	start='(' end=')' contained contains=@cParenGroup,cParen2
  syn region	cParen2		transparent matchgroup=hlLevel2	start='(' end=')' contained contains=@cParenGroup,cParen3
  syn region	cParen3		transparent matchgroup=hlLevel3	start='(' end=')' contained contains=@cParenGroup,cParen4
  syn region	cParen4		transparent matchgroup=hlLevel4	start='(' end=')' contained contains=@cParenGroup,cParen5
  syn region	cParen5		transparent matchgroup=hlLevel5	start='(' end=')' contained contains=@cParenGroup,cParen6
  syn region	cParen6		transparent matchgroup=hlLevel6	start='(' end=')' contained contains=@cParenGroup,cParen7
  syn region	cParen7		transparent matchgroup=hlLevel7	start='(' end=')' contained contains=@cParenGroup,cParen8
  syn region	cParen8		transparent matchgroup=hlLevel8	start='(' end=')' contained contains=@cParenGroup,cParen9
  syn region	cParen9		transparent matchgroup=hlLevel9	start='(' end=')' contained contains=@cParenGroup,cParen
 endif
else
 if &ft == "cpp"
  syn region	cCppParen	start='(' end=')' contains=@cParenGroup
 else
  syn region	cParen		start='(' end=')' contains=@cParenGroup
 endif
endif

" ---------------------------------------------------------------------
" supports [] highlighting and error detection {{{1
if g:hlrainbow =~ '[[\]]'
 syn clear   cBracket cCppBracket
 syn cluster cBracketGroup		contains=cBlock,cBracket,cCharacter,cComment,cCommentError,cCommentL,cConditional,cConstant,cDefine,cInclude,cLabel,cMulti,cNumbers,cOperator,cPreProc,cRepeat,cSpaceError,cSpecialCharacter,cSpecialError,cStatement,cStorageClass,cString,cStructure,cType

 if &ft == "cpp"
"  call Decho("enabling [] rainbow for C++")
  syn cluster cCppBracketGroup	contains=cBlock,cCharacter,cComment,cCommentError,cCommentL,cConditional,cConstant,cCppBracket,cCppParen,cCppString,cDefine,cInclude,cLabel,cMulti,cNumbers,cOperator,cPreProc,cRepeat,cSpaceError,cSpecialCharacter,cSpecialError,cStatement,cStorageClass,cStructure,cType
  syn region cCppBracket  fold	matchgroup=hlLevel0 start='\[' end=']' 			 contains=@cCppBracketGroup,cCppBracket1
  syn region cCppBracket1		matchgroup=hlLevel1 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket2
  syn region cCppBracket2		matchgroup=hlLevel2 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket3
  syn region cCppBracket3		matchgroup=hlLevel3 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket4
  syn region cCppBracket4		matchgroup=hlLevel4 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket5
  syn region cCppBracket5		matchgroup=hlLevel5 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket6
  syn region cCppBracket6		matchgroup=hlLevel6 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket7
  syn region cCppBracket7		matchgroup=hlLevel7 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket8
  syn region cCppBracket8		matchgroup=hlLevel8 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket9
  syn region cCppBracket9		matchgroup=hlLevel9 start='\[' end=']' contained contains=@cCppBracketGroup,cCppBracket
 else
"  call Decho("enabling [] rainbow for C")
  syn region cBracket  fold	matchgroup=hlLevel0 start='\[' end=']' 			 contains=@cBracketGroup,cBracket1
  syn region cBracket1		matchgroup=hlLevel1 start='\[' end=']' contained contains=@cBracketGroup,cBracket2
  syn region cBracket2		matchgroup=hlLevel2 start='\[' end=']' contained contains=@cBracketGroup,cBracket3
  syn region cBracket3		matchgroup=hlLevel3 start='\[' end=']' contained contains=@cBracketGroup,cBracket4
  syn region cBracket4		matchgroup=hlLevel4 start='\[' end=']' contained contains=@cBracketGroup,cBracket5
  syn region cBracket5		matchgroup=hlLevel5 start='\[' end=']' contained contains=@cBracketGroup,cBracket6
  syn region cBracket6		matchgroup=hlLevel6 start='\[' end=']' contained contains=@cBracketGroup,cBracket7
  syn region cBracket7		matchgroup=hlLevel7 start='\[' end=']' contained contains=@cBracketGroup,cBracket8
  syn region cBracket8		matchgroup=hlLevel8 start='\[' end=']' contained contains=@cBracketGroup,cBracket9
  syn region cBracket9		matchgroup=hlLevel9 start='\[' end=']' contained contains=@cBracketGroup,cBracket
 endif
else
 if &ft == "cpp"
  syn region	cCppBracket	start='\[' end=']' contains=@cCppBracketGroup
 else
  syn region	cBracket	start='\[' end=']' contains=@cBracketGroup
 endif
endif

" don't use {{{# patterns in curly brace matching
syn match cFoldSpec	'{{{\d\+'
syn match cFoldSpec	'}}}\d\+'

" highlighting: {{{1
hi link cCurlyError		cError
hi link cBracketError	cError
if &bg == "dark"
 hi default   hlLevel0 ctermfg=red         guifg=red1
 hi default   hlLevel1 ctermfg=yellow      guifg=orange1      
 hi default   hlLevel2 ctermfg=green       guifg=yellow1      
 hi default   hlLevel3 ctermfg=cyan        guifg=gold
 hi default   hlLevel4 ctermfg=magenta     guifg=hotpink
 hi default   hlLevel5 ctermfg=red         guifg=PeachPuff1
 hi default   hlLevel6 ctermfg=yellow      guifg=cyan1        
 hi default   hlLevel7 ctermfg=green       guifg=slateblue1   
 hi default   hlLevel8 ctermfg=cyan        guifg=magenta1     
 hi default   hlLevel9 ctermfg=magenta     guifg=purple1
else
 hi default   hlLevel0 ctermfg=red         guifg=red3
 hi default   hlLevel1 ctermfg=darkyellow  guifg=orangered3
 hi default   hlLevel2 ctermfg=darkgreen   guifg=orange2
 hi default   hlLevel3 ctermfg=blue        guifg=yellow3
 hi default   hlLevel4 ctermfg=darkmagenta guifg=olivedrab4
 hi default   hlLevel5 ctermfg=red         guifg=green4
 hi default   hlLevel6 ctermfg=darkyellow  guifg=paleturquoise3
 hi default   hlLevel7 ctermfg=darkgreen   guifg=deepskyblue4
 hi default   hlLevel8 ctermfg=blue        guifg=darkslateblue
 hi default   hlLevel9 ctermfg=darkmagenta guifg=darkviolet
endif

" ---------------------------------------------------------------------
"  Modelines: {{{1
let &cpo= keepcpo
" vim: fdm=marker ft=vim ts=4
