" RainbowPlugin.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Oct 28, 2009
"   Version: 2n	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_Rainbow")
 finish
endif
let g:loaded_Rainbow= "v2g"
let s:keepcpo       = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -nargs=? -bang Rainbow	call Rainbow#Rainbow(<bang>1,<q-args>)

" ---------------------------------------------------------------------
" Default: {{{1
if !exists("g:hlrainbow")
 let g:hlrainbow= "{("
endif

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
