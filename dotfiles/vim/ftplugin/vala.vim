" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

setlocal commentstring=//%s
setlocal errorformat=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m

" Disable valadoc syntax highlight
" let g:vala_ignore_valadoc = 1

" Enable comment strings
" let g:vala_comment_strings = 1

" Highlight space errors
let g:vala_space_errors = 1
" Disable trailing space errors
" let g:vala_no_trail_space_error = 1
" Disable space-tab-space errors
" let g:vala_no_tab_space_error = 1

" Minimum lines used for comment syncing (default 50)
" let g:vala_minlines = 120
