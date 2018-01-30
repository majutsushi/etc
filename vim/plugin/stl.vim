" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

if &compatible || exists('g:loaded_stl')
    finish
endif
let g:loaded_stl = 1

function! s:set_colours(colours) abort
    for name in keys(a:colours)
        let colours = {'c': a:colours[name][0], 'nc': a:colours[name][1]}
        let name = (name ==# 'NONE' ? '' : name)

        if exists("colours['c'][0]")
            exec 'hi StatusLine' . name .
               \ ' guibg=' . colours['c'][0] .
               \ ' guifg=' . colours['c'][1] .
               \ ' gui='   . colours['c'][2]
        endif

        if exists("colours['nc'][0]")
            exec 'hi StatusLine' . name . 'NC' .
               \ ' guibg=' . colours['nc'][0] .
               \ ' guifg=' . colours['nc'][1] .
               \ ' gui='   . colours['nc'][2]
        endif
    endfor
endfunction

augroup stl
    autocmd!
    autocmd ColorScheme * call s:set_colours(g:statuscolours)
    autocmd VimEnter,WinEnter,BufWinEnter * call stl#update()
    autocmd BufReadPost,CursorHold,BufWritePost * call stl#recompute_stl_ts()
    autocmd BufReadPost,CursorHold,BufWritePost * call stl#recompute_stl_ws()
augroup END

call s:set_colours(g:statuscolours)
