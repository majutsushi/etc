" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2011-02-26 15:32:56 +1300 NZDT
" Last changed : 2011-02-26 15:32:56 +1300 NZDT

" Reformat lines (getting the spacing correct)
function! TeX_fmt()
    if (getline(".") != "")
        let save_cursor = getpos(".")
        let op_wrapscan = &wrapscan
        set nowrapscan

        let par_begin = '^\(%D\)\=\s*\($\|\\begin\|\\end\|\\[\|\\]\|\\\(sub\)*section\>\|\\item\>\|\\NC\>\|\\blank\>\|\\noindent\>\)'
        let par_end = '^\(%D\)\=\s*\($\|\\begin\|\\end\|\\[\|\\]\|\\place\|\\\(sub\)*section\>\|\\item\>\|\\NC\>\|\\blank\>\)'

        try
            exe '?'.par_begin.'?+'
        catch /E384/
            1
        endtry

        norm V

        try
            exe '/'.par_end.'/-'
        catch /E385/
            $
        endtry

        norm gq

        let &wrapscan = op_wrapscan
        call setpos('.', save_cursor)
    endif
endfunction

nmap <buffer> <silent> Q :call TeX_fmt()<CR>
