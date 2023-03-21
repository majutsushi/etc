" This is heavily modified from Dr. Chip's HiLinkTrace plugin.

function! s:syntax_info() abort
    let curline = line('.')
    let curcol  = col('.')

    let idlist = synstack(curline, curcol)
    if empty(idlist)
        echo 'No syntax found'
        return
    endif
    call map(idlist, 'synIDattr(v:val, "name")')
    let syntaxstack = join(idlist, ' -> ')

    let firstlink = synIDattr(synID(curline, curcol, 1), 'name')
    let translink = synIDattr(synID(curline, curcol, 0), 'name')
    let lastlink  = synIDattr(synIDtrans(synID(curline, curcol, 1)), 'name')

    " if transparent link isn't the same as the top highlighting link,
    " then indicate it with a leading 'T:'
    if firstlink != translink && firstlink != ''
        let hilink = 'T:' . translink . ' -> ' . firstlink
    elseif firstlink != translink
        let hilink = 'T:' . translink
    else
        let hilink = firstlink
    endif

    redir => hi_out
    silent! highlight
    redir END

    " trace through the linkages
    if firstlink != lastlink && firstlink != ''
        let no_overflow = 0
        let curlink = firstlink
        while curlink != lastlink && no_overflow < 10
            let nextlink = substitute(hi_out, '^.*\<' . curlink . '\s\+xxx links to \([A-Za-z_]\+\).*$', '\1', '')
            if nextlink =~ '\<start=\|\<cterm[fb]g=\|\<gui[fb]g='
                let nextlink = substitute(nextlink, '^[ \t\n]*\(\S\+\)\s\+.*$', '\1', '')
                let hilink = hilink . ' -> ' . nextlink
                break
            endif
            let hilink  = hilink . ' -> ' . nextlink
            let curlink = nextlink
            let no_overflow += 1
        endwhile
    endif

    echo 'Synstack:    ' syntaxstack
    echo 'Highlighting:' hilink
    if lastlink != ''
        execute 'highlight ' . lastlink
    endif
endfunction

nnoremap <leader>sy :call <SID>syntax_info()<CR>
