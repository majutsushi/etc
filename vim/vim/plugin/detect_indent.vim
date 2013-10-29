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

    let min_indent = s:get_min_indent()

    if tabs && spaces
        let expand = s:should_expand()
        let &tabstop = min_indent
    elseif spaces
        let expand = 1
    elseif tabs
        let expand = 0
    endif

    if expand
        set expandtab
        if min_indent > 0
            let &softtabstop = min_indent
            let &shiftwidth = min_indent
        endif
    else
        set noexpandtab
        set softtabstop=0
        let &shiftwidth = &tabstop
    endif
endfunction

function! s:should_expand() abort
    let num_spaces = len(filter(getline(1, '$'), "v:val =~ '^ '"))
    let num_tabs =   len(filter(getline(1, '$'), "v:val =~ '^\t'"))

    return num_spaces >= num_tabs
endfunction

function! s:get_min_indent() abort
    let has_c_comments = index(['c', 'cpp', 'java', 'javascript', 'php'],
                            \ &filetype) != -1
    let max_lines = 500
    let minindent = 8

    for linenr in range(1, min([max_lines, line('$')]))
        let line = getline(linenr)

        if line[0] != ' ' || line[minindent - 1] == ' ' || line !~ '\S' ||
         \ (has_c_comments && line =~ '^ \*')
            continue
        endif

        let indent = len(matchstr(line, '^ \+'))
        let minindent = min([indent, minindent])
    endfor

    return minindent
endfunction

autocmd BufReadPost,BufWritePost * call s:detect_indent()
