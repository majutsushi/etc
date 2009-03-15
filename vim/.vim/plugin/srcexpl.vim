
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" File Name:      srcexpl.vim
" Abstract:       A (G)VIM plugin for exploring the source code based on 
"                 'tags' and 'quickfix'. It works like the context window 
"                 in the Source Insight.
" Author:         CHE Wenlong <chewenlong AT buaa.edu.cn>
" Version:        3.1
" Last Change:    August 18, 2008

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" The_setting_example_in_my_vimrc_file:-)

" // The switch of the Source Explorer
" nmap <F8> :SrcExplToggle<CR>

" // Set the window height of Source Explorer
" let g:SrcExpl_winHeight = 9

" // Set 300 ms for refreshing the Source Explorer
" let g:SrcExpl_refreshTime = 100

" // Let the Source Explorer update the tags file when opening
" let g:SrcExpl_updateTags = 1

" // Set "Space" key for refresh the Source Explorer manually
" let g:SrcExpl_refreshKey = "<Space>"

" // Set "Ctrl-d" key for back from the definition context
" let g:SrcExpl_gobackKey = "<C-d>"

" // In order to Aviod conflicts, the Source Explorer should know what plugins
" // are using buffers. And you need add their bufnames into the list below 
" // according to the command ":buffers!"
" let g:SrcExpl_pluginList = [
"         \ "__Tag_List__", 
"         \ "_NERD_tree_", 
"         \ "Source_Explorer"
"     \ ]

" // Enable or disable local definition searching, and note that this is not 
" // guaranteed to work, the Source Explorer does not check the syntax for now, 
" // it only searches for a match with the keyword according to the command 'gd'.
" let g:SrcExpl_searchLocalDef = 1

" Just_change_above_of_them_by_yourself:-)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" NOTE: The graph below shows my work platform with some VIM plugins, 
"       including 'Taglist', 'Source Explorer', and 'NERD tree'. And
"       I usually use the 'Trinity' plugin to manage them.

" +---------------------------------------------------------------------------+
" |---------------------------------------------------------------------------|
" |-demo.c--------|------------------------------------------|-/home/myprj----|
" |               |                                          |                |
" |function       |/* This is the edit window. */            |~ test/         |
" |  foo          |                                          ||               |
" |  bar          |void foo(void)                            |`-demo.c        |
" |               |{                                         |                |
" |~              |}                                         |~               |
" |~              |                                          |~               |
" |~              |void bar(void)                            |~               |
" |~              |{                                         |~               |
" |~              |}                                         |~               |
" |~              |                                          |~               |
" |~              |~                                         |~               |
" |-__Tag_List__--|-demo.c-----------------------------------|--_NERD_tree_---|
" |Source Explorer V3.1                                                       |
" |~                                                                          |
" |~                                                                          |
" |~                                                                          |
" |~                                                                          |
" |-Source_Explorer-----------------------------------------------------------|
" |:TrinityToggleAll                                                          |
" +---------------------------------------------------------------------------+

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Avoid reloading {{{

if exists('loaded_srcexpl')
    finish
endif

let loaded_srcexpl = 1
let s:save_cpo = &cpoptions

" }}}

" VIM version control {{{

" The VIM version control for running the Source Explorer

if v:version < 700
    echohl ErrorMsg
    echo "SrcExpl: Require VIM 7.0 or above for running the Source Explorer."
    echohl None
    finish
endif

set cpoptions&vim

" }}}

" User interfaces {{{

" User interface for opening the Source Explorer

command! -nargs=0 -bar SrcExpl 
    \ call <SID>SrcExpl()

" User interface for closing the Source Explorer

command! -nargs=0 -bar SrcExplClose 
    \ call <SID>SrcExpl_Close()

" User interface for switching the Source Explorer

command! -nargs=0 -bar SrcExplToggle 
    \ call <SID>SrcExpl_Toggle()

" User interface for changing the 
" height of the Source Explorer Window
if !exists('g:SrcExpl_winHeight')
    let g:SrcExpl_winHeight = 10
endif

" User interface for setting the 
" update time interval of each refreshing
if !exists('g:SrcExpl_refreshTime')
    let g:SrcExpl_refreshTime = 100
endif

" User interface to update the 'tags'
" file when loading the Source Explorer
if !exists('g:SrcExpl_updateTags')
    let g:SrcExpl_updateTags = 0
endif

" User interface to go back from 
" the definition context
if !exists('g:SrcExpl_gobackKey')
    let g:SrcExpl_gobackKey = ''
endif

" User interface for refreshing one
" definition searching manually
if !exists('g:SrcExpl_refreshKey')
    let g:SrcExpl_refreshKey = ''
endif

" User interface for handling the 
" conflicts between the Source Explorer
" and other plugins
if !exists('g:SrcExpl_pluginList')
    let g:SrcExpl_pluginList = [
            \ "__Tag_List__", 
            \ "_NERD_tree_", 
            \ "Source_Explorer"
        \ ]
endif

" User interface for enable local Declaration
" searching according to command 'gd'
if !exists('g:SrcExpl_searchLocalDef')
    let g:SrcExpl_searchLocalDef = 1
endif

" }}}

" Global variables {{{

" Mark List for tag the flow of exploring
let s:SrcExpl_markList  = [
        \ "A", "B", "C", "D", "E", 
        \ "F", "G", "H", "I", "J", 
        \ "K", "L", "M", "N", "O", 
        \ "P", "Q", "R", "S", "T", 
        \ "U", "V", "W", "X", "Y", "Z"
    \ ]

" Buffer title for buffer listing
let s:SrcExpl_title     =   'Source_Explorer'

" The log file path for debug
let s:SrcExpl_logPath   =   './srcexpl.log'

" The whole path of 'tags' file
let s:SrcExpl_tagsPath  =   ''

" The key word symbol for exploring
let s:SrcExpl_symbol    =   ''

" Original work path when initializing
let s:SrcExpl_workPath  =   ''

" The whole file path being explored now
let s:SrcExpl_currPath  =   ''

" Line number of the current word under the cursor
let s:SrcExpl_currLine  =   0

" Column number of the current word under the cursor
let s:SrcExpl_currCol   =   0

" Line number of the current cursor
let s:SrcExpl_cursorLine=   0

" Debug Switch for logging the debug information
let s:SrcExpl_debug     =   0

" Mark index to get the real item
let s:SrcExpl_markIndex =   0

" ID number of srcexpl.vim
let s:SrcExpl_scriptID  =   0

" The edit window position
let s:SrcExpl_editWin   =   0

" Source Explorer switch flag
let s:SrcExpl_opened    =   0

" Source Explorer status:
" 0: No such tag definition
" 1: One definition
" 2: Multiple definitions
" 3: Local definition
let s:SrcExpl_status    =   0

" }}}

" SrcExpl_Debug() {{{

" Record the supplied debug information log along with the time

function! <SID>SrcExpl_Debug(log)

    " Debug switch is on
    if s:SrcExpl_debug == 1
        " Log file path is valid
        if s:SrcExpl_logPath != ''
            " Output to the log file
            echo s:SrcExpl_logPath
            exe "redir >> " . s:SrcExpl_logPath
            " Add the current time
            silent echon strftime("%H:%M:%S") . ": " . a:log . "\n"
            redir END
        endif
    endif

endfunction " }}}

" SrcExpl_GoBack() {{{

" Move the cursor to the previous location in the mark history

function! g:SrcExpl_GoBack()

    if (!&previewwindow)
        " Jump back to the previous position
        call <SID>SrcExpl_GetMark()
        " Open the folding if exists
        if has("folding")
            silent! . foldopen!
        endif
    endif

endfunction " }}}

" SrcExpl_EnterWin() {{{

" Opreation when WinEnter Event happens

function! <SID>SrcExpl_EnterWin()

    " If or not the cursor is on the edit window
    let l:rtn = <SID>SrcExpl_AdaptPlugins()

    " In the Source Explorer
    if (&previewwindow) || (l:rtn != 0)
        if has("gui_running")
            " Delete the SrcExplGoBack item in Popup menu
            silent! nunmenu 1.01 PopUp.&SrcExplGoBack
            " Do the mapping for 'double-click' and 'enter'
            if maparg('<2-LeftMouse>', 'n') == ''
                nnoremap <silent> <2-LeftMouse> 
                    \ :call <SID>SrcExpl_Jump()<CR>
            endif
        endif
        if maparg('<CR>', 'n') == ''
            nnoremap <silent> <CR> :call <SID>SrcExpl_Jump()<CR>
        endif
    " Other windows
    else
        if has("gui_running")
            " You can use SrcExplGoBack item in Popup menu
            " to go back from the definition
            silent! nnoremenu 1.01 PopUp.&SrcExplGoBack 
                \ :call g:SrcExpl_GoBack()<CR>
            " Unmapping the exact mapping of 'double-click' and 'enter'
            if maparg("<2-LeftMouse>", "n") == 
                    \ ":call <SNR>" . s:SrcExpl_scriptID . 
                \ "SrcExpl_Jump()<CR>"
                nunmap <silent> <2-LeftMouse>
            endif
        endif
        if maparg("<CR>", "n") == ":call <SNR>" . 
            \ s:SrcExpl_scriptID . "SrcExpl_Jump()<CR>"
            nunmap <silent> <CR>
        endif
    endif

endfunction " }}}

" SrcExpl_SetCurr() {{{

" Save the current buf-win file path, line number and column number

function! <SID>SrcExpl_SetCurr()

    " Get the whole file path of the buffer before tag
    let s:SrcExpl_currPath = expand("%:p")
    " Get the current line before tag
    let s:SrcExpl_currLine = line(".")
    " Get the current column before tag
    let s:SrcExpl_currCol = col(".")

endfunction " }}}

" SrcExpl_SetMark() {{{

" Set the mark for back to the previous position

function! <SID>SrcExpl_SetMark()

    " Get the line number of previous mark
    let l:line = line("'" . s:SrcExpl_markList[s:SrcExpl_markIndex])
    " Get the column number of previous mark
    let l:col = col("'" . s:SrcExpl_markList[s:SrcExpl_markIndex])
    " Avoid the same situation
    if l:line == line(".") && l:col == col(".")
        return
    endif
    " Update new mark position index
    let s:SrcExpl_markIndex += 1
    " Out of the list range
    if s:SrcExpl_markIndex == len(s:SrcExpl_markList)
        let s:SrcExpl_markIndex = 0
    endif
    " Record the next mark position
    exe "normal " . "m" . s:SrcExpl_markList[s:SrcExpl_markIndex]

endfunction " }}}

" SrcExpl_GetMark() {{{

" Get the mark for back to the previous position

function! <SID>SrcExpl_GetMark()

    " Delete the current mark
    exe "delmarks " . s:SrcExpl_markList[s:SrcExpl_markIndex]
    " Back to the previous position index
    let s:SrcExpl_markIndex -= 1
    " Back to the top of the mark stack
    if s:SrcExpl_markIndex == -1
        " Reinitialize the index
        let s:SrcExpl_markIndex = len(s:SrcExpl_markList) - 1
    endif
    try
        " Back to the previous position immediately
        exe "normal " . "`" . s:SrcExpl_markList[s:SrcExpl_markIndex]
    catch
        " There is no mark on the previous cursor
        let s:SrcExpl_markIndex = 0
        " Tell the user what has happened
        echohl ErrorMsg
        echo "SrcExpl: Mark stack is empty."
        echohl None
    endtry

endfunction " }}}

" SrcExpl_FilterExcmd() {{{

" Filter the Ex command information

function! <SID>SrcExpl_FilterExcmd(raw)

    let l:idx = 0
    let l:new = ""

    " Get the EX symbol in order to jump
    while a:raw[l:idx] != ''
        " If the '*', '[' and ']' in the function definition,
        " then we add the '\' in front of it.
        if (a:raw[l:idx] == '*')
            let l:new = l:new . '\' . '*'
        elseif (a:raw[l:idx] == '[')
            let l:new = l:new . '\' . '['
        elseif (a:raw[l:idx] == ']')
            let l:new = l:new . '\' . ']'
        else
            let l:new = l:new . a:raw[l:idx]
        endif
        let l:idx += 1
    endwhile

    return l:new

endfunction " }}}

" SrcExpl_SelToJump() {{{

" Select one of multi-definitions, and jump to there

function! <SID>SrcExpl_SelToJump()

    let l:index = 0
    let l:fname = ""
    let l:excmd = ""

    if !&previewwindow
        silent! wincmd P
    endif
    " If point to the Jump list head, just avoid that
    if line(".") == 1
        return
    endif
    " Get the item data that user selected
    let l:list = getline(".")
    " Traverse the prompt string until get the 
    " file path
    while !((l:list[l:index] == ']') && 
        \ (l:list[l:index + 1] == ':'))
        let l:index += 1
    endwhile
    " Done
    let l:index += 3
    " Get the whole file path of the exact definition
    while !((l:list[l:index] == ' ') && 
        \ (l:list[l:index + 1] == '[')) 
        let l:fname = l:fname . l:list[l:index]
        let l:index += 1
    endwhile
    " Done
    let l:index += 2
    " Traverse the prompt string until get the symbol
    while !((l:list[l:index] == ']') && 
        \ (l:list[l:index + 1] == ':'))
        let l:index += 1
    endwhile
    " Done
    let l:index += 3
    " Get the EX command string
    while l:list[l:index] != ''
        let l:excmd = l:excmd . l:list[l:index]
        let l:index += 1
    endwhile
    " Indeed go back to the edit window
    silent! exe s:SrcExpl_editWin . "wincmd w"
    " Open the file of definition context
    exe "edit " . s:SrcExpl_tagsPath . l:fname
    " Use Ex Command to Jump to the exact position of the definition
    silent! exe <SID>SrcExpl_FilterExcmd(l:excmd)
    call <SID>SrcExpl_MatchExpr()

endfunction " }}}

" SrcExpl_Jump() {{{

" Jump to the edit window and point to the definition

function! <SID>SrcExpl_Jump()

    " Only do the operation on the Source Explorer 
    " window is valid
    if !&previewwindow
        return
    endif
    " Do we get the definition already?
    if (bufname("%") == s:SrcExpl_title)
        if s:SrcExpl_status == 0 " No definition
            return
        endif
    endif
    " Indeed go back to the edit window
    silent! exe s:SrcExpl_editWin . "wincmd w"
    " Set the mark for recording the current position
    call <SID>SrcExpl_SetMark()
    " We got multiple definitions
    if s:SrcExpl_status == 2
        call <SID>SrcExpl_SelToJump()
        " Set the mark for recording the current position
        call <SID>SrcExpl_SetMark()
        return
    endif
    " Open the buffer using edit window
    exe "edit " . s:SrcExpl_currPath
    " Jump to the context line of that symbol
    call cursor(s:SrcExpl_currLine, s:SrcExpl_currCol)
    " Match the Symbol of definition
    call <SID>SrcExpl_MatchExpr()
    " Set the mark for recording the current position
    call <SID>SrcExpl_SetMark()
    " We got one local definition
    if s:SrcExpl_status == 3
        " Get the cursor line number
        let s:SrcExpl_cursorLine = line(".")
        " Try to tag the symbol again
        let l:expr = '\C\<' . s:SrcExpl_symbol . '\>'
        let l:rslt = <SID>SrcExpl_TryToTag(l:expr)
        redraw
        silent! exe s:SrcExpl_editWin . "wincmd w"
    endif

endfunction " }}}

" SrcExpl_MatchExpr() {{{

" Match the Symbol of definition

function! <SID>SrcExpl_MatchExpr()

    " First open the folding if exists
    if has("folding")
        silent! . foldopen!
    endif
    " Match the symbol
    call search("$", "b")
    let s:SrcExpl_symbol = substitute(s:SrcExpl_symbol, 
        \ '\\', '\\\\', "")
    call search('\V\C\<' . s:SrcExpl_symbol . '\>')

endfunction " }}}

" SrcExpl_HiExpr() {{{

" Highlight the Symbol of definition

function! <SID>SrcExpl_HiExpr()

    " Set the highlight color
    hi SrcExpl_HighLight term=bold guifg=Black guibg=Magenta ctermfg=Black ctermbg=Magenta
    " Highlight
    exe 'match SrcExpl_HighLight "\%' . line(".") . 'l\%' . 
        \ col(".") . 'c\k*"'

endfunction " }}}

" SrcExpl_TryToGoDecl() {{{

" Search the local declaration

function! <SID>SrcExpl_TryToGoDecl(expr)

    " Get the original cursor position
    let l:oldline = line(".")
    let l:oldcol = col(".")
    " Try to search the local declaration
    if searchdecl(a:expr, 0, 1) != 0
        " Search failed
        return -1
    endif
    " Get the new cursor position
    let l:newline = line(".")
    let l:newcol = col(".")
    " Go back to the original cursor position
    call cursor(l:oldline, l:oldcol)
    " Preview the context
    exe "silent " . "pedit " . expand("%:p")
    " Go to the Preview window
    silent! wincmd P
    " Indeed in the Preview window
    if &previewwindow
        " Go to the new cursor position
        call cursor(l:newline, l:newcol)
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_HiExpr()
        " Set the current buf-win property
        call <SID>SrcExpl_SetCurr()
    endif
    " Search successfully
    return 0

endfunction " }}}

" SrcExpl_NoteNoDef() {{{

" The User Interface function to open the Source Explorer

function! <SID>SrcExpl_NoteNoDef()

    " Do the Source Explorer existed already?
    let l:bufnum = bufnr(s:SrcExpl_title)
    " Not existed
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_title
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif
    " Reopen the Source Explorer idle window
    exe "silent " . "pedit " . l:wcmd
    " Move to it
    silent! wincmd P
    if &previewwindow
        " First make it modifiable
        setlocal modifiable
        setlocal buflisted
        setlocal buftype=nofile
        " Report the reason why Source Explorer
        " can not point to the definition
        " Delete all lines in buffer.
        1,$d _
        " Goto the end of the buffer put the buffer list
        $
        " Display the version of the Source Explorer
        put! ='Definition Not Found'
        " Cancel all the highlighted words
        match none
        " Delete the extra trailing blank line
        $ d _
        " Make it unmodifiable again
        setlocal nomodifiable
    endif
    return 0

endfunction " }}}

" SrcExpl_ListMultiDefs() {{{

" List Multiple definitions into the preview window

function! <SID>SrcExpl_ListMultiDefs(list, len)

    " Does the Source Explorer existed already?
    let l:bufnum = bufnr(s:SrcExpl_title)
    " Create a new buffer
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = s:SrcExpl_title
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif
    " Reopen the Source Explorer idle window
    exe "silent " . "pedit " . l:wcmd
    " Return to the preview window
    silent! wincmd P
    " Done
    if &previewwindow
        " Reset the property of the Source Explorer
        setlocal modifiable
        setlocal buflisted
        setlocal buftype=nofile
        " Delete all lines in buffer
        1,$d _
        " Get the tags dictionary array
        " Begin build the Jump List for exploring the tags
        put! = '[Jump List]: '. s:SrcExpl_symbol . ' (' . a:len . ') '
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_HiExpr()
        " Loop key & index
        let l:indx = 0
        " Loop for listing each tag from tags file
        while 1
            " First get each tag list
            let l:dict = get(a:list, l:indx, {})
            " There is one tag
            if l:dict != {}
                " Goto the end of the buffer put the buffer list
                $
                put! ='[File Name]: '. l:dict['filename']
                    \ . ' ' . '[Ex Command]: ' . l:dict['cmd']
            else " Traversal finished
                break
            endif
            let l:indx += 1
        endwhile
    endif
    " Delete the extra trailing blank line
    $ d _
    " Move the cursor to the top of the Source Explorer window
    exe "normal! gg"
    " Back to the first line
    setlocal nomodifiable
    return 0

endfunction " }}}

" SrcExpl_ViewOneDef() {{{

" Display the definition of the symbol into the preview window

function! <SID>SrcExpl_ViewOneDef(fname, excmd)

    " Open the file first
    exe "silent " . "pedit " . a:fname
    " Go to the Source Explorer window
    silent! wincmd P
    " Indeed back to the preview window
    if &previewwindow
        " Execute EX command according to the parameter
        silent! exe <SID>SrcExpl_FilterExcmd(a:excmd)
        " Just avoid highlight
        silent! /\<\>
        " Match the symbol
        call <SID>SrcExpl_MatchExpr()
        " Highlight the symbol
        call <SID>SrcExpl_HiExpr()
        " Set the current buf-win property
        call <SID>SrcExpl_SetCurr()
    endif
    return 0

endfunction " }}}

" SrcExpl_TryToTag() {{{

" Just try to find the tag under the cursor

function! <SID>SrcExpl_TryToTag(expr)

    " Function calling result
    let l:rslt = -1
    " We get the tag list of the expression
    let l:list = taglist(a:expr)
    " Then get the length of taglist
    let l:len = len(l:list)
    " No tag
    if l:len <= 0
        " No definition
        let s:SrcExpl_status = 0
        let l:rslt = <SID>SrcExpl_NoteNoDef()
    " One tag
    elseif l:len == 1
        " One definition
        let s:SrcExpl_status = 1
        " Get dictionary to load tag's file name and ex command
        let l:dict = get(l:list, 0, {})
        let l:rslt = <SID>SrcExpl_ViewOneDef(l:dict['filename'], l:dict['cmd'])
    " Multiple tags list
    else
        " Multiple definitions
        let s:SrcExpl_status = 2
        let l:rslt = <SID>SrcExpl_ListMultiDefs(l:list, l:len)
    endif
    return l:rslt

endfunction " }}}

" SrcExpl_GetSymbol() {{{

" Get the valid symbol under the current cursor

function! <SID>SrcExpl_GetSymbol()

    " Get the current character under the cursor
    let l:cchar = getline(".")[col(".") - 1]
    " Get the current word under the cursor
    let l:cword = expand("<cword>")

    " Judge that if or not the character is invalid,
    " because only 0-9, a-z, A-Z, and '_' are valid
    if (l:cchar =~ '\w') && (l:cword =~ '\w')
        " If the key word symbol has been explored
        " just now, we will not explore that again
        if s:SrcExpl_symbol ==# l:cword
            " Not in Local definition searching mode
            if g:SrcExpl_searchLocalDef == 0
                return -1
            else
                " The cursor is not moved actually
                if s:SrcExpl_cursorLine == line(".")
                    return -2
                endif
            endif
        endif
        " Get the cursor line number
        let s:SrcExpl_cursorLine = line(".")
        " Get the symbol word under the cursor
        let s:SrcExpl_symbol = l:cword
    " Invalid character
    else
        if s:SrcExpl_symbol == ''
            return -3 " Second, third ...
        else " First
            let s:SrcExpl_symbol = ''
        endif
    endif
    return 0

endfunction " }}}

" SrcExpl_AdaptPlugins() {{{

" The Source Explorer window will not work when the cursor on the 

" window of other plugins, such as 'Taglist', 'NERD tree' etc.

function! <SID>SrcExpl_AdaptPlugins()

    " Traversal the list of other plugins
    for item in g:SrcExpl_pluginList
        " If they acted as a split window
        if bufname("%") ==# item
            " Just avoid this operation
            return 1
        endif
    endfor
    " Safe
    return 0

endfunction " }}}

" SrcExpl_Refresh() {{{

" Refresh the Source Explorer window and update the status

function! g:SrcExpl_Refresh()

    let l:rslt = -1
    let l:expr = ""

    " If or not the cursor is on the edit window
    let l:rslt = <SID>SrcExpl_AdaptPlugins()
    if l:rslt != 0
        return
    endif
    " Only Source Explorer window is valid 
    if &previewwindow
        return
    endif
    " Avoid errors of multi-buffers
    if &modified
        echohl ErrorMsg
        echo "SrcExpl: The modified file is not saved."
        echohl None
        return
    endif

    " Get the edit window position
    let s:SrcExpl_editWin = winnr()
    " Get the symbol under the cursor
    let l:rslt = <SID>SrcExpl_GetSymbol()
    " The symbol is invalid
    if l:rslt < 0
        return
    endif
    " call <SID>SrcExpl_Debug('s:SrcExpl_symbol is (' . s:SrcExpl_symbol . ')')
    let l:expr = '\C\<' . s:SrcExpl_symbol . '\>'
    " Try to Go to local declaration
    if g:SrcExpl_searchLocalDef != 0
        let l:rslt = <SID>SrcExpl_TryToGoDecl(l:expr)
    else
        let l:rslt = -1
    endif
    if l:rslt >= 0
        " We got a local definition
        let s:SrcExpl_status = 3
    else
        " Try to tag
        let l:rslt = <SID>SrcExpl_TryToTag(l:expr)
    endif
    redraw
    silent! exe s:SrcExpl_editWin . "wincmd w"

endfunction " }}}

" SrcExpl_GetInput() {{{

" Get the word inputed by user on the command line window

function! <SID>SrcExpl_GetInput(note)

    " Be sure synchronize
    call inputsave()
    " Get the input content
    let l:input = input(a:note)
    " Save the content
    call inputrestore()
    " Tell SrcExpl
    return l:input

endfunction " }}}

" SrcExpl_ProbeTags() {{{

" Probe if or not there is a 'tags' file under the project PATH

function! <SID>SrcExpl_ProbeTags()

    " First get current work directory
    let l:tmp = getcwd()

    " Get the raw work path
    if l:tmp != s:SrcExpl_workPath
        " First load Source Explorer
        if s:SrcExpl_workPath == ""
            " Save that
            let s:SrcExpl_workPath = l:tmp
        endif
        " Go to the raw work path
        exe "cd " . s:SrcExpl_workPath
    endif

    let l:tmp = ""

    " Loop to probe the tags in CWD
    while !filereadable("tags")
        " First save
        let l:tmp = getcwd()
        " Up to my parent directory
        cd ..
        " Have been up to the system root directory
        if l:tmp == getcwd()
            " So break out
            break
        endif
    endwhile
    " Indeed in the system root directory
    if l:tmp == getcwd()
        " Clean the buffer
        let s:SrcExpl_tagsPath = ""
    " Have found a 'tags' file already
    else
        " UNIXs OS or MAC OS-X
        if has("unix") || has("macunix")
            if getcwd()[strlen(getcwd()) - 1] != '/'
                let s:SrcExpl_tagsPath = 
                    \ getcwd() . '/'
            endif
        " WINDOWS 95/98/ME/NT/2000/XP
        elseif has("win32")
            if getcwd()[strlen(getcwd()) - 1] != '\'
                let s:SrcExpl_tagsPath = 
                    \ getcwd() . '\'
            endif
        else
            " Other operating system
            echohl ErrorMsg
            echo "SrcExpl: Not support on this OS platform for now."
            echohl None
        endif
    endif

    call <SID>SrcExpl_Debug("s:SrcExpl_tagsPath is (" . s:SrcExpl_tagsPath . ")")

endfunction " }}}

" SrcExpl_CloseWin() {{{

" Close the Source Explorer window and delete its buffer

function! <SID>SrcExpl_CloseWin()

    " Just close the preview window
    pclose
    " Judge if or not the Source Explorer
    " buffer had been deleted
    let l:bufnum = bufnr(s:SrcExpl_title)
    " Existed indeed
    if l:bufnum != -1
        exe "bdelete! " . s:SrcExpl_title
    endif

endfunction " }}}

" SrcExpl_OpenWin() {{{

" Open the Source Explorer window under the bottom of (G)Vim,
" and set the buffer's property of the Source Explorer

function! <SID>SrcExpl_OpenWin()

    " Get the edit window position
    let s:SrcExpl_editWin = winnr()

    " Open the Source Explorer window as the idle one
    exe "silent " . "belowright " . "pedit " . s:SrcExpl_title
    " Jump to the Source Explorer
    silent! wincmd P
    " Open successfully and jump to it indeed
    if &previewwindow
        " Show its name on the buffer list
        setlocal buflisted
        " No exact file
        setlocal buftype=nofile
        " Delete all lines in buffer
        1,$d _
        " Goto the end of the buffer
        $
        " Display the version of the Source Explorer
        put! ='Source Explorer V3.1'
        " Delete the extra trailing blank line
        $ d _
        " Make it no modifiable
        setlocal nomodifiable
        " Put it on the bottom of (G)Vim
"        silent! wincmd J
    endif
    " Indeed go back to the edit window
    silent! exe s:SrcExpl_editWin . "wincmd w"

endfunction " }}}

" SrcExpl_Cleanup() {{{

" Clean up the rubbish and free the mapping resources

function! <SID>SrcExpl_Cleanup()

    " GUI Version
    if has("gui_running")
        " Delete the SrcExplGoBack item in Popup menu
        silent! nunmenu 1.01 PopUp.&SrcExplGoBack
        " Make the 'double-click' and 'enter' for nothing
        if maparg('<2-LeftMouse>', 'n') != ''
            unmap <silent> <2-LeftMouse>
        endif
    endif
    if maparg('<CR>', 'n') != ''
        unmap <silent> <CR>
    endif
    " Unmap the user's key
    if maparg(g:SrcExpl_refreshKey, 'n') == 
        \ ":call g:SrcExpl_Refresh()<CR>"
        exe "unmap " . g:SrcExpl_refreshKey
    endif
    " Unmap the user's key
    if maparg(g:SrcExpl_gobackKey, 'n') == 
        \ ":call g:SrcExpl_GoBack()<CR>"
        exe "unmap " . g:SrcExpl_gobackKey
    endif
    " Unload the autocmd group
    silent! autocmd! SrcExpl_AutoCmd

endfunction " }}}

" SrcExpl_Init() {{{

" Initialize the Source Explorer properties

function! <SID>SrcExpl_Init()

    " Delete all the marks
    delmarks A-Z a-z 0-9
    " Not change the current working directory
    set noautochdir
    " Access the Tags file 
    call <SID>SrcExpl_ProbeTags()
    " Found one Tags file
    if s:SrcExpl_tagsPath != ""
        " Compiled with 'Quickfix' feature
        if !has("quickfix")
            " Can not create preview window without quickfix feature
            echohl ErrorMsg
            echo "SrcExpl: Not support without 'Quickfix'."
            echohl None
            return -1
        endif
        " Have found 'tags' file and update that
        if g:SrcExpl_updateTags != 0
            " Call the external 'ctags' program
            silent !ctags -R *
        endif
    else
        " Ask user if or not create a tags file
        echohl Question |
            \ let l:answer = <SID>SrcExpl_GetInput("SrcExpl: "
                \ . "The 'tags' file isn't found in your PATH.\n"
            \ . "Create one in the current directory now? (y or n)")
        \ | echohl None
        " They do
        if l:answer == "y" || l:answer == "yes"
            " Back from the root directory
            exe "cd " . s:SrcExpl_workPath
            " Call the external 'ctags' program
            silent !ctags -R *
            " Rejudge the tags file if existed
            call <SID>SrcExpl_ProbeTags()
            " Maybe there is no 'ctags' program in user's system
            if s:SrcExpl_tagsPath == ""
                " Tell them what happened
                echohl ErrorMsg
                echo "SrcExpl: Execute the 'ctags' program failed."
                echohl None
                return -2
            endif
        else
            " They don't
            echo ""
            return -3
        endif
    endif
    " First set the height of preview window
    exe "set previewheight=". string(g:SrcExpl_winHeight)
    " Set the actual update time according to user's requestion
    " 1000 milliseconds by default
"    exe "set updatetime=" . string(g:SrcExpl_refreshTime)
    " Map the user's key to go back from the 
    " definition context.
    if g:SrcExpl_gobackKey != ""
        exe "nnoremap " . g:SrcExpl_gobackKey . 
            \ " :call g:SrcExpl_GoBack()<CR>"
    endif
    " Map the user's key to refresh the definition
    " updating manually.
    if g:SrcExpl_refreshKey != ""
        exe "nnoremap " . g:SrcExpl_refreshKey . 
            \ " :call g:SrcExpl_Refresh()<CR>"
    endif
    " First get the SrcExpl.vim's ID
    map <SID>xx <SID>xx
    let s:SrcExpl_scriptID = substitute(maparg('<SID>xx'), 
        \ '<SNR>\(\d\+_\)xx$', '\1', '')
    unmap <SID>xx
    " Then form an autocmd group
    augroup SrcExpl_AutoCmd
        " Delete the autocmd group first
        autocmd!
"        au! CursorHold * nested call g:SrcExpl_Refresh()
        au! WinEnter * nested call <SID>SrcExpl_EnterWin()
    augroup end
    " Initialize successfully
    return 0

endfunction " }}}

" SrcExpl_Toggle() {{{

" The User Interface function to open / close the Source Explorer

function! <SID>SrcExpl_Toggle()

    call <SID>SrcExpl_Debug("s:SrcExpl_opened is (" . s:SrcExpl_opened . ")")

    " Already closed
    if s:SrcExpl_opened == 0
        " Initialize the properties
        let l:rtn = <SID>SrcExpl_Init()
        " Initialize failed
        if l:rtn != 0
            return
        endif
        " Create the window
        call <SID>SrcExpl_OpenWin()
        " Set the switch flag on
        let s:SrcExpl_opened = 1
    " Already Opened
    else
        " Set the switch flag off
        let  s:SrcExpl_opened = 0
        " Close the window
        call <SID>SrcExpl_CloseWin()
        " Do the cleaning work
        call <SID>SrcExpl_Cleanup()
    endif

endfunction " }}}

" SrcExpl_Close() {{{

" The User Interface function to close the Source Explorer

function! <SID>SrcExpl_Close()

    if s:SrcExpl_opened == 1
        " Set the switch flag off
        let s:SrcExpl_opened = 0
        " Close the window
        call <SID>SrcExpl_CloseWin()
        " Do the cleaning work
        call <SID>SrcExpl_Cleanup()
    else
        " Tell users the reason
        echohl ErrorMsg
        echo "SrcExpl: The Source Explorer is close."
        echohl None
        return
    endif

endfunction " }}}

" SrcExpl() {{{

" The User Interface function to open the Source Explorer

function! <SID>SrcExpl()

    if s:SrcExpl_opened == 0
        " Initialize the properties
        let l:rtn = <SID>SrcExpl_Init()
        " Initialize failed
        if l:rtn != 0
            return
        endif
        " Create the window
        call <SID>SrcExpl_OpenWin()
        " Set the switch flag on
        let s:SrcExpl_opened = 1
    else
        " Tell users the reason
        echohl ErrorMsg
        echo "SrcExpl: The Source Explorer is running."
        echohl None
        return
    endif

endfunction " }}}

" Avoid side effects {{{

set cpoptions&
let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim:foldmethod=marker:tabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

