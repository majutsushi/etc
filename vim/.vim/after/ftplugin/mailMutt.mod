" mutt module for mail FTplugin
"
" Requires vim 6.x.
" To install place in ~/.vim/after/ftplugin/mail.vim
"
" Author: Brian Medley
" Email:  freesoftware@4321.tv
"
" Version:
"   $Revision: 1.4 $
"   $Date: 2003/11/06 04:19:04 $
"   $Source: /Users/bpm/.vim/after/ftplugin/RCS/mailMutt.mod,v $
"

" Only do this when not done yet for this buffer
if exists("b:did_mailMutt_module")
  finish
endif
let b:did_mailMutt_module = 1

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

exe "call " . s:ms . 'RegisterModule(sid . "AliasQueryMuttAlias")'
exe "call " . s:ms . 'RegisterModule(sid . "AliasListMuttAlias")'

exe "call " . s:ms . 'RegisterModule(sid . "AliasQueryMuttQuery")'
exe "call " . s:ms . 'RegisterModule(sid . "AliasListMuttQuery")'

let @a = ABackup
unlet ABackup
unlet sid

"
" Description:
" This routine assumes that user has the cursor on an alias to lookup.  Based
" on this it:
" - retrieves the alias(es) from the mutt alias file
" - actually replaces the alias with the parsed output
"
" Thanx for Luc Hermitte <hermitte@free.fr> for this:
"  <URL:http://hermitte.free.fr/vim/>
"
if !exists("*s:AliasQueryMuttAlias")
function s:AliasQueryMuttAlias()
    let b:AliasQueryMsg = ""
    exe "let mutt_alias_file = " . s:ms . "ScriptVar('mutt_alias_file')"

    " - retrieves the alias(es) from the mutt alias file
    let lookup=expand("<cword>")
    if "" == lookup
        let b:AliasQueryMsg = "Nothing found to lookup"
        return
    endif

    " get rid of comments (which could be confused w/ cpp directives) and run
    " thourgh cpp to take care of line continuation
    let cmd = "sed 's/\\#.*//' " . mutt_alias_file . " | cpp | "
    " get rid of 'stuff' added on by cpp
    let cmd = cmd . "sed -e 's/\\#.*//' | "
    " actually look for alias
    let cmd = cmd . "grep 'alias[\t ]*" . lookup . "[\t ]' "
    silent exe 'let output=system("' . cmd . '")'
    if v:shell_error
        let b:AliasQueryMsg = output
        return
    endif

    let msk = "\\(<\\|\\)\\([+a-zA-Z0-9._-]\\+@[a-zA-Z0-9./-]\\+\\)\\(>\\|\\)"
    let expansion = ""
    while 1
        let line = matchstr(output, ".\\{-}\n")

        let addr = substitute(line, "alias\\s\\+\\S\\+\\s*", "", "")
        let name = substitute(addr, msk, "", "")
        let addr = matchstr(addr, msk)
        if "" == addr
            let b:AliasQueryMsg = "Unable to parse address from ouput '" . line . "'"
            return
        endif
        let name = substitute(name, "\n", "", "")
        let name = substitute(name, "\\((\\|)\\)", "", "g") " remove parens
        let name = substitute(name, "^\\s\\+", "", "")
        let name = substitute(name, "\\s\\+$", "", "")
        let addr = substitute(addr, "\n", "", "")
        if -1 == match(addr, "<")
            let addr = "<" . addr . ">"
        endif
        let expansion = expansion . name . " " . addr

        " get next line or quit processing if none
        let output = substitute(output, ".\\{-}\n", "", "")
        if "" == output
            let b:AliasQueryMsg = ""
            break
        endif

        let expansion = expansion . ",\n    "
    endwhile

    " - actually replaces the alias with the parsed output
    exe "call " . s:ms . "ReplaceWord(expansion)"
endfunction
endif

"
" Description:
" This routine is a placeholder to show that we don't support getting an
" alias list from mutt alias files.
"
if !exists("*s:AliasListMuttAlias")
function s:AliasListMuttAlias()
    let b:AliasListMsg = "Can't get list from mutt alias file.  Use a query."

    return ""
endfunction
endif

"
" Description:
" This routine assumes that user has the cursor on an alias to lookup.  Based
" on this it:
" - retrieves the alias(es) from the user defined mutt query command
" - actually replaces the alias with the parsed output
"
if !exists("*s:AliasQueryMuttQuery")
function s:AliasQueryMuttQuery()
    let b:AliasQueryMsg = ""
    exe "let cmd = " . s:ms . "ScriptVar('mail_mutt_query_command')"

    " - retrieves the alias(es) from the mutt external cmd
    let lookup=expand("<cword>")
    if "" == lookup
        let b:AliasQueryMsg = "Nothing found to lookup"
        return
    endif

    let cmd = cmd . " " . lookup
    silent exe 'let output=system("' . cmd . '")'
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
" This routine is a placeholder to show that we don't support getting an
" alias list from mutt query cmd.
"
if !exists("*s:AliasListMuttQuery")
function s:AliasListMuttQuery()
    let b:AliasListMsg = "Can't get list from mutt query cmd.  Use a query."

    return ""
endfunction
endif
" vim: ft=vim
