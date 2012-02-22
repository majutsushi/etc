" mailcomplete.vim -- Omni-completion for mails using lbdb
" Author       : Jan Larres <jan@majutsushi.net>
" License      : GPLv3
" Created      : 2012-02-22 14:10:50 +1300 NZDT
" Last changed : 2012-02-22 14:10:51 +1300 NZDT
"
" Based on http://www.vim.org/scripts/script.php?script_id=1757
" and http://dollyfish.net.nz/blog/2008-04-01/mutt-and-vim-custom-autocompletion

function! mailcomplete#Complete(findstart, base)
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1

        while start > 0 && line[start - 1] =~ '[^:,]'
          let start -= 1
        endwhile

        while start < col('.') && line[start] =~ '[:, ]'
            let start += 1
        endwhile

        return start
    else
        let result = []
        let query = substitute(a:base, '"', '', 'g')
        let query = substitute(query, '\s*<.*>\s*', '', 'g')

        for m in s:LbdbQuery(query)
            call add(result, printf('%s <%s>', m[0], m[1]))
        endfor

        return result
    endif
endfunction

" queries lbdb with a query string and return a list of pairs:
" [['full name', 'email'], ['full name', 'email'], ...]
function! s:LbdbQuery(qstring)
    let output = system("lbdbq '" . a:qstring . "'")
    let results = []

    for line in split(output, "\n")[1:] " skip first line (lbdbq summary)
        let fields = split(line, "\t")
        let results += [ [fields[1], fields[0]] ]
    endfor

    return results
endfunction
