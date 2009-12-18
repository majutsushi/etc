" Rainbow.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Nov 01, 2009
"   Version: 2g	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || !exists("g:loaded_Rainbow")
 finish
endif
let g:loaded_Rainbow = "v2g"
let s:keepcpo        = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Rainbow#Rainbow: enable/disable rainbow highlighting for C/C++ {{{2
fun! Rainbow#Rainbow(enable,hlrainbow)
"  call Dfunc("Rainbow#Rainbow(enable=".a:enable." hlrainbow<".a:hlrainbow.">)")
  exe "set ft=".&ft
  if a:hlrainbow != ""
   let g:hlrainbow= a:hlrainbow
  endif
  if a:enable
   if exists("b:hlrainbow")
    unlet b:hlrainbow
   endif
"  call Decho("sourcing rainbow.vvim")
   exe "so ".substitute(&rtp,',.*$','','')."/after/syntax/c/rainbow.vvim"
  endif
"  call Dret("Rainbow#Rainbow")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
