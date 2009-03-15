" Abook module for mail FTplugin
"
" Requires vim 6.x.
" To install place in ~/.vim/after/ftplugin/mail.vim
"
" Author: Brian Medley
" Email:  freesoftware@4321.tv
"
" Version:
"   $Revision: 1.1 $
"   $Date: 2002/02/23 22:36:53 $
"   $Source: /home/bmedley/.vim/after/ftplugin/RCS/mailAbook.mod,v $
"

" Only do this when not done yet for this buffer
if exists("b:did_mailAbook_module")
  finish
endif
let b:did_mailAbook_module = 1

let ABackup = @a

redir @a
silent! map <Plug>MailAliasList
redir END

" ms => main_script
let s:ms = @a
let s:ms = substitute(s:ms, '.*\(<SNR>\d\+_\).*', '\1', '')

nnoremap <buffer> <script> <Plug>Mail¬¬¬ <SID>MailModSrewyness
redir @a
silent! map <Plug>Mail¬¬¬
redir END

let sid = @a
let sid = substitute(sid, '.*\(<SNR>\d\+_\).*', '\1', '')

exe "call " . s:ms . 'RegisterModule(sid . "AliasQueryAbook")'
exe "call " . s:ms . 'RegisterModule(sid . "AliasListAbook")'

let @a = ABackup
unlet ABackup
unlet sid

"
" Description:
" This routine assumes that user has the cursor on an alias to lookup.  Based
" on this it:
" - retrieves the alias(es) from abook
" - parses the output from abook
" - actually replaces the alias with the parsed output
"
if !exists("*s:AliasQueryAbook")
function s:AliasQueryAbook()
    let b:AliasQueryMsg = ""

    " - retrieves the alias(es) from abook
    let lookup=expand("<cword>")
    if "" == lookup
        let b:AliasQueryMsg = "Nothing found to lookup"
        return
    endif

    silent exe 'let output=system("abook --mutt-query ' . lookup . '")'
    if v:shell_error
        let b:AliasQueryMsg = output
        return
    endif

    " - parses the output from abook
    exe "let addrs=" . s:ms . "ParseMuttQuery(output)"
    if "" == addrs
        let b:AliasQueryMsg = b:ParseMuttQueryErr
        return
    endif

    " so that they will be aligned under the 'to' or 'cc' line
    let addrs=substitute(addrs, "\n", ",\n    ", "g")

    exe "call " . s:ms . "ReplaceWord(addrs)"
endfunction
endif

"
" Description:
" This routine will launch abook and spit out what the user selected from the
" application (by pressing 'Q').  It's always called from 'insert' mode, so
" the text will be inserted like it was typed.
"
" That's why 'paste' is set and reset.  So that the text that we insert won't
" be 'mangled' by the user's settings.
"
if !exists("*s:AliasListAbook")
function s:AliasListAbook()
    let b:AliasListMsg = ""
    let f = tempname()

    set paste
    silent exe '!abook 2> ' . f
    exe 'let addresses=system("cat ' . f . '")'
    if "" == addresses
        let b:AliasListMsg = "Nothing found to lookup"
        return ""
    endif

    " - parses the output from abook
    exe "let addresses=" . s:ms . "ParseMuttQuery(addresses)"
    if "" == addresses
        let b:AliasListMsg = b:ParseMuttQueryErr
        return ""
    endif

    " so that they will be aligned under the 'to' or 'cc' line
    let addresses=substitute(addresses, "\n", ",\n    ", "g")

    return addresses
endfunction
endif

" vim: ft=vim
