" Rainbow.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Nov 18, 2009
"   Version: 2n	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || !exists("g:loaded_Rainbow")
 finish
endif
let g:loaded_Rainbow = "v2n"
let s:keepcpo        = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Rainbow#Rainbow: enable/disable rainbow highlighting for C/C++ {{{2
fun! Rainbow#Rainbow(enable,hlrainbow)
  if !exists("s:rainbowlevel")
   let s:rainbowlevel= 1
  else
   let s:rainbowlevel= s:rainbowlevel + 1
  endif

"  call Dfunc("Rainbow#Rainbow(enable=".a:enable." hlrainbow<".a:hlrainbow.">) rainbowlevel=".s:rainbowlevel)

  if s:rainbowlevel > 1
   let s:rainbowlevel= s:rainbowlevel - 1
"   call Dret("Rainbow#Rainbow : preventing Rainbow nesting")
   return
  endif

  " set filetype to clear out rainbow highlighting; remove any commands in the AuRainbowColor autocmd group
  augroup AugroupRainbow
   au!
  augroup END
  silent! augroup! AugroupRainbow
  exe "set ft=".&ft

  " set global g:hlrainbow to the new user's selection (if any)
  if a:hlrainbow != ""
   let g:hlrainbow= a:hlrainbow
  endif

  if a:enable
"  call Decho("sourcing rainbow.vvim")
   augroup AugroupRainbow
	au BufNewFile,BufReadPost *.c,*.cpp,*.cxx,*.c++,*.C,*.h,*.hpp,*.hxx,*.h++,*.H	Rainbow
	augroup END
   exe "so ".fnameescape(substitute(&rtp,',.*$','',''))."/after/syntax/c/rainbow.vvim"
  endif

  let s:rainbowlevel= s:rainbowlevel - 1
"  call Dret("Rainbow#Rainbow")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
