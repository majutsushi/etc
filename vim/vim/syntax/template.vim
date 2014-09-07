" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

" Quit when a syntax file was already loaded {{{2
if exists("b:current_syntax")
    finish
endif
let s:keepcpo = &cpo
set cpo&vim

syntax include @vim syntax/vim.vim

syntax region templateCmd start=/{%+\?/hs=s+2 keepend end=/+\?%}/me=s-1 contains=@vim,templateCmdTag
syntax match templateCmdTag /{%+\?/ contained
syntax match templateCmdTag /+\?%}/

syntax region templateExpr start=/{{\s/hs=s+3 keepend end=/\s}}/me=s-1 contains=@vim,templateExprTag
syntax match templateExprTag /{{\ze\s/ contained
syntax match templateExprTag /\s\zs}}/

highlight default link templateCmdTag  Statement
highlight default link templateExprTag Identifier

let b:current_syntax = "template"

let &cpo = s:keepcpo
unlet s:keepcpo
