function! s:detect()
    if getline(1) =~ '^\d\{4}-\d\{2}-\d\{2} \+\d\{2}:\d\{2}:\d\{2},\d\{3} \+\[[^]]\+\]\+ \+\w\+ \+\S\+ \+-'
        setfiletype scenlog
    endif
endfunction
autocmd BufNewFile,BufRead * call s:detect()
