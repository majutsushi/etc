" C Call-Tree Explorer (CCTree) <CCTree.vim>
"
"
" Script Info and Documentation 
"=============================================================================
"    Copyright: Copyright (C) August 2008, Hari Rangarajan
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               cctree.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damamges
"               resulting from the use of this software.
"
" Name Of File: CCTree.vim
"  Description: C Call-Tree Explorer Vim Plugin
"   Maintainer: Hari Rangarajan <hari.rangarajan@gmail.com>
"          URL: http://vim.sourceforge.net/scripts/script.php?script_id=2368
"  Last Change: December 24, 2008
"      Version: 0.61
"
"=============================================================================
" 
"  Description:
"       Plugin generates call-trees for any function or macro in real-time inside
"  Vim.
"
"  Requirements: 1) Cscope
"                2) Vim 7.xx 
"
"                Tested on Unix and the following Win32 versions:
"                + Cscope, mlcscope (WIN32)
"                       http://www.geocities.com/shankara_c/cscope.html
"                       http://www.bell-labs.com/project/wwexptools/packages.html
"
"                
"
"  Installation: 
"               Copy this file to ~/.vim/plugins/
"               or to /vimfiles/plugins/  (on Win32 platforms) 
" 
"               It might also be possible to load it as a filetype plugin
"               ~/.vim/ftplugin/c/
"
"               Need to set :filetype plugin on 
"           
"
"  Usage:
"           Build cscope database, for example:
"           > cscope -b -i cscope.files
"               [Tip: add -c option to build uncompressed databases for faster
"               load speeds]
"
"           Load database with command ":CCTreeLoadDB"
"           (Please note that it might take a while depending on the 
"           database size)
"
"           A database name, i.e., my_cscope.out, can be specified with 
"           the command. If not provided, a prompt will ask for the 
"           filename; default is cscope.out.
"
"           To unload database, use command ":CCTreeUnLoadDB"
"
"           Default Mappings:
"             Get reverse call tree for symbol  <C-\><
"             Get forward call tree for symbol  <C-\>>
"             Increase depth of tree and update <C-\>=
"             Decrease depth of tree and update <C-\>-
"
"             Open symbol in other window       <CR>
"             Preview symbol in other window    <Ctrl-P>
"
"          Command List:
"             CCTreeLoadDB                <dbname>
"             CCTreeUnLoadDB             
"             CCTreeTraceForward          <symbolname>
"             CCTreeTraceReverse          <symbolname>     
"             CCTreeRecurseDepthPlus     
"             CCTreeRecurseDepthMinus    
"
"
"
"          Settings:
"               Customize behavior by changing the variable settings
"
"               Cscope database file, g:CCTreeCscopeDb = "cscope.out"
"               Maximum call levels,   g:CCTreeRecursiveDepth = 3
"               Maximum visible(unfolded) level, g:CCTreeMinVisibleDepth = 3
"               Orientation of window,  g:CCTreeOrientation = "leftabove"
"                (standard vim options for split: [right|left][above|below])
"
"               Use Vertical window, g:CCTreeWindowVertical = 1
"                   Min width for window, g:CCTreeWindowMinWidth = 40
"                   g:CCTreeWindowWidth = -1, auto-select best width to fit
"
"               Horizontal window, g:CCTreeWindowHeight, default is -1
"
"
"               Display format, g:CCTreeDisplayMode, default 1
"
"               Values: 1 -- Ultra-compact (takes minimum screen width)
"                       2 -- Compact       (Takes little more space)
"                       3 -- Wide          (Takes copious amounts of space)
"
"               For vertical splits, 1 and 2 are good, while 3 is good for
"               horizontal displays
"   
"               NOTE: To get older behavior, add the following to your vimrc
"               let g:CCTreeDisplayMode = 3
"               let g:CCTreeWindowVertical = 0
"
"               Syntax Coloring:
"                    CCTreeSymbol is the symbol name
"                    CCTreeMarkers include  "|","+--->"
"
"                    CCTreeHiSymbol is the highlighted call tree functions
"                    CCTreeHiMarkers is the same as CCTreeMarkers except
"                           these denote the highlighted call-tree
"
"
"                    CCTreeHiXXXX allows dynamic highlighting of the call-tree.
"                    To observe the effect, move the cursor to the function to
"                    highlight the current call-tree. This option can be
"                    turned off using the setting, g:CCTreeHilightCallTree.
"                    For faster highlighting, the value of 'updatetime' can be
"                    changed
"
"  Limitations:
"           The accuracy of the call-tree will only be as good as the cscope 
"           database generation.
"           NOTE: Different flavors of Cscope have some known
"                 limitations due to the lexical analysis engine. This results
"                 in incorrectly identified function blocks, etc.
"
"  History:
"
"           Version 0.61: December 24, 2008
"                 1. Fixed bug when processing include files
"                 2. Remove 'set ruler' option
"
"           Version 0.60: November 26, 2008
"                 1. Added support for source-file dependency tree
"
"           Version 0.50: October 17, 2008
"                 1. Optimizations for compact memory foot-print and 
"                    improved compressed-database load speeds
"
"           Version 0.41: October 6, 2008
"                  1. Minor fix: Compressed cscope databases will load
"                  incorrectly if encoding is not 8-bit
"
"           Version 0.4: September 28, 2008
"                  1. Rewrite of "tree-display" code
"                  2. New syntax hightlighting
"                  3. Dynamic highlighting for call-trees
"                  4. Support for new window modes (vertical, horizontal)  
"                  5. New display format option for compact or wide call-trees
"                  NOTE: defaults for tree-orientation set to vertical
"
"           Version 0.3:
"               September 21, 2008
"                 1. Support compressed cscope databases
"                 2. Display window related bugs fixed
"                 3. More intuitive display and folding capabilities
"               
"           Version 0.2:
"               September 12, 2008
"               (Patches from Yegappan Lakshmanan, thanks!)
"                 1. Support for using the plugin in Vi-compatible mode.
"                 2. Filtering out unwanted lines before processing the db.
"                 3. Command-line completion for the commands.
"                 4. Using the cscope db from any directory.
"
"           Version 0.1:
"                August 31,2008
"                 1. Cross-referencing support for only functions and macros
"                    Functions inside macro definitions will be incorrectly
"                    attributed to the top level calling function
"
"
"   Thanks:
"
"    Arun Chaganty/Timo Tiefel	    (Ver 0.60 -- bug report)
"    Michael Wookey                 (Ver 0.4 -- Testing/bug report/patches)
"    Yegappan Lakshmanan            (Ver 0.2 -- Patches)
"
"    The Vim Community, ofcourse :)
"
"=============================================================================

if !exists('loaded_cctree') && v:version >= 700
  " First time loading the cctree plugin
  "let loaded_cctree = 1
else
   finish 
endif

" Line continuation used here
let s:cpo_save = &cpoptions
set cpoptions&vim

" Global variables 
" Modify in .vimrc to modify default behavior
if !exists('CCTreeCscopeDb')
    let CCTreeCscopeDb = "cscope.out"
endif
if !exists('CCTreeRecursiveDepth')
    let CCTreeRecursiveDepth = 3
endif
if !exists('CCTreeMinVisibleDepth')
    let CCTreeMinVisibleDepth = 3
endif
if !exists('CCTreeOrientation')
    let CCTreeOrientation = "leftabove"
endif
if !exists('CCTreeWindowVertical')
    let CCTreeWindowVertical = 1
endif
if !exists('CCTreeWindowWidth')
    " -1 is auto select best width
    let CCTreeWindowWidth = -1
endif
if !exists('CCTreeWindowMinWidth')
    let CCTreeWindowMinWidth = 40
endif
if !exists('CCTreeWindowHeight')
    let CCTreeWindowHeight = -1
endif
if !exists('CCTreeDisplayMode')
    let CCTreeDisplayMode = 1
endif
if !exists('CCTreeHilightCallTree')
    let CCTreeHilightCallTree = 1
endif

" Plugin related local variables
let s:pluginname = 'CCTree'
let s:windowtitle = 'CCTree-Preview'

" There could be duplicate keywords on different lines
let s:CCTreekeyword = ''
let s:CCTreekeywordLine = -1

" Definition of a keyword...
let s:CCTreeKeywordRegEx = '[A-Za-z0-9_\\\.\/]\+'

" Other state variables
let s:currentkeyword = ''
let s:currentdirection = ''
let s:dbloaded = 0
let s:symhashtable = {}
let s:save_statusline = ''
let s:lastbufname = ''

" Turn on/off debugs
let s:tag_debug=0

" Use the Decho plugin for debugging
function! DBGecho(...)
    if s:tag_debug
        Decho(a:000)
    endif
endfunction

function! DBGredir(...)
    if s:tag_debug
        Decho(a:000)
    endif
endfunction


let s:symlistindex = 0
let s:symlisttable = []

function! s:CCTreeSymbolListAdd(name)
    if !has_key(s:symhashtable, a:name)
        let s:symhashtable[a:name] = s:symlistindex
        call add(s:symlisttable, s:CCTreeSymbolDictCreate(a:name))
        let s:symlistindex += 1
    endif
    return s:symhashtable[a:name]
endfunction

function! s:CCTreeSymbolDictCreate(name)
    let retval = {}
    
    let retval['n'] = a:name
    let retval['c'] = ""
    let retval['p'] = ""
    return retval
endfunction

function! s:CCTreeSymbolMarkXRef(funcentryidx, newfuncidx)
    let s:symlisttable[a:funcentryidx]['c'] .= (a:newfuncidx. ",")
    let s:symlisttable[a:newfuncidx]['p'] .= (a:funcentryidx. ",")
endfunction


function! s:CCTreeInitStatusLine()
    let s:symlastprogress = 0
    let s:symprogress = 0
    let s:cursym = 0
    let s:currentstatus = ''
    let s:statusextra = ''
    
    let s:save_statusline = &statusline
    setlocal statusline=%{CCTreeStatusLine()}
endfunction
        
function! s:CCTreeRestoreStatusLine()
    let &statusline = s:save_statusline
endfunction

function! s:CCTreeBusyStatusLineUpdate(msg)
    let s:currentstatus = a:msg
    redrawstatus
endfunction

function! s:CCTreeBusyStatusLineExtraInfo(msg)
    let s:statusextra = a:msg
    redrawstatus
endfunction

function! CCTreeStatusLine()
    return s:pluginname. " ". s:currentstatus. " -- ". s:statusextra
endfunction


let s:progresscurrent = 0
let s:progressmax = 0

function! s:CCTreeProgressBarInit(maxcount)
        let s:progressmax = a:maxcount
        let s:progress1percent = a:maxcount/100
        let s:progresspercent = 0
endfunction


function! s:CCTreeProgressBarTick(count)
        let s:progresscurrent += a:count
        if s:progress1percent < s:progresscurrent
            let s:progresscurrent = 0
            let s:progresspercent += 1
            call s:CCTreeBusyStatusLineExtraInfo("Processing ". s:progresspercent . 
                        \ "\%, total ". s:progressmax. " items")
        endif
endfunction


function! s:CCTreeWarningMsg(msg)
    echohl WarningMsg
    echo a:msg
    echohl None
endfunction

function! s:CCTreePreprocessFilter (val)
    call s:CCTreeProgressBarTick(1)
    return a:val =~ "^\t[`#$}]|^\k"
endfunction

function! s:CCTreeLoadDB(db_name)
    let curfuncidx = -1
    let newfuncidx =  -1
    let curfileidx = -1
    let newfileidx =  -1

    call s:CCTreeUnloadDB()

    let cscope_db = a:db_name
    if cscope_db == ''
        let cscope_db = input('Cscope database: ', g:CCTreeCscopeDb, 'file')
        if cscope_db == ''
            return
        endif
    endif

    if !filereadable(cscope_db)
        call s:CCTreeWarningMsg('Cscope database ' . cscope_db . ' not found')
        return
    endif

    call s:CCTreeBusyStatusLineUpdate('Loading database')
    let symbols = readfile(cscope_db)
    if empty(symbols)
        call s:CCTreeWarningMsg("Failed to read cscope database")
        call s:CCTreeRestoreStatusLine()
        return
    endif

    let symindex = 0
    let symlocalstart = 0
    let symlocalcount = 0

    " Grab previous status line
    call s:CCTreeInitStatusLine()
    
    call s:CCTreeBusyStatusLineUpdate('Reading database')
    " Check if database was built uncompressed
   if symbols[0] !~ "cscope.*\-c"
        let s:dbcompressed = 1
    else
        let s:dbcompressed = 0
    endif
    " Filter-out lines that doesn't have relevant information
    call filter(symbols, 'v:val =~ "^\t[`#$}@\~]"')
    call s:CCTreeProgressBarInit(len(symbols))

    call s:CCTreeBusyStatusLineUpdate('Analyzing database')
    for a in symbols
        call s:CCTreeProgressBarTick(1)
        
        if a[1] == "`"
             if curfuncidx != -1
                 let newfuncidx = s:CCTreeSymbolListAdd(a[2:])
                 call s:CCTreeSymbolMarkXRef(curfuncidx, newfuncidx)
             endif
        elseif a[1] == "$"
            let curfuncidx = s:CCTreeSymbolListAdd(a[2:])
        elseif a[1] == "#"
            call s:CCTreeSymbolListAdd(a[2:])
        elseif a[1] == "}"
            let curfuncidx = -1
        elseif a[1] == "~"
            let newfileidx = s:CCTreeSymbolListAdd(a[3:])
            call s:CCTreeSymbolMarkXRef(curfileidx, newfileidx)
        elseif a[1] == "@"
	    if a[2] != ""
                let curfileidx = s:CCTreeSymbolListAdd(a[2:])
	    endif
        endif
    endfor
    
    if s:dbcompressed == 1
        call s:CCTreeBusyStatusLineUpdate('Uncompressing database')
        " inplace uncompression
        call s:Digraph_Uncompress(s:symlisttable, s:symhashtable)
    endif

    call s:CCTreeRestoreStatusLine()
    let s:dbloaded = 1
    echomsg "Done building database"
endfunction


function! s:CCTreeUnloadDB()
    unlet s:symlisttable
    unlet s:symhashtable
    let s:dbloaded = 0
    " Force cleanup
    call garbagecollect()

    let s:symlisttable = []
    let s:symhashtable = {}
endfunction 

function! s:CCTreeGetSymbolXRef(symname, direction)
    let symentryidx = s:symhashtable[a:symname]
    let symidslist = split(s:symlisttable[symentryidx][a:direction], ",")
    let xrefs = {}

    for asymid in symidslist
        let xrefs[s:symlisttable[asymid]['n']] = 1
    endfor
    return xrefs
endfunction

function! s:CCTreeGetCallsForSymbol(symname, depth, direction)
    if (a:depth > g:CCTreeRecursiveDepth) 
        return {}
    endif

    if !has_key(s:symhashtable, a:symname)
        return {}            
    endif

    let calltree_dict = {}
    let calltree_dict['entry'] = a:symname

    for entry in keys(s:CCTreeGetSymbolXRef(a:symname, a:direction))
        if !has_key(calltree_dict, 'childlinks')
            let calltree_dict['childlinks'] = []
        endif
        let tmpDict = 
                \s:CCTreeGetCallsForSymbol(entry, a:depth+1, a:direction)
        call add(calltree_dict['childlinks'], tmpDict)
    endfor
    return calltree_dict
endfunction

func! s:FindOpenBuffer(filename)
    let bnrList = tabpagebuflist(tabpagenr())

    for bufnrs in bnrList
        if (bufname(bufnrs) == a:filename)
            let newWinnr = bufwinnr(bufnrs)
            exec newWinnr.'wincmd w'
            return 1
        endif
    endfor
    " Could not find the buffer
    return 0
endfunction

function! s:CCTreePreviewWindowLeave()
    call s:FindOpenBuffer(s:lastbufname)
endfunction

function! CCTreePreviewStatusLine()
    let rtitle= s:windowtitle. ' -- '. s:currentkeyword. 
            \'[Depth: '. g:CCTreeRecursiveDepth.','
    
    if s:currentdirection == 'p' 
        let rtitle .= "(Reverse)"
    else
        let rtitle .= "(Forward)"
    endif

    return rtitle.']'
endfunction

function! s:CCTreePreviewWindowEnter()
    let s:lastbufname = bufname("%")
    if s:FindOpenBuffer(s:windowtitle) == 0
        if g:CCTreeWindowVertical == 1
            exec  g:CCTreeOrientation." vsplit ". s:windowtitle
            set winfixwidth
        else
            exec  g:CCTreeOrientation." split ". s:windowtitle
            set winfixheight
        endif

        setlocal buftype=nofile
        setlocal bufhidden=wipe
        setlocal noswapfile
        setlocal nonumber
        setlocal statusline=%=%{CCTreePreviewStatusLine()}


        syntax match CCTreePathMark /\s[|+]/ contained
        syntax match CCTreeArrow  /-*[<>]/ contained
        syntax match CCTreeSymbol  / [A-Za-z0-9_\.\\\/]\+/  contained
 
        syntax region CCTreeSymbolLine start="^\s" end="$" contains=CCTreeArrow,CCTreePathMark,CCTreeSymbol oneline

        syntax match CCTreeHiArrow  /-*[<>]/ contained
        syntax match CCTreeHiSymbol  / [A-Za-z0-9_\.\\\/]\+/  contained
        syntax match CCTreeHiPathMark /\s[|+]/ contained
        
        syntax match CCTreeMarkExcl  /^[!#]/ contained
        syntax match CCTreeMarkTilde /@/  contained
        syntax region CCTreeUpArrowBlock start="@"  end=/[|+]/  contains=CCTreeMarkTilde contained oneline

        syntax region CCTreeHiSymbolLine start="!" end="$" contains=CCTreeMarkExcl, 
                \ CCTreeUpArrowBlock,
                \ CCTreeHiSymbol,CCTreeHiArrow,CCTreeHiPathMark oneline

        syntax region CCTreeMarkedSymbolLine start="#" end="$" contains=CCTreeMarkExcl,
                        \ CCTreeMarkTilde,CCTreePathMark,
                        \ CCTreeArrow,CCTreeSymbol,CCTreeUpArrowBlock oneline

        let cpo_save = &cpoptions
        set cpoptions&vim

        call s:CCTreeBufferKeyMappingsCreate() 
        nnoremap <buffer> <silent> <C-p>  :CCTreePreviewBufferUsingTag<CR>
        nnoremap <buffer> <silent> <CR>  :CCTreeLoadBufferUsingTag<CR>
        nnoremap <buffer> <silent> <2-LeftMouse> :CCTreeLoadBufferUsingTag<CR>

        let &cpoptions = cpo_save
    endif
    setlocal foldmethod=expr
    setlocal foldexpr=s:CCTreeFoldExpr(getline(v:lnum))
    setlocal foldtext=CCTreeFoldText()
    let &l:foldlevel=g:CCTreeMinVisibleDepth
endfunction   


function! s:CCTreeBuildTreeForLevel(dict, level, treelist, lvllen)
    if !has_key(a:dict, 'entry')
        return
    endif

    if g:CCTreeDisplayMode == 1 
       let curlevellen = 1
    elseif g:CCTreeDisplayMode == 2
       let curlevellen = a:level + 2
    elseif g:CCTreeDisplayMode == 3
       let curlevellen = strlen(a:dict['entry']) + a:level + 2
    endif    

    let a:lvllen[a:level] = min([a:lvllen[a:level], curlevellen])


    call add(a:treelist, [a:dict['entry'], a:level])
    if has_key(a:dict, 'childlinks')
        for a in a:dict['childlinks']
            call s:CCTreeBuildTreeForLevel(a, a:level+1, a:treelist, a:lvllen)
        endfor
    endif
endfunction


let s:calltreemaxdepth = 10
function! s:CCTreeBuildTreeDisplayItems(treedict, treesymlist)
    let treexinfo = repeat([255], s:calltreemaxdepth)
    call s:CCTreeBuildTreeForLevel(a:treedict, 0, a:treesymlist, treexinfo) 
    return s:CCTreeBuildDisplayPrependText(treexinfo)
endfunction


function! s:CCTreeBuildDisplayPrependText(lenlist)
    let pptxt = "  "
    let treepptext = repeat([" "], s:calltreemaxdepth)

   if s:currentdirection == 'p' 
        let directiontxt = "< "
    elseif s:currentdirection == 'c'
        let directiontxt = "> "
   endif

   let treepptext[0] = pptxt."+".directiontxt

    for idx in range(1, s:calltreemaxdepth-1)
        if a:lenlist[idx] != 255
            let pptxt .= repeat(" ", a:lenlist[idx-1])
            let treepptext[idx] = pptxt."+"

            if g:CCTreeDisplayMode == 1 
                let arrows = '-'
            elseif g:CCTreeDisplayMode >= 2
                let arrows = repeat("-", idx)
            endif

            let treepptext[idx] = pptxt."+".arrows.directiontxt
            let pptxt .= "|"
        endif
    endfor
    return treepptext
endfunction

function! s:CCTreeDisplayTreeList(pptxtlst, treelst)
    for aentry in a:treelst
        call setline(".", a:pptxtlst[aentry[1]]. aentry[0])
        let b:maxwindowlen = max([strlen(getline("."))+1, b:maxwindowlen])
        exec "normal o"
    endfor
endfunction


" Provide dynamic call-tree highlighting using 
" syntax highlight tricks 
"
" There are 3 types of lines, marked with the start character [\s, !, #]
" Also @ is used to mark the path that is going up

function! s:CCTreeMarkCallTree(treelst, keyword)
    let declevel = -1

    for idx in range(line("."), 1, -1)
        " Find our keyword
        if declevel == -1  
            if a:treelst[idx-1][0] == a:keyword
                let declevel = a:treelst[idx-1][1] 
            endif
        endif

        " Skip folds
        if declevel != -1 && foldclosed(idx) == -1
            let curline = getline(idx)
            if declevel == a:treelst[idx-1][1]
                let linemarker = '!'
                let declevel -= 1
            else
                let linemarker = '#'
            endif
            let pos = match(curline, '[+|]', 0, declevel+1)
            " Unconventional change char
            let curline = linemarker.strpart(curline, 1, pos-2).'@'.
                        \ strpart(curline, pos, 1). strpart(curline, pos+1)
            call setline(idx, curline)
        endif
    endfor
endfunction



function! s:CCTreeDisplayTreeInWindow(atree)
    let incctreewin = 1
    if (bufname('%') != s:windowtitle) 
        call s:CCTreePreviewWindowEnter()
        let incctreewin = 0
    endif
    setlocal modifiable
    1,$d
    let b:treelist = []
    let b:maxwindowlen = g:CCTreeWindowMinWidth
    let treemarkertxtlist = s:CCTreeBuildTreeDisplayItems(a:atree, b:treelist)
    call s:CCTreeDisplayTreeList(treemarkertxtlist, b:treelist)

    if g:CCTreeWindowVertical == 1
        if g:CCTreeWindowWidth == -1
            exec "vert resize". b:maxwindowlen
        else
            exec "vertical resize". g:CCTreeWindowWidth
        endif
    else
        if g:CCTreeWindowHeight != -1
            let &winminheight = g:CCTreeWindowHeight
           exec "resize".g:CCTreeWindowHeight
        endif
    endif

    exec "normal gg"

    " Need to force this again
    let &l:foldlevel=g:CCTreeMinVisibleDepth
    setlocal nomodifiable
    if (incctreewin == 0)
        call s:CCTreePreviewWindowLeave()
    endif
endfunction

function! s:CCTreeFoldExpr(line)
    let lvl = b:treelist[v:lnum-1][1]
    if lvl == 0
        let lvl = 1
    endif
    return '>'.lvl
endfunction


function! CCTreeFoldText()
    let line = substitute(getline(v:foldstart), '[!@#]', ' ' , 'g')
    return line. " (+". (v:foldend - v:foldstart). 
                \  ')'. repeat(" ", winwidth(0))
endfunction


function! s:CCTreeStoreState(symbol, direction)
    let s:currentkeyword = a:symbol
    let s:currentdirection = a:direction
endfunction

function! s:CCTreeDBIsLoaded()
    if s:dbloaded == 0
        call s:CCTreeWarningMsg('CCTree database not loaded')
        return 0
    endif
    return 1
endfunction

" Trick to get the current script ID
map <SID>xx <SID>xx
let s:sid = substitute(maparg('<SID>xx'), '<SNR>\(\d\+_\)xx$', '\1', '')
unmap <SID>xx

function! s:CCTreeTraceTreeForSymbol(sym_arg, direction)
    if s:CCTreeDBIsLoaded() == 0
        return
    endif

    let symbol = a:sym_arg
    if symbol == ''
        let symbol = input('Trace symbol: ', expand('<cword>'),
                    \ 'customlist,<SNR>' . s:sid . 'CCTreeCompleteKwd')
        if symbol == ''
            return
        endif
    endif

    let atree = s:CCTreeGetCallsForSymbol(symbol, 0, a:direction)
    call s:CCTreeStoreState(symbol, a:direction)
    call s:CCTreeUpdateForCurrentSymbol()
endfunction

function! s:CCTreeUpdateForCurrentSymbol()
    if s:currentkeyword != ''
        let atree = s:CCTreeGetCallsForSymbol(s:currentkeyword, 0, s:currentdirection)
        call s:CCTreeDisplayTreeInWindow(atree)
    endif
endfunction
 

function! s:CCTreeGetCurrentKeyword()
    let curline = line(".")
    if foldclosed(curline) == -1
        let curkeyword = matchstr(getline("."), s:CCTreeKeywordRegEx)
        if curkeyword != ''
            if curkeyword != s:CCTreekeyword || curline != s:CCTreekeywordLine
                let s:CCTreekeyword = curkeyword
                let s:CCTreekeywordLine = line(".")
                return 1
            endif
        endif 
    endif  
    return -1
endfunction

function! s:CCTreeLoadBufferFromKeyword()
    if s:CCTreeGetCurrentKeyword() == -1
        return
    endif

    try 
        exec 'wincmd p'
    catch
        call s:CCTreeWarningMsg('No buffer to load file')
    finally
        if (cscope_connection() > 0)
            try 
                exec "cs find g ".s:CCTreekeyword
            catch
                " cheap hack
                exec "cs find f ".s:CCTreekeyword
            endtry
        else
            try
                " Ctags is smart enough to figure the path
                exec "tag ".fnamemodify(s:CCTreekeyword, ":t")
            catch /^Vim\%((\a\+)\)\=:E426/
                call s:CCTreeWarningMsg('Tag '. s:CCTreekeyword .' not found')
                wincmd p
            endtry
        endif
    endtry
endfunction
    
function! s:CCTreePreviewBufferFromKeyword()
    call s:CCTreeGetCurrentKeyword()
    if s:CCTreekeyword == ''
        return
    endif
    silent! wincmd P
    if !&previewwindow 
        wincmd p
    endif
    exec "ptag ".s:CCTreekeyword
endfunction


function! s:CCTreeSanitizeCallDepth()
    let error = 0
    if g:CCTreeRecursiveDepth >= s:calltreemaxdepth
        g:CCTreeRecursiveDepth = s:calltreemaxdepth
        let error = 1
    elseif g:CCTreeRecursiveDepth < 1 
        g:CCTreeRecursiveDepth = 1
        let error = 1
    endif

    if error == 1
        call s:CCTreeWarningMsg('Depth out of bounds')
    endif
    return error
endfunction

function! s:CCTreeRecursiveDepthIncrease()
    let g:CCTreeRecursiveDepth += 1
    if s:CCTreeSanitizeCallDepth() == 0
        call s:CCTreeUpdateForCurrentSymbol()
    endif
endfunction

function! s:CCTreeRecursiveDepthDecrease()
    let g:CCTreeRecursiveDepth -= 1
    if s:CCTreeSanitizeCallDepth() == 0
        call s:CCTreeUpdateForCurrentSymbol()
    endif
endfunction


" Use this function to determine the correct "g" flag
" for substitution
function! s:CCTreeGetSearchFlag(gvalue)
    let ret = (!a:gvalue)* (&gdefault) + (!&gdefault)*(a:gvalue)
    if ret == 1
        return 'g'
    endif
    return ''
endfunc

function! s:CCTreeClearMarks()
   let windict = winsaveview()
   silent! exec "1,$s/[!#@]/ /e".s:CCTreeGetSearchFlag(1)
   call winrestview(windict)
endfunction

function! s:CCTreeCursorHoldHandle()
    if g:CCTreeHilightCallTree && s:CCTreeGetCurrentKeyword() != -1 
       setlocal modifiable
       call s:CCTreeClearMarks()
       call s:CCTreeMarkCallTree(b:treelist, s:CCTreekeyword)
       setlocal nomodifiable
    endif
endfunction

" CCTreeCompleteKwd
" Command line completion function to return names from the db
function! s:CCTreeCompleteKwd(arglead, cmdline, cursorpos)
    if a:arglead == ''
        return keys(s:symhashtable)
    else
        return filter(keys(s:symhashtable), 'v:val =~? a:arglead')
    endif
endfunction

augroup CCTreeGeneral
    au!
    autocmd CursorHold CCTree-Preview call s:CCTreeCursorHoldHandle()
augroup END



"Standard display
highlight link CCTreeSymbol  Function
highlight link CCTreeMarkers LineNr
highlight link CCTreeArrow CCTreeMarkers
highlight link CCTreePathMark CCTreeArrow
highlight link CCTreeHiPathMark CCTreePathMark

" highlighted display
highlight link CCTreeHiSymbol  TODO
highlight link CCTreeHiMarkers StatusLine
highlight link CCTreeHiArrow  CCTreeHiMarkers
highlight link CCTreeUpArrowBlock CCTreeHiArrow

highlight link CCTreeMarkExcl Ignore
highlight link CCTreeMarkTilde Ignore


" Define commands
command! -nargs=? -complete=file CCTreeLoadDB  call s:CCTreeLoadDB(<q-args>)
command! -nargs=0 CCTreeUnLoadDB               call s:CCTreeUnloadDB()
command! -nargs=? -complete=customlist,s:CCTreeCompleteKwd
        \ CCTreeTraceForward call s:CCTreeTraceTreeForSymbol(<q-args>, 'c')
command! -nargs=? -complete=customlist,s:CCTreeCompleteKwd CCTreeTraceReverse  
            \ call s:CCTreeTraceTreeForSymbol(<q-args>, 'p')
command! -nargs=0 CCTreeLoadBufferUsingTag call s:CCTreeLoadBufferFromKeyword()
command! -nargs=0 CCTreePreviewBufferUsingTag call s:CCTreePreviewBufferFromKeyword()
command! -nargs=0 CCTreeRecurseDepthPlus call s:CCTreeRecursiveDepthIncrease()
command! -nargs=0 CCTreeRecurseDepthMinus call s:CCTreeRecursiveDepthDecrease()


function! s:CCTreeGetKeyword()
    let keyw = expand("<cword>")
    let keyf = expand("<cfile>")

    if keyw != keyf 
        if has_key(s:symhashtable, keyf)
            return keyf
        elseif has_key(s:symhashtable, keyw)
            return keyw
        endif
    else
        return keyw
    endif
    return ''
endfunction


function! s:CCTreeBufferKeyMappingsCreate()
     let func_expr = '<SNR>'.s:sid.'CCTreeGetKeyword()'
     exec 'nnoremap <buffer> <silent> <C-\>< :CCTreeTraceReverse <C-R>='.func_expr.'<CR><CR>'
     exec 'nnoremap <buffer> <silent> <C-\>> :CCTreeTraceForward <C-R>='.func_expr.'<CR><CR>'

     nnoremap <buffer> <silent> <C-\>= :CCTreeRecurseDepthPlus<CR> 
     nnoremap <buffer> <silent> <C-\>- :CCTreeRecurseDepthMinus<CR> 
endfunction

augroup CCTreeMaps
au!
" Header files get detected as cpp?
" This is a bug in Vim 7.2, a patch needs to be applied to the runtime c
" syntax files
" For now, use this hack to make *.h files work
autocmd FileType * if &ft == 'c'|| &ft == 'cpp' |call s:CCTreeBufferKeyMappingsCreate()| endif
augroup END


" Cscope Digraph character compression/decompression routines
" the logic of these routines are based off the Cscope source code

let s:dichar1 = " teisaprnl(of)=c"	
let s:dichar2 = " tnerpla"

function! s:Digraph_DictTable_Init ()
    let dicttable = []
    let index = 0

    for dc1 in range(strlen(s:dichar1))
        for dc2 in range(strlen(s:dichar2))
            call add(dicttable, s:dichar1[dc1].s:dichar2[dc2])
        endfor
    endfor

    return dicttable
endfunction

function! s:Digraph_Uncompress_Slow (value, dicttable)
    let retval = ""
    for idx in range(strlen(a:value))
        let charext = char2nr(a:value[idx])-128
        if charext >= 0 
            let retval .= a:dicttable[charext]
        else
            let retval .= a:value[idx]
        endif
    endfor
    return retval
endfunction

function! s:Digraph_Uncompress_Fast (value, dicttable)
    let dichar_list = split(a:value, '[^\d128-\d255]\{}')
    let retval = a:value
    for adichar in dichar_list
        let retval = substitute(retval, '\C'.adichar, a:dicttable[char2nr(adichar)-128], "g")
    endfor
    return retval
endfunction


function! s:Digraph_Uncompress_filter_loop(compressedsym, symlist, symhash, cmpdict)
    let idx = a:symhash[a:compressedsym]
    let uncmpname = s:Digraph_Uncompress_Fast(a:compressedsym, a:cmpdict)
    let a:symhash[uncmpname] = idx
    let a:symlist[idx]['n'] = uncmpname
    call s:CCTreeProgressBarTick(1)
    return 0
endfunction

function! s:Digraph_Uncompress (symlist, symhash)
    let compressdict = s:Digraph_DictTable_Init()

    call s:CCTreeProgressBarInit(len(a:symhash))
" The encoding needs to be changed to 8-bit, otherwise we can't swap special 
" 8-bit characters; restore after done
    let encoding_save=&encoding
    let &encoding="latin1"

    for compressedsym in keys(a:symhash)
        let idx = a:symhash[compressedsym]
        let uncmpname = s:Digraph_Uncompress_Fast(compressedsym, compressdict)
        let a:symhash[uncmpname] = idx
        " free the old entry
        unlet a:symhash[compressedsym]
        let a:symlist[idx]['n'] = uncmpname
        call s:CCTreeProgressBarTick(1)
    endfor
    let &encoding=encoding_save
endfunction


function! s:Digraph_Compress(value, dicttable)
    let index = 0
    let retval = ""

    while index < strlen(a:value)
        let dc1 = stridx(s:dichar1, a:value[index])
        if dc1 != -1
            let dc2 = stridx(s:dichar2, a:value[index+1])
            if dc2 != -1 
                let retval .= nr2char(128 + (dc1*8) + dc2)  
                " skip 2 chars
                let index += 2
                continue
            endif
        endif
        let retval .= a:value[index]
        let index += 1
    endwhile
    return retval
endfunction


" restore 'cpo'
let &cpoptions = s:cpo_save
unlet s:cpo_save

