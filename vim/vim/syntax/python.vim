" .vim/syntax/python.vim -- python
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2010-04-08 21:10:14 +1200 NZST
" Last changed : 2010-05-10 00:36:45 +1200 NZST

" from http://www.sontek.net/Python-with-a-modular-IDE-(Vim)
"syn match pythonError "^\s*def\s\+\w\+(.*)\s*$" display
"syn match pythonError "^\s*class\s\+\w\+(.*)\s*$" display
"syn match pythonError "^\s*for\s.*[^:]$" display
"syn match pythonError "^\s*except\s*$" display
"syn match pythonError "^\s*finally\s*$" display
"syn match pythonError "^\s*try\s*$" display
"syn match pythonError "^\s*else\s*$" display
"syn match pythonError "^\s*else\s*[^:].*" display
"syn match pythonError "^\s*if\s.*[^\:]$" display
"syn match pythonError "^\s*except\s.*[^\:]$" display
"syn match pythonError "[;]$" display
"syn keyword pythonError do

"hi def link pythonError Error

syn keyword pythonBuiltin self

