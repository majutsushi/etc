" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

function! s:tab(shift) abort
    if getline('.') =~ '^\s*|'
        call tablemode#spreadsheet#cell#Motion(a:shift ? 'h' : 'l')
    else
        if a:shift
            python ORGMODE.plugins[u"ShowHide"].toggle_folding(reverse=True)
        else
            python ORGMODE.plugins[u"ShowHide"].toggle_folding()
        endif
    endif
endfunction
nnoremap <buffer>   <Tab> :call <SID>tab(0)<CR>
nnoremap <buffer> <S-Tab> :call <SID>tab(1)<CR>
