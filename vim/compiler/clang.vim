" Vim compiler file
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-01-16 20:18:43 +1300 NZDT
" Last changed : 2012-01-16 20:18:43 +1300 NZDT

if exists("current_compiler")
  finish
endif
let current_compiler = "clang"

let s:cpo_save = &cpo
set cpo-=C

CompilerSet errorformat=%f:%l:%c:\ %t%s:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
