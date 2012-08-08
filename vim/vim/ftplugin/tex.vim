" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net

setlocal foldmethod=expr
setlocal foldexpr=LatexFold(v:lnum)

let b:chapter_present = search('^\\chapter{', 'cnw')
autocmd BufWritePost <buffer> let b:chapter_present = search('^\\chapter{', 'cnw')

function! LatexFold(lnum)
    if b:chapter_present > 0
        let base = 2
    else
        let base = 1
    endif

    let line = getline(a:lnum)

    if line =~ '^\\chapter{.\+}'
        return '>1'
    elseif line =~ '^\\section{.\+}'
        return '>' . base
    elseif line =~ '^\\subsection{.\+}'
        return '>' . string(base + 1)
    elseif line =~ '^\\subsubsection{.\+}'
        return '>' . string(base + 2)
    elseif line =~ '\\begin{.\+}'
        return 'a1'
    elseif line =~ '\\end{.\+}'
        return 's1'
    endif

    return '='
endfunction

" Reformat lines (getting the spacing correct)
function! s:TeX_format()
    if getline('.') == ''
        return
    endif

    let cursor_save   = getpos('.')
    let wrapscan_save = &wrapscan
    set nowrapscan

    let par_begin = '^\(%D\)\=\s*\($\|\\begin\|\\end\|\\[\|\\]\|\\\(sub\)*section\>\|\\item\>\|\\NC\>\|\\blank\>\|\\noindent\>\)'
    let par_end   = '^\(%D\)\=\s*\($\|\\begin\|\\end\|\\[\|\\]\|\\\(sub\)*section\>\|\\item\>\|\\NC\>\|\\blank\>\|\\place\)'

    try
        execute '?' . par_begin . '?+'
    catch /E384/
        1
    endtry

    normal! V

    try
        execute '/' . par_end . '/-'
    catch /E385/
        $
    endtry

    normal! gq

    let &wrapscan = wrapscan_save
    call setpos('.', cursor_save)
endfunction

nnoremap <buffer> <silent> Q :call <SID>TeX_format()<CR>
