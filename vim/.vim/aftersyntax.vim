" aftersyntax.vim:
"   Author: 	Charles E. Campbell, Jr.
"   Date:		Jul 02, 2004
"   Version:	1
"
"   1. Just rename this file (to something like c.vim)
"   2. Put it into .vim/after/syntax
"   3. Then any *.vim files in the subdirectory
"      .vim/after/syntax/name-of-file/
"      will be sourced

" ---------------------------------------------------------------------
" source in all files in the after/syntax/c directory
let ft       = expand("<sfile>:t:r")
let s:synlist= glob(expand("<sfile>:h")."/".ft."/*.vim")
"call Decho("ft<".ft."> synlist<".s:synlist.">")

while s:synlist != ""
 if s:synlist =~ '\n'
  let s:synfile = substitute(s:synlist,'\n.*$','','e')
  let s:synlist = substitute(s:synlist,'^.\{-}\n\(.*\)$','\1','e')
  else
  let s:synfile = s:synlist
  let s:synlist = ""
 endif

" call Decho("sourcing <".s:synfile.">")
 exe "so ".s:synfile
endwhile

" cleanup
unlet s:synlist
if exists("s:synfile")
 unlet s:synfile
endif
