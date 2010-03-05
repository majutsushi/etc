" vikiAnyWord.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=vim-vikiAnyWord)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     04-Apr-2005.
" @Last Change: 2010-01-03.
" @Revision:    0.39

" call tlog#Log('Load: '. expand('<sfile>')) " vimtlib-sfile


"""" Any Word {{{1
function! viki_anyword#MinorMode(state) "{{{3
    let b:vikiFamily = 'anyword'
    call viki_viki#MinorMode(a:state)
endfun

function! viki_anyword#SetupBuffer(state, ...) "{{{3
    let dontSetup = a:0 > 0 ? a:1 : ''
    call viki_viki#SetupBuffer(a:state, dontSetup)
    if b:vikiNameTypes =~? "s" && !(dontSetup =~? "s")
        if b:vikiNameTypes =~# "S" && !(dontSetup =~# "S")
            let simpleWikiName = b:vikiSimpleNameQuoteBeg
                        \ .'['. b:vikiSimpleNameQuoteChars .']'
                        \ .'\{-}'. b:vikiSimpleNameQuoteEnd
        else
            let simpleWikiName = ""
        endif
        if b:vikiNameTypes =~# "s" && !(dontSetup =~# "s")
            let simple = '\<['. g:vikiUpperCharacters .']['. g:vikiLowerCharacters
                        \ .']\+\(['. g:vikiUpperCharacters.']['.g:vikiLowerCharacters
                        \ .'0-9]\+\)\+\>'
            if simpleWikiName != ""
                let simpleWikiName = simpleWikiName .'\|'. simple
            else
                let simpleWikiName = simple
            endif
        endif
        let anyword = '\<['. b:vikiSimpleNameQuoteChars .' ]\+\>'
        if simpleWikiName != ""
            let simpleWikiName = simpleWikiName .'\|'. anyword
        else
            let simpleWikiName = anyword
        endif
        let b:vikiSimpleNameRx = '\C\(\(\<['. g:vikiUpperCharacters .']\+::\)\?'
                    \ .'\('. simpleWikiName .'\)\)'
                    \ .'\(#\('. b:vikiAnchorNameRx .'\)\>\)\?'
        let b:vikiSimpleNameSimpleRx = '\C\(\<['.g:vikiUpperCharacters.']\+::\)\?'
                    \ .'\('. simpleWikiName .'\)'
                    \ .'\(#'. b:vikiAnchorNameRx .'\>\)\?'
        let b:vikiSimpleNameNameIdx   = 1
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 6
        let b:vikiSimpleNameCompound = 'let erx="'. escape(b:vikiSimpleNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiSimpleNameNameIdx
                    \ .' | let destIdx='. b:vikiSimpleNameDestIdx
                    \ .' | let anchorIdx='. b:vikiSimpleNameAnchorIdx
    endif
    let b:vikiInexistentHighlight = "vikiAnyWordInexistentLink"
    let b:vikiMarkInexistent = 2
endf

function! viki_anyword#DefineMarkup(state) "{{{3
    if b:vikiNameTypes =~? "s" && b:vikiSimpleNameRx != ""
        exe "syn match vikiRevLink /" . b:vikiSimpleNameRx . "/"
    endif
    if b:vikiNameTypes =~# "e" && b:vikiExtendedNameRx != ""
        exe "syn match vikiRevExtendedLink '" . b:vikiExtendedNameRx . "'"
    endif
    if b:vikiNameTypes =~# "u" && b:vikiUrlRx != ""
        exe "syn match vikiURL /" . b:vikiUrlRx . "/"
    endif
endfun

function! viki_anyword#DefineHighlighting(state, ...) "{{{3
    let dontSetup = a:0 > 0 ? a:1 : ''
    call viki_viki#DefineHighlighting(a:state)
    if version < 508
        command! -nargs=+ VikiHiLink hi link <args>
    else
        command! -nargs=+ VikiHiLink hi def link <args>
    endif
    exec 'VikiHiLink '. b:vikiInexistentHighlight .' Normal'
    delcommand VikiHiLink
endf

function! viki_anyword#Find(flag, ...) "{{{3
    let rx = viki#RxFromCollection(b:vikiNamesOk)
    let i  = a:0 >= 1 ? a:1 : 0
    call viki_viki#Find(a:flag, i, rx)
endfun


