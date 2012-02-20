" Author       : Jan Larres <jan@majutsushi.net>
" Website      : https://github.com/majutsushi/
" Created      : 2012-02-20 14:48:17 +1300 NZDT
" Last changed : 2012-02-20 14:48:19 +1300 NZDT
"
" Based on http://vim.wikia.com/wiki/Make_footnotes_in_vim

if exists("loaded_footnotes")
    finish
endif
let loaded_footnotes = 1

let s:cpo_save = &cpo
set cpo&vim

imap <c-x>f <C-O>:call <SID>AddFootnote()<CR>

function! s:AddFootnote()
    if exists('b:footnotenr')
        let b:footnotenr += 1
        let cr = ""
    else
        let b:footnotenr = 1
        let cr = "\<cr>"
    endif

    execute "normal! i[" . b:footnotenr . "]\<esc>"

    belowright 3split
    normal G
    if search("^-- $", "bW")
        if len(cr) == 0
            execute "normal! \<up>"
        else
            execute "normal! O"
        endif
        execute "normal! O" . cr . "  [" . b:footnotenr . "] "
    else
        execute "normal! o" . cr . "  [" . b:footnotenr . "] "
    endif

    startinsert!
endfunction

let &cpo = s:cpo_save
