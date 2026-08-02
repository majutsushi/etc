" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

if &compatible || exists('g:loaded_stl')
    finish
endif
let g:loaded_stl = 1

augroup stl
    autocmd!
    autocmd BufReadPost,CursorHold,BufWritePost * call stl#recompute_stl_ts()
    autocmd BufReadPost,CursorHold,BufWritePost * call stl#recompute_stl_ws()
    autocmd VimEnter,WinEnter,BufWinEnter,CursorHold * call stl#update()
augroup END
