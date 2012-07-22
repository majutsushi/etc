XPTemplate priority=personal

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common
      \ _common/personal

fun! s:f.headerSymbolVim(...) "{{{
  let h = expand('%:t:r')
  let h = substitute(h, '\.', '_', 'g') " replace . with _

  return 'loaded_' . h
endfunction "}}}

XPT once " if exists.. finish
XSET i|pre=headerSymbolVim()
if exists(`$SParg^'`g^:`i^'`$SParg^)
    finish
endif
let `g^:`i^`$SPop^=`$SPop^1
`cursor^

XPT varconf " if !exists ".." let .. = .. endif
if !exists(`$SParg^'`g^:`varname^'`$SParg^)
    let `g^:`varname^`$SPop^=`$SPop^`val^
endif

XPT fun wrap " fun! ..(..) .. endfunction
" `name^`$SPfun^() {{{`2^
function! `name^`$SPfun^(`:_args:^) abort
    `cursor^
endfunction

..XPT

XPT member wrap " tips
" `name^`$SPfun^() {{{`2^
function! `name^`$SPfun^(`:_args:^) abort dict
    `cursor^
endfunction

..XPT
