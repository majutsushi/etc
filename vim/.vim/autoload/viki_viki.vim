" vikiDeplate.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-03.
" @Last Change: 2009-02-15.
" @Revision:    0.0.111

if &cp || exists("loaded_viki_viki")
    finish
endif
let loaded_viki_viki = 1

let s:save_cpo = &cpo
set cpo&vim


""" viki/deplate {{{1
" Prepare a buffer for use with viki.vim. Setup all buffer-local 
" variables etc.
" This also sets up the rx for the different viki name types.
" viki_viki#SetupBuffer(state, ?dontSetup='')
function! viki_viki#SetupBuffer(state, ...) "{{{3
    if !g:vikiEnabled
        return
    endif
    " TLogDBG expand('%') .': '. (exists('b:vikiFamily') ? b:vikiFamily : 'default')

    let dontSetup = a:0 > 0 ? a:1 : ""
    let noMatch = ""
   
    if exists("b:vikiNoSimpleNames") && b:vikiNoSimpleNames
        let b:vikiNameTypes = substitute(b:vikiNameTypes, '\Cs', '', 'g')
    endif
    if exists("b:vikiDisableType") && b:vikiDisableType != ""
        let b:vikiNameTypes = substitute(b:vikiNameTypes, '\C'. b:vikiDisableType, '', 'g')
    endif

    call viki#SetBufferVar("vikiAnchorMarker")
    call viki#SetBufferVar("vikiSpecialProtocols")
    call viki#SetBufferVar("vikiSpecialProtocolsExceptions")
    call viki#SetBufferVar("vikiMarkInexistent")
    call viki#SetBufferVar("vikiTextstylesVer")
    " call viki#SetBufferVar("vikiTextstylesVer")
    call viki#SetBufferVar("vikiLowerCharacters")
    call viki#SetBufferVar("vikiUpperCharacters")
    call viki#SetBufferVar("vikiAnchorNameRx")
    call viki#SetBufferVar("vikiUrlRestRx")
    call viki#SetBufferVar("vikiFeedbackMin")

    if a:state == 1
        call viki#SetBufferVar("vikiCommentStart", 
                    \ "b:commentStart", "b:ECcommentOpen", "b:EnhCommentifyCommentOpen",
                    \ "*matchstr(&commentstring, '^\\zs.*\\ze%s')")
        call viki#SetBufferVar("vikiCommentEnd",
                    \ "b:commentEnd", "b:ECcommentClose", "b:EnhCommentifyCommentClose", 
                    \ "*matchstr(&commentstring, '%s\\zs.*\\ze$')")
    elseif !exists('b:vikiCommentStart')
        " This actually is an error.
        if &debug != ''
            echom "Viki: FTPlugin wasn't loaded. Viki requires :filetype plugin on"
        endif
        let b:vikiCommentStart = '%'
        let b:vikiCommentEnd   = ''
    endif
    
    let b:vikiSimpleNameQuoteChars = '^][:*/&?<>|\"'
    
    let b:vikiSimpleNameQuoteBeg   = '\[-'
    let b:vikiSimpleNameQuoteEnd   = '-\]'
    let b:vikiQuotedSelfRef        = "^". b:vikiSimpleNameQuoteBeg . b:vikiSimpleNameQuoteEnd ."$"
    let b:vikiQuotedRef            = "^". b:vikiSimpleNameQuoteBeg .'.\+'. b:vikiSimpleNameQuoteEnd ."$"

    if empty(b:vikiAnchorNameRx)
        let b:vikiAnchorNameRx         = '['. b:vikiLowerCharacters .']['. 
                    \ b:vikiLowerCharacters . b:vikiUpperCharacters .'_0-9]*'
    endif
    " TLogVAR b:vikiAnchorNameRx
    
    let interviki = '\<['. b:vikiUpperCharacters .']\+::'

    " if viki#IsSupportedType("sSc") && !(dontSetup =~? "s")
    if viki#IsSupportedType("s") && !(dontSetup =~? "s")
        if viki#IsSupportedType("S") && !(dontSetup =~# "S")
            let quotedVikiName = b:vikiSimpleNameQuoteBeg 
                        \ .'['. b:vikiSimpleNameQuoteChars .']'
                        \ .'\{-}'. b:vikiSimpleNameQuoteEnd
        else
            let quotedVikiName = ""
        endif
        if viki#IsSupportedType("c") && !(dontSetup =~# "c")
            let simpleWikiName = viki#GetSimpleRx4SimpleWikiName()
            if quotedVikiName != ""
                let quotedVikiName = quotedVikiName .'\|'
            endif
        else
            let simpleWikiName = '\(\)'
        endif
        let simpleHyperWords = ''
        if v:version >= 700 && viki#IsSupportedType('w') && !(dontSetup =~# 'w')
            let b:vikiHyperWordTable = {}
            if viki#IsSupportedType('f') && !(dontSetup =~# 'f')
                call viki#CollectFileWords(b:vikiHyperWordTable, simpleWikiName)
            endif
            call viki#CollectHyperWords(b:vikiHyperWordTable)
            let hyperWords = keys(b:vikiHyperWordTable)
            if !empty(hyperWords)
                let simpleHyperWords = join(map(hyperWords, '"\\<".tlib#rx#Escape(v:val)."\\>"'), '\|') .'\|'
                let simpleHyperWords = substitute(simpleHyperWords, ' \+', '\\s\\+', 'g')
            endif
        endif
        let b:vikiSimpleNameRx = '\C\(\('. interviki .'\)\?'.
                    \ '\('. simpleHyperWords . quotedVikiName . simpleWikiName .'\)\)'.
                    \ '\(#\('. b:vikiAnchorNameRx .'\)\>\)\?'
        let b:vikiSimpleNameSimpleRx = '\C\(\<['.b:vikiUpperCharacters.']\+::\)\?'.
                    \ '\('. simpleHyperWords . quotedVikiName . simpleWikiName .'\)'.
                    \ '\(#'. b:vikiAnchorNameRx .'\>\)\?'
        let b:vikiSimpleNameNameIdx   = 1
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 6
        let b:vikiSimpleNameCompound = 'let erx="'. escape(b:vikiSimpleNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiSimpleNameNameIdx
                    \ .' | let destIdx='. b:vikiSimpleNameDestIdx
                    \ .' | let anchorIdx='. b:vikiSimpleNameAnchorIdx
    else
        let b:vikiSimpleNameRx        = noMatch
        let b:vikiSimpleNameSimpleRx  = noMatch
        let b:vikiSimpleNameNameIdx   = 0
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 0
    endif
   
    if viki#IsSupportedType("u") && !(dontSetup =~# "u")
        let urlChars = 'A-Za-z0-9.,:%?=&_~@$/|+-'
        let b:vikiUrlRx = '\<\(\('.b:vikiSpecialProtocols.'\):['. urlChars .']\+\)'.
                    \ '\(#\('. b:vikiAnchorNameRx .'\)\)\?'. b:vikiUrlRestRx
        let b:vikiUrlSimpleRx = '\<\('. b:vikiSpecialProtocols .'\):['. urlChars .']\+'.
                    \ '\(#'. b:vikiAnchorNameRx .'\)\?'. b:vikiUrlRestRx
        let b:vikiUrlNameIdx   = 0
        let b:vikiUrlDestIdx   = 1
        let b:vikiUrlAnchorIdx = 4
        let b:vikiUrlCompound = 'let erx="'. escape(b:vikiUrlRx, '\"')
                    \ .'" | let nameIdx='. b:vikiUrlNameIdx
                    \ .' | let destIdx='. b:vikiUrlDestIdx
                    \ .' | let anchorIdx='. b:vikiUrlAnchorIdx
    else
        let b:vikiUrlRx        = noMatch
        let b:vikiUrlSimpleRx  = noMatch
        let b:vikiUrlNameIdx   = 0
        let b:vikiUrlDestIdx   = 0
        let b:vikiUrlAnchorIdx = 0
    endif
   
    if viki#IsSupportedType("x") && !(dontSetup =~# "x")
        " let vikicmd = '['. b:vikiUpperCharacters .']\w*'
        let vikicmd    = '\(IMG\|Img\|INC\%[LUDE]\)\>'
        let vikimacros = '\(img\|ref\)\>'
        let b:vikiCmdRx        = '\({'. vikimacros .'\|#'. vikicmd .'\)\(.\{-}\):\s*\(.\{-}\)\($\|}\)'
        let b:vikiCmdSimpleRx  = '\({'. vikimacros .'\|#'. vikicmd .'\).\{-}\($\|}\)'
        let b:vikiCmdNameIdx   = 1
        let b:vikiCmdDestIdx   = 5
        let b:vikiCmdAnchorIdx = 4
        let b:vikiCmdCompound = 'let erx="'. escape(b:vikiCmdRx, '\"')
                    \ .'" | let nameIdx='. b:vikiCmdNameIdx
                    \ .' | let destIdx='. b:vikiCmdDestIdx
                    \ .' | let anchorIdx='. b:vikiCmdAnchorIdx
    else
        let b:vikiCmdRx        = noMatch
        let b:vikiCmdSimpleRx  = noMatch
        let b:vikiCmdNameIdx   = 0
        let b:vikiCmdDestIdx   = 0
        let b:vikiCmdAnchorIdx = 0
    endif
    
    if viki#IsSupportedType("e") && !(dontSetup =~# "e")
        let b:vikiExtendedNameRx = 
                    \ '\[\[\(\('.b:vikiSpecialProtocols.'\)://[^]]\+\|[^]#]\+\)\?'.
                    \ '\(#\([^]]*\)\)\?\]\(\[\([^]]\+\)\]\)\?\([!~*$\-]*\)\]'
                    " \ '\(#\('. b:vikiAnchorNameRx .'\)\)\?\]\(\[\([^]]\+\)\]\)\?[!~*\-]*\]'
        let b:vikiExtendedNameSimpleRx = 
                    \ '\[\[\('. b:vikiSpecialProtocols .'://[^]]\+\|[^]#]\+\)\?'.
                    \ '\(#[^]]*\)\?\]\(\[[^]]\+\]\)\?[!~*$\-]*\]'
                    " \ '\(#'. b:vikiAnchorNameRx .'\)\?\]\(\[[^]]\+\]\)\?[!~*\-]*\]'
        let b:vikiExtendedNameNameIdx   = 6
        let b:vikiExtendedNameModIdx    = 7
        let b:vikiExtendedNameDestIdx   = 1
        let b:vikiExtendedNameAnchorIdx = 4
        let b:vikiExtendedNameCompound = 'let erx="'. escape(b:vikiExtendedNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiExtendedNameNameIdx
                    \ .' | let destIdx='. b:vikiExtendedNameDestIdx
                    \ .' | let anchorIdx='. b:vikiExtendedNameAnchorIdx
    else
        let b:vikiExtendedNameRx        = noMatch
        let b:vikiExtendedNameSimpleRx  = noMatch
        let b:vikiExtendedNameNameIdx   = 0
        let b:vikiExtendedNameDestIdx   = 0
        let b:vikiExtendedNameAnchorIdx = 0
    endif

    let b:vikiInexistentHighlight = "vikiInexistentLink"

    " TLogVAR a:state
    if a:state == 2
        " TLogVAR g:vikiAutoMarks
        if g:vikiAutoMarks
            call viki#SetAnchorMarks()
        endif
        if g:vikiNameSuffix != ''
            exec 'setlocal suffixesadd+='. g:vikiNameSuffix
        endif
        if exists('b:vikiNameSuffix') && b:vikiNameSuffix != '' && b:vikiNameSuffix != g:vikiNameSuffix
            exec 'setlocal suffixesadd+='. b:vikiNameSuffix
        endif
        if exists('g:loaded_hookcursormoved') && g:loaded_hookcursormoved >= 3 && exists('b:vikiMarkInexistent') && b:vikiMarkInexistent
            let b:hookcursormoved_syntaxleave = ['vikiLink', 'vikiExtendedLink', 'vikiURL', 'vikiOkLink', 'vikiInexistentLink']
            for cond in g:vikiHCM
                call hookcursormoved#Register(cond, function('viki#HookCheckPreviousPosition'))
            endfor
        endif
    endif
endf


" Define viki core syntax groups for hyperlinks
function! viki_viki#DefineMarkup(state) "{{{3
    if viki#IsSupportedType("sS") && b:vikiSimpleNameSimpleRx != ""
        exe "syntax match vikiLink /" . b:vikiSimpleNameSimpleRx . "/"
    endif
    if viki#IsSupportedType("e") && b:vikiExtendedNameSimpleRx != ""
        exe "syntax match vikiExtendedLink '" . b:vikiExtendedNameSimpleRx . "' skipnl"
    endif
    if viki#IsSupportedType("u") && b:vikiUrlSimpleRx != ""
        exe "syntax match vikiURL /" . b:vikiUrlSimpleRx . "/"
    endif
endf


" Define the highlighting of the core syntax groups for hyperlinks
function! viki_viki#DefineHighlighting(state) "{{{3
    exec 'hi vikiInexistentLink '. g:viki_highlight_inexistent_{&background}
    exec 'hi vikiHyperLink '. g:viki_highlight_hyperlink_{&background}

    if viki#IsSupportedType("sS")
        hi def link vikiLink vikiHyperLink
        hi def link vikiOkLink vikiHyperLink
        hi def link vikiRevLink Normal
    endif
    if viki#IsSupportedType("e")
        hi def link vikiExtendedLink vikiHyperLink
        hi def link vikiExtendedOkLink vikiHyperLink
        hi def link vikiRevExtendedLink Normal
    endif
    if viki#IsSupportedType("u")
        hi def link vikiURL vikiHyperLink
    endif
endf


" Define viki-related key maps
function! viki_viki#MapKeys(state) "{{{3
    if exists('b:vikiDidMapKeys')
        return
    endif
    if a:state == 1
        if exists('b:vikiMapFunctionalityMinor') && b:vikiMapFunctionalityMinor
            let mf = b:vikiMapFunctionalityMinor
        else
            let mf = g:vikiMapFunctionalityMinor
        endif
    elseif exists('b:vikiMapFunctionality') && b:vikiMapFunctionality
        let mf = b:vikiMapFunctionality
    else
        let mf = g:vikiMapFunctionality
    endif

    " if !hasmapto('viki#MaybeFollowLink')
        if viki#MapFunctionality(mf, 'c')
            nnoremap <buffer> <silent> <c-cr> :call viki#MaybeFollowLink(0,1)<cr>
            inoremap <buffer> <silent> <c-cr> <c-o>:call viki#MaybeFollowLink(0,1)<cr>
            " nnoremap <buffer> <silent> <LocalLeader><c-cr> :call viki#MaybeFollowLink(0,1,-1)<cr>
        endif
        if viki#MapFunctionality(mf, 'f')
            " nnoremap <buffer> <silent> <c-cr> :call viki#MaybeFollowLink(0,1)<cr>
            " inoremap <buffer> <silent> <c-cr> <c-o>:call viki#MaybeFollowLink(0,1)<cr>
            " nnoremap <buffer> <silent> <LocalLeader><c-cr> :call viki#MaybeFollowLink(0,1,-1)<cr>
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'f :call viki#MaybeFollowLink(0,1)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'s :call viki#MaybeFollowLink(0,1,-1)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'v :call viki#MaybeFollowLink(0,1,-2)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'1 :call viki#MaybeFollowLink(0,1,1)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'2 :call viki#MaybeFollowLink(0,1,2)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'3 :call viki#MaybeFollowLink(0,1,3)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'4 :call viki#MaybeFollowLink(0,1,4)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'t :call viki#MaybeFollowLink(0,1,"tab")<cr>'
        endif
        if viki#MapFunctionality(mf, 'mf')
            " && !hasmapto("viki#MaybeFollowLink")
            nnoremap <buffer> <silent> <m-leftmouse> <leftmouse>:call viki#MaybeFollowLink(0,1)<cr>
            inoremap <buffer> <silent> <m-leftmouse> <leftmouse><c-o>:call viki#MaybeFollowLink(0,1)<cr>
        endif
    " endif

    " if !hasmapto('VikiMarkInexistent')
        if viki#MapFunctionality(mf, 'i')
            exec 'noremap <buffer> <silent> '. g:vikiMapLeader .'d :call viki#MarkInexistentInElement("Document")<cr>'
            exec 'noremap <buffer> <silent> '. g:vikiMapLeader .'p :call viki#MarkInexistentInElement("Paragraph")<cr>'
        endif
        if viki#MapFunctionality(mf, 'I')
            if g:vikiMapInexistent
                let i = 0
                let m = strlen(g:vikiMapKeys)
                while i < m
                    let k = g:vikiMapKeys[i]
                    call viki#MapMarkInexistent(k, "LineQuick")
                    let i = i + 1
                endwh
                let i = 0
                let m = strlen(g:vikiMapQParaKeys)
                while i < m
                    let k = g:vikiMapQParaKeys[i]
                    call viki#MapMarkInexistent(k, "ParagraphVisible")
                    let i = i + 1
                endwh
            endif
        endif
    " endif

    if viki#MapFunctionality(mf, 'e')
        " && !hasmapto("viki#Edit")
        exec 'noremap <buffer> '. g:vikiMapLeader .'e :VikiEdit '
    endif
    
    if viki#MapFunctionality(mf, 'q') && exists("*VEnclose")
        " && !hasmapto("VikiQuote")
        exec 'vnoremap <buffer> <silent> '. g:vikiMapLeader .'q :VikiQuote<cr><esc>:call viki#MarkInexistentInElement("LineQuick")<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'q viw:VikiQuote<cr><esc>:call viki#MarkInexistentInElement("LineQuick")<cr>'
        exec 'inoremap <buffer> <silent> '. g:vikiMapLeader .'q <esc>viw:VikiQuote<cr>:call viki#MarkInexistentInElement("LineQuick")<cr>i'
    endif
    
    if viki#MapFunctionality(mf, 'p')
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'<bs> :call viki#GoParent()<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'<up> :call viki#GoParent()<cr>'
    endif

    if viki#MapFunctionality(mf, 'b')
        " && !hasmapto("VikiGoBack")
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'b :call viki#GoBack()<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'<left> :call viki#GoBack()<cr>'
    endif
    if viki#MapFunctionality(mf, 'mb')
        nnoremap <buffer> <silent> <m-rightmouse> <leftmouse>:call viki#GoBack(0)<cr>
        inoremap <buffer> <silent> <m-rightmouse> <leftmouse><c-o>:call viki#GoBack(0)<cr>
    endif
    
    if viki#MapFunctionality(mf, 'F')
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'n :VikiFindNext<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'N :VikiFindPrev<cr>'
        exec 'nmap <buffer> <silent> '. g:vikiMapLeader .'F '. g:vikiMapLeader .'n'. g:vikiMapLeader .'f'
    endif
    if viki#MapFunctionality(mf, 'tF')
        nnoremap <buffer> <silent> <c-tab>   :VikiFindNext<cr>
        nnoremap <buffer> <silent> <c-s-tab> :VikiFindPrev<cr>
    endif
    if viki#MapFunctionality(mf, 'Files')
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'u :VikiFilesUpdate<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'U :VikiFilesUpdateAll<cr>'
        exec 'nnoremap <buffer> '. g:vikiMapLeader .'x :VikiFilesExec '
        exec 'nnoremap <buffer> '. g:vikiMapLeader .'X :VikiFilesExec! '
    endif
    let b:vikiDidMapKeys = 1
endf


" Initialize viki as minor mode (add-on to some buffer filetype)
"state ... no-op:0, minor:1, major:2
function! viki_viki#MinorMode(state) "{{{3
    if !g:vikiEnabled
        return 0
    endif
    if a:state == 0
        return 0
    endif
    let state = a:state < 0 ? -a:state : a:state
    let vf = viki#Family(1)
    " c ... CamelCase 
    " s ... Simple viki name 
    " S ... Simple quoted viki name
    " e ... Extended viki name
    " u ... URL
    " i ... InterViki
    " call viki#SetBufferVar('vikiNameTypes', 'g:vikiNameTypes', "*'csSeui'")
    call viki#SetBufferVar('vikiNameTypes')
    call viki#DispatchOnFamily('SetupBuffer', vf, state)
    call viki#DispatchOnFamily('DefineMarkup', vf, state)
    call viki#DispatchOnFamily('DefineHighlighting', vf, state)
    call viki#DispatchOnFamily('MapKeys', vf, state)
    if !exists('b:vikiEnabled') || b:vikiEnabled < state
        let b:vikiEnabled = state
    endif
    " call viki#DispatchOnFamily('VikiDefineMarkup', vf, state)
    " call viki#DispatchOnFamily('VikiDefineHighlighting', vf, state)
    return 1
endf


" Find an anchor
function! viki_viki#FindAnchor(anchor) "{{{3
    " TLogVAR a:anchor
    if a:anchor == g:vikiDefNil || a:anchor == ''
        return
    endif
    let mode = matchstr(a:anchor, '^\(l\(ine\)\?\|rx\|vim\)\ze=')
    if exists('*VikiAnchor_'. mode)
        let arg  = matchstr(a:anchor, '=\zs.\+$')
        call VikiAnchor_{mode}(arg)
    else
        let co = col('.')
        let li = line('.')
        let anchorRx = viki#GetAnchorRx(a:anchor)
        " TLogVAR anchorRx
        keepjumps go
        let found = search(anchorRx, 'Wc')
        " TLogVAR found
        if !found
            call cursor(li, co)
            if g:vikiFreeMarker
                call search('\c\V'. escape(a:anchor, '\'), 'w')
            endif
        endif
    endif
    exec g:vikiPostFindAnchor
endf


" Complete missing information in the definition of an extended viki name
function! viki_viki#CompleteExtendedNameDef(def) "{{{3
    " TLogVAR a:def
    exec viki#SplitDef(a:def)
    if v_dest == g:vikiDefNil
        if v_anchor == g:vikiDefNil
            throw "Viki: Malformed extended viki name (no destination): ". string(a:def)
        else
            let v_dest = g:vikiSelfRef
        endif
    elseif viki#IsInterViki(v_dest)
        let useSuffix = viki#InterVikiSuffix(v_dest)
        let v_dest = viki#InterVikiDest(v_dest)
        " TLogVAR v_dest
        if v_dest != g:vikiDefNil
            let v_dest = viki#ExpandSimpleName('', v_dest, useSuffix)
            " TLogVAR v_dest
        endif
    else
        if v_dest =~? '^[a-z]:'                      " an absolute dos path
        elseif v_dest =~? '^\/'                          " an absolute unix path
        elseif v_dest =~? '^'.b:vikiSpecialProtocols.':' " some protocol
        elseif v_dest =~ '^\~'                           " user home
            " let v_dest = $HOME . strpart(v_dest, 1)
            let v_dest = fnamemodify(v_dest, ':p')
            let v_dest = viki#CanonicFilename(v_dest)
        else                                           " a relative path
            let v_dest = expand("%:p:h") .g:vikiDirSeparator. v_dest
            let v_dest = viki#CanonicFilename(v_dest)
        endif
        if v_dest != '' && v_dest != g:vikiSelfRef && !viki#IsSpecial(v_dest)
            let mod = viki#ExtendedModifier(v_part)
            if fnamemodify(v_dest, ':e') == '' && mod !~# '!'
                let v_dest = viki#WithSuffix(v_dest)
            endif
        endif
    endif
    if v_name == g:vikiDefNil
        let v_name = fnamemodify(v_dest, ':t:r')
    endif
    let v_type = v_type == g:vikiDefNil ? 'e' : v_type
    " TLogVAR v_name, v_dest, v_anchor, v_part, v_type
    return viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type)
endf


" Complete missing information in the definition of a command viki name
function! viki_viki#CompleteCmdDef(def) "{{{3
    " TLogVAR a:def
    exec viki#SplitDef(a:def)
    " TLogVAR v_name, v_dest, v_anchor
    let args     = v_anchor
    let v_anchor = g:vikiDefNil
    if v_name ==# "#IMG" || v_name =~# "{img"
        let v_dest = viki#FindFileWithSuffix(v_dest, viki#GetSpecialFilesSuffixes())
        " TLogVAR v_dest
    elseif v_name ==# "#Img"
        let id = matchstr(args, '\sid=\zs\w\+')
        if id != ''
            let v_dest = viki#FindFileWithSuffix(id, viki#GetSpecialFilesSuffixes())
        endif
    elseif v_name =~ "^#INC"
        " <+TODO+> Search path?
    elseif v_name =~ '^{ref\>'
        let v_anchor = v_dest
        let v_name = g:vikiSelfRef
        let v_dest = g:vikiSelfRef
        " TLogVAR v_name, v_anchor, v_dest
    else
        " throw "Viki: Unknown command: ". v_name
        let v_name = g:vikiDefNil
        let v_dest = g:vikiDefNil
        " let v_anchor = g:vikiDefNil
    endif
    let v_type = v_type == g:vikiDefNil ? 'cmd' : v_type
    let vdef   = viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type)
    " TLogVAR vdef
    return vdef
endf


" Complete missing information in the definition of a simple viki name
function! viki_viki#CompleteSimpleNameDef(def) "{{{3
    " TLogVAR a:def
    exec viki#SplitDef(a:def)
    if v_name == g:vikiDefNil
        throw "Viki: Malformed simple viki name (no name): ". string(a:def)
    endif

    if !(v_dest == g:vikiDefNil)
        throw "Viki: Malformed simple viki name (destination=".v_dest."): ". string(a:def)
    endif

    " TLogVAR v_name
    if viki#IsInterViki(v_name)
        let i_name = viki#InterVikiName(v_name)
        let useSuffix = viki#InterVikiSuffix(v_name)
        let v_name = viki#InterVikiPart(v_name)
    elseif viki#IsHyperWord(v_name)
        let hword = viki#HyperWordValue(v_name)
        if type(hword) == 4
            let i_name = hword.interviki
            let useSuffix = hword.suffix
            let v_name = hword.name
        else
            let i_name = ''
            let useSuffix = ''
            let v_name = hword
        end
    else
        let i_name = ''
        let v_dest = expand("%:p:h")
        let useSuffix = g:vikiDefSep
    endif
    " TLogVAR i_name

    if viki#IsSupportedType("S")
        " TLogVAR v_name
        if v_name =~ b:vikiQuotedSelfRef
            let v_name  = g:vikiSelfRef
        elseif v_name =~ b:vikiQuotedRef
            let v_name = matchstr(v_name, "^". b:vikiSimpleNameQuoteBeg .'\zs.\+\ze'. b:vikiSimpleNameQuoteEnd ."$")
        endif
    elseif !viki#IsSupportedType("c")
        throw "Viki: CamelCase names not allowed"
    endif

    if v_name != g:vikiSelfRef
        " TLogVAR v_dest, v_name, useSuffix
        let rdest = viki#ExpandSimpleName(v_dest, v_name, useSuffix)
        " TLogVAR rdest
    else
        let rdest = g:vikiDefNil
        " TLogVAR rdest
    endif

    if i_name != ''
        let rdest = viki#InterVikiDest(rdest, i_name)
        " TLogVAR rdest
        " let v_name = ''
    endif

    let v_type   = v_type == g:vikiDefNil ? 's' : v_type
    " TLogVAR v_type
    return viki#MakeDef(v_name, rdest, v_anchor, v_part, v_type)
endf


" Find a viki name
" viki_viki#Find(flag, ?count=0, ?rx=nil)
function! viki_viki#Find(flag, ...) "{{{3
    let rx = (a:0 >= 2 && a:2 != '') ? a:2 : viki#FindRx()
    if rx != ""
        let i = a:0 >= 1 ? a:1 : 0
        while i >= 0
            call search(rx, a:flag)
            let i = i - 1
        endwh
    endif
endf


let &cpo = s:save_cpo
unlet s:save_cpo
