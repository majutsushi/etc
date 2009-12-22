" cmd.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-08-23.
" @Last Change: 2009-02-15.
" @Revision:    0.0.21

if &cp || exists("loaded_tlib_cmd_autoload")
    finish
endif
let loaded_tlib_cmd_autoload = 1


function! tlib#cmd#OutputAsList(command) "{{{3
    " let lines = ''
    redir => lines
    silent! exec a:command
    redir END
    return split(lines, '\n')
endf


" See |:TBrowseOutput|.
function! tlib#cmd#BrowseOutput(command) "{{{3
    let list = tlib#cmd#OutputAsList(a:command)
    let cmd = tlib#input#List('s', 'Output of: '. a:command, list)
    if !empty(cmd)
        call feedkeys(':'. cmd)
    endif
endf


" :def: function! tlib#cmd#UseVertical(?rx='')
" Look at the history whether the command was called with vertical. If 
" an rx is provided check first if the last entry in the history matches 
" this rx.
function! tlib#cmd#UseVertical(...) "{{{3
    TVarArg ['rx']
    let h0 = histget(':')
    let rx0 = '\C\<vert\%[ical]\>\s\+'
    if !empty(rx)
        let rx0 .= '.\{-}'.rx
    endif
    " TLogVAR h0, rx0
    return h0 =~ rx0
endf


" Print the time in seconds a command takes.
function! tlib#cmd#Time(cmd) "{{{3
    let start = localtime()
    exec a:cmd
    echom 'Time: '. (localtime() - start) .'s: '. a:cmd
endf

