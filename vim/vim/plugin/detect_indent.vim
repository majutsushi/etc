" Try to automatically detect indent settings
" Author:  Jan Larres <jan@majutsushi.net>
" Website: http://majutsushi.net
" License: MIT/X11

if &cp || exists("loaded_detect_indent")
    finish
endif
let loaded_detect_indent = 1

function! s:detect_indent() abort
    let tabs = search('^\t', 'nw') != 0
    let spaces = search('^ ', 'nw') != 0
    let expand = 1

    if tabs && spaces
        let expand = s:should_expand()
    elseif spaces
        let expand = 1
    elseif tabs
        let expand = 0
    endif

    if expand
        setlocal expandtab
        let min_indent = s:get_min_indent()
        if min_indent > 0
            execute 'setlocal softtabstop=' . min_indent
            execute 'setlocal shiftwidth=' . min_indent
        endif
    else
        setlocal noexpandtab
        setlocal softtabstop=0
        setlocal shiftwidth=8
    endif
endfunction

function! s:should_expand() abort
    let num_spaces = len(filter(getbufline(winbufnr(0), 1, '$'), "v:val =~ '^ '"))
    let num_tabs =   len(filter(getbufline(winbufnr(0), 1, '$'), "v:val =~ '^\t'"))

    return num_spaces > num_tabs
endfunction

function! s:get_min_indent() abort
    let indented = filter(getbufline(winbufnr(0), 1, '$'), "v:val =~ '^ '")
    call map(indented, "substitute(v:val, '^\\( \\+\\)[^ ]', '\\=len(submatch(1))', '')")
    return min(indented)
endfunction

autocmd BufReadPost,BufWritePost * call s:detect_indent()
