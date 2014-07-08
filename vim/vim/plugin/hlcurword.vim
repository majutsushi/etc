" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

if &compatible || exists('loaded_hlcurword')
    finish
endif
let loaded_hlcurword = 1

if !hlexists('CurWord')
    if &background == 'dark'
        highlight CurWord guibg=#555555
    else
        highlight CurWord guibg=#aaaaaa
    endif
endif

function! s:hlcurword() abort
    let word = expand('<cword>')

    " Safer to do this than save the id from matchadd() in case someone has
    " called clearmatches()
    let matches = filter(getmatches(), 'v:val.group == "CurWord"')
    for lastmatch in matches
        call matchdelete(lastmatch.id)
    endfor

    call matchadd('CurWord', '\V\<' . word . '\>', -50)
endfunction

augroup HlCurWord
    autocmd CursorHold  * call s:hlcurword()
    autocmd CursorHoldI * call s:hlcurword()
augroup END
