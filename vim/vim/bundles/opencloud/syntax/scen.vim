" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim


syntax region scenFold start="{" end="}" transparent fold


syntax keyword scenSection  ROLES DIALOGS TABLES

syntax region  scenAttribute  start='(' end=')'
syntax region  scenMetadata   start='\[' end='\]'
syntax region  scenString     start=+"+ end=+"+

syntax match   scenMessage "^  \zs[^ }]\+"


highlight default link scenSection    Keyword
highlight default link scenAttribute  PreProc
highlight default link scenMetadata   Special
highlight default link scenString     String
highlight default link scenMessage    Type


let b:current_syntax = "scen"

let &cpo = s:cpo_save
unlet s:cpo_save
