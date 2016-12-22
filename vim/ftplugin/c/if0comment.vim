" Comment out code with #if 0/#endif
" Based on http://www.vim.org/scripts/script.php?script_id=637

xnoremap <silent> <buffer> <localleader>c :call <SID>If0comment()<CR>
nnoremap <silent> <buffer> <localleader>c :call <SID>If0uncomment()<CR>

function! <SID>If0comment() range
    call append((a:firstline - 1), "#if 0")
    call append(a:lastline + 1, "#endif")
endfunction

function! <SID>If0uncomment()
    let start = search('^#if 0', 'bcnW', 1)
    if start == 0
        echo 'No valid comment block found'
        return
    endif

    execute start . 'd'
    let emb = 0
    for linenr in range(start + 1, line('$'))
        let line = getline(linenr)

        if line =~ '^#if'
            let emb += 1
        elseif line =~ '^#else'
            if emb == 0
                " not an embedded else so turn else into an #if 0 to match
                " following #endif
                let newline = substitute(line, '^#else', '#if 0', '')
                call setline(linenr, newline)
                break
            endif
        elseif line =~ '^#endif'
            if emb > 0
                let emb -= 1
            else
                " found matching endif; remove it
                execute linenr . 'd'
                break
            endif
        endif
    endfor
endfunction

" vim: ts=4 sts=4 sw=4 et
