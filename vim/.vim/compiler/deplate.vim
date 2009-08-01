" viki.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     25-Apr-2004.
" @Last Change: 2009-02-15.
" @Revision:    0.43
" 
" Description:
" Use deplate as the "compiler" for viki files.

if exists("current_compiler")
  finish
endif
let current_compiler = "deplate"
" let g:current_compiler="deplate"

if exists(":CompilerSet") != 2
    command! -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo&vim

fun! DeplateCompilerSet(options)
    if exists("b:deplatePrg")
        exec "CompilerSet makeprg=".escape(b:deplatePrg ." ". a:options, " ")."\\ $*\\ %"
    elseif exists("g:deplatePrg")
        exec "CompilerSet makeprg=".escape(g:deplatePrg ." ". a:options, " ")."\\ $*\\ %"
    else
        exec "CompilerSet makeprg=deplate ".escape(a:options, " ")."\\ $*\\ %"
        " CompilerSet makeprg=deplate\ $*\ %
    endif
endf
command! -nargs=* DeplateCompilerSet call DeplateCompilerSet(<q-args>)

DeplateCompilerSet

CompilerSet errorformat=%f:%l:%m,%f:%l-%*\\d:%m

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ff=unix
