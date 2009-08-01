" Viki.vim -- Some kind of personal wiki for Vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     08-Dec-2003.
" @Last Change: 2009-03-20.
" @Revision:    2627
"
" GetLatestVimScripts: 861 1 viki.vim
"
" Short Description:
" This plugin adds wiki-like hypertext capabilities to any document.  Just 
" type :VikiMinorMode and all wiki names will be highlighted. If you press 
" <c-cr> (or <LocalLeader>vf) when the cursor is over a wiki name, you 
" jump to (or create) the referred page. When invoked via :set ft=viki, 
" additional highlighting is provided.
"
" Requirements:
" - tlib.vim (vimscript #1863)
" 
" Optional Enhancements:
" - imaps.vim (vimscript #244 or #475 for |:VimQuote|)
" - kpsewhich (not a vim plugin :-) for vikiLaTeX
"
" TODO:
" - File names containing # (the # is interpreted as URL component)
" - Per Interviki simple name patterns
" - Allow Wiki links like ::Word or even ::word (not in minor mode due 
"   possible conflict with various programming languages?)
" - :VikiRename command: rename links/files (requires a cross-plattform grep 
"   or similar; or one could a global register)
" - don't know how to deal with viki names that span several lines (e.g.  in 
"   LaTeX mode)

if &cp || exists("loaded_viki") "{{{2
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 15
    runtime plugin/02tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 15
        echoerr 'tlib >= 0.15 is required'
        finish
    endif
endif
let loaded_viki = 311

" This is what we consider nil, in the absence of nil in vimscript
let g:vikiDefNil  = ''

" In a previous version this was used as list separator and as nil too
let g:vikiDefSep  = "\n"

" let s:vikiSelfEsc = '\'

" In extended viki links this is considered as a reference to the current 
" document. This is likely to go away.
let g:vikiSelfRef = '.'

" let s:vikiEnabledID = loaded_viki .'_'. strftime('%c')


" Configuration {{{1
" If zero, viki is disabled, though the code is loaded.
if !exists("g:vikiEnabled") "{{{2
    let g:vikiEnabled = 1
endif

" Support for the taglist plugin.
if !exists("tlist_viki_settings") "{{{2
    let tlist_viki_settings="deplate;s:structure"
endif

" A simple viki name is made from a series of upper and lower characters 
" (i.e. CamelCase-names). These two variables define what is considered as 
" upper and lower-case characters. We don't rely on the builtin 
" functionality for this.
if !exists("g:vikiUpperCharacters") "{{{2
    let g:vikiUpperCharacters = "A-Z"
endif
if !exists("g:vikiLowerCharacters") "{{{2
    let g:vikiLowerCharacters = "a-z"
endif

" Characters allowed in anchors
" Defaults to:
" [b:vikiLowerCharacters][b:vikiLowerCharacters +  b:vikiUpperCharacters + '_0-9]*
if !exists('g:vikiAnchorNameRx')
    let g:vikiAnchorNameRx = '' "{{{2
endif

if !exists('g:vikiUrlRestRx')
    let g:vikiUrlRestRx = '['. g:vikiLowerCharacters . g:vikiUpperCharacters .'0-9?%_=&+-]*'  "{{{2
endif

" The prefix for the menu of intervikis. Set to '' in order to remove the 
" menu.
if !exists("g:vikiMenuPrefix") "{{{2
    let g:vikiMenuPrefix = "Plugin.Viki."
endif

" Make submenus for N letters of the interviki names.
if !exists('g:vikiMenuLevel')
    let g:vikiMenuLevel = 1   "{{{2
endif

" URLs matching these protocols are handled by VikiOpenSpecialProtocol()
if !exists("g:vikiSpecialProtocols") "{{{2
    let g:vikiSpecialProtocols = 'https\?\|ftps\?\|nntp\|mailto\|mailbox\|file'
endif

" Exceptions from g:vikiSpecialProtocols
if !exists("g:vikiSpecialProtocolsExceptions") "{{{2
    let g:vikiSpecialProtocolsExceptions = ""
endif

" Files matching these suffixes are handled by viki#OpenSpecialFile()
if !exists("g:vikiSpecialFiles") "{{{2
    let g:vikiSpecialFiles = [
                \ 'aac',
                \ 'aif',
                \ 'aiff',
                \ 'au',
                \ 'avi',
                \ 'bmp',
                \ 'dia',
                \ 'doc',
                \ 'dvi',
                \ 'eps',
                \ 'eps',
                \ 'gif',
                \ 'htm',
                \ 'html',
                \ 'jpeg',
                \ 'jpg',
                \ 'm3u',
                \ 'mp1',
                \ 'mp2',
                \ 'mp3',
                \ 'mp4',
                \ 'mpeg',
                \ 'mpg',
                \ 'odg',
                \ 'ods',
                \ 'odt',
                \ 'ogg',
                \ 'pdf',
                \ 'png',
                \ 'ppt',
                \ 'ps',
                \ 'rtf',
                \ 'voc',
                \ 'wav',
                \ 'wma',
                \ 'wmf',
                \ 'wmv',
                \ 'xhtml',
                \ 'xls',
                \ ]
endif

" Exceptions from g:vikiSpecialFiles
if !exists("g:vikiSpecialFilesExceptions") "{{{2
    let g:vikiSpecialFilesExceptions = ""
endif

if !exists('g:viki_highlight_hyperlink_light') "{{{2
    " let g:viki_highlight_hyperlink_light = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=DarkBlue guifg=DarkBlue'
    let g:viki_highlight_hyperlink_light = 'term=underline cterm=underline gui=underline ctermfg=DarkBlue guifg=DarkBlue'
endif
if !exists('g:viki_highlight_hyperlink_dark') "{{{2
    " let g:viki_highlight_hyperlink_dark = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=DarkBlue guifg=LightBlue'
    let g:viki_highlight_hyperlink_dark = 'term=underline cterm=underline gui=underline ctermfg=LightBlue guifg=#bfbfff'
endif

if !exists('g:viki_highlight_inexistent_light') "{{{2
    " let g:viki_highlight_inexistent_light = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=DarkRed guifg=DarkRed'
    let g:viki_highlight_inexistent_light = 'term=underline cterm=underline gui=underline ctermfg=DarkRed guifg=DarkRed'
endif
if !exists('g:viki_highlight_inexistent_dark') "{{{2
    " let g:viki_highlight_inexistent_dark = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=Red guifg=Red'
    let g:viki_highlight_inexistent_dark = 'term=underline cterm=underline gui=underline ctermfg=Red guifg=Red'
endif

" If set to true, any files loaded by viki will become viki enabled (in 
" minor mode); this was the default behaviour in earlier versions
if !exists('g:vikiPromote') "{{{2
    let g:vikiPromote = 0
endif

" If non-nil, use the parent document's suffix.
if !exists("g:vikiUseParentSuffix") | let g:vikiUseParentSuffix = 0      | endif "{{{2

" Default file suffix (including the optional period, e.g. '.txt').
if !exists("g:vikiNameSuffix")      | let g:vikiNameSuffix = ""          | endif "{{{2

" Prefix for anchors
if !exists("g:vikiAnchorMarker")    | let g:vikiAnchorMarker = "#"       | endif "{{{2

" If non-nil, search anchors anywhere in the text too (without special 
" markup)
if !exists("g:vikiFreeMarker")      | let g:vikiFreeMarker = 0           | endif "{{{2

if !exists('g:vikiPostFindAnchor') "{{{2
    let g:vikiPostFindAnchor = 'norm! zz'
endif

" List of enabled viki name types
" c ... Camel case
" s ... Simple names
" S ... Quoted simple names
" e ... Extended names
" u ... URLs
" i ... Intervikis
" x ... Commands
" w ... "hyperwords"
" f ... Filenames as "hyperwords"
if !exists("g:vikiNameTypes")       | let g:vikiNameTypes = "csSeuixwf"  | endif "{{{2

" Which directory explorer to use to edit directories
if !exists("g:vikiExplorer")        | let g:vikiExplorer = "Sexplore"    | endif "{{{2
" if !exists("g:vikiExplorer")        | let g:vikiExplorer = "split"    | endif "{{{2
" if !exists("g:vikiExplorer")        | let g:vikiExplorer = "edit"          | endif "{{{2
"
" If hide or update: use the respective command when leaving a buffer
if !exists("g:vikiHide")            | let g:vikiHide = ''                | endif "{{{2

" Don't use g:vikiHide for commands matching this rx
if !exists("g:vikiNoWrapper")       | let g:vikiNoWrapper = '\cexplore'  | endif "{{{2

" Cache information about a document's inexistent names
if !exists("g:vikiCacheInexistent") | let g:vikiCacheInexistent = 0      | endif "{{{2

" Mark up inexistent names.
if !exists("g:vikiMarkInexistent")  | let g:vikiMarkInexistent = 1       | endif "{{{2

" If non-nil, map keys that trigger the evaluation of inexistent names
if !exists("g:vikiMapInexistent")   | let g:vikiMapInexistent = 1        | endif "{{{2

" Map these keys for g:vikiMapInexistent to LineQuick
if !exists("g:vikiMapKeys")         | let g:vikiMapKeys = "]).,;:!?\"' " | endif "{{{2

" Map these keys for g:vikiMapInexistent to ParagraphVisible
if !exists("g:vikiMapQParaKeys")    | let g:vikiMapQParaKeys = "\n"      | endif "{{{2

" Install hooks for these conditions (requires hookcursormoved to be 
" installed)
" "linechange" could cause some slowdown.
if !exists("g:vikiHCM") "{{{2
    let g:vikiHCM = ['syntaxleave_oneline']
endif

" Check the viki name before inserting this character
if !exists("g:vikiMapBeforeKeys")   | let g:vikiMapBeforeKeys = ']'      | endif "{{{2

" Some functions a gathered in families/classes. See vikiLatex.vim for 
" an example.
if !exists("g:vikiFamily")          | let g:vikiFamily = ""              | endif "{{{2

" The directory separator
if !exists("g:vikiDirSeparator")    | let g:vikiDirSeparator = "/"       | endif "{{{2

" The version of Deplate markup
if !exists("g:vikiTextstylesVer")   | let g:vikiTextstylesVer = 2        | endif "{{{2

" if !exists("g:vikiBasicSyntax")     | let g:vikiBasicSyntax = 0          | endif "{{{2
" If non-nil, display headings of different levels in different colors
if !exists("g:vikiFancyHeadings")   | let g:vikiFancyHeadings = 0        | endif "{{{2

" Choose folding method version
if !exists("g:vikiFoldMethodVersion") | let g:vikiFoldMethodVersion = 4  | endif "{{{2

" What is considered for folding.
" This variable is only used if g:vikiFoldMethodVersion is 1.
if !exists("g:vikiFolds")           | let g:vikiFolds = 'hf'             | endif "{{{2

" Context lines for folds
if !exists("g:vikiFoldsContext") "{{{2
    let g:vikiFoldsContext = [2, 2, 2, 2]
endif

" Consider fold levels bigger that this as text body, levels smaller 
" than this as headings
" This variable is only used if g:vikiFoldMethodVersion is 1.
if !exists("g:vikiFoldBodyLevel")   | let g:vikiFoldBodyLevel = 6        | endif "{{{2

" The default viki page (as absolute filename)
if !exists("g:vikiHomePage")        | let g:vikiHomePage = ''            | endif "{{{2

" The default filename for an interviki's index name
if !exists("g:vikiIndex")           | let g:vikiIndex = 'index'          | endif "{{{2

" How often the feedback is changed when marking inexisting links
if !exists("g:vikiFeedbackMin")     | let g:vikiFeedbackMin = &lines     | endif "{{{2

" The map leader for most viki key maps.
if !exists("g:vikiMapLeader")       | let g:vikiMapLeader = '<LocalLeader>v' | endif "{{{2

" If non-nil, anchors like #mX are turned into vim marks
if !exists("g:vikiAutoMarks")       | let g:vikiAutoMarks = 1            | endif "{{{2

" if !exists("g:vikiOpenInWindow")    | let g:vikiOpenInWindow = ''        | endif "{{{2
if !exists("g:vikiHighlightMath")   | let g:vikiHighlightMath = ''       | endif "{{{2

" If non-nil, cache back-links information
if !exists("g:vikiSaveHistory")     | let g:vikiSaveHistory = 0          | endif "{{{2

" The variable that keeps back-links information
if !exists("g:VIKIBACKREFS")        | let g:VIKIBACKREFS = {}            | endif "{{{2

" A list of files that contain special viki names
if v:version >= 700 && !exists("g:vikiHyperWordsFiles") "{{{2
    let g:vikiHyperWordsFiles = [
                \ get(split(&rtp, ','), 0).'/vikiWords.txt',
                \ './.vikiWords',
                \ ]
endif

" Definition of intervikis. (This variable won't be evaluated until 
" autoload/viki.vim is loaded).
if !exists('g:viki_intervikis')
    let g:viki_intervikis = {}   "{{{2
endif

" Define which keys to map
if !exists("g:vikiMapFunctionality") "{{{2
    " b     ... go back
    " c     ... follow link (c-cr)
    " e     ... edit
    " F     ... find
    " f     ... follow link (<LocalLeader>v)
    " i     ... check for inexistant destinations
    " I     ... map keys in g:vikiMapKeys and g:vikiMapQParaKeys
    " m[fb] ... map mouse (depends on f or b)
    " p     ... edit parent (or backlink)
    " q     ... quote
    " tF    ... tab as find
    " Files ... #Files related
    " let g:vikiMapFunctionality      = 'mf mb tF c q e i I Files'
    let g:vikiMapFunctionality      = 'ALL'
endif
" Define which keys to map in minor mode (invoked via :VikiMinorMode)
if !exists("g:vikiMapFunctionalityMinor") "{{{2
    " let g:vikiMapFunctionalityMinor = 'f b p mf mb tF c q e i'
    let g:vikiMapFunctionalityMinor = 'f b p mf mb tF c q e'
endif


" Special file handlers {{{1
if !exists('g:vikiOpenFileWith_ws') && exists(':WsOpen') "{{{2
    function! VikiOpenAsWorkspace(file)
        exec 'WsOpen '. escape(a:file, ' &!%')
        exec 'lcd '. escape(fnamemodify(a:file, ':p:h'), ' &!%')
    endf
    let g:vikiOpenFileWith_ws = "call VikiOpenAsWorkspace('%{FILE}')"
    call add(g:vikiSpecialFiles, 'ws')
endif
if type(g:vikiSpecialFiles) != 3
    echoerr 'Viki: g:vikiSpecialFiles must be a list'
endif
" TAssert IsList(g:vikiSpecialFiles)

if !exists("g:vikiOpenFileWith_ANY") "{{{2
    if exists('g:netrw_browsex_viewer')
        let g:vikiOpenFileWith_ANY = "exec 'silent !'. g:netrw_browsex_viewer .' '. shellescape('%{FILE}')"
    elseif has("win32") || has("win16") || has("win64")
        let g:vikiOpenFileWith_ANY = "exec 'silent ! start \"\" '. shellescape('%{FILE}')"
    elseif has("mac")
        let g:vikiOpenFileWith_ANY = "exec 'silent !open '. shellescape('%{FILE}')"
    elseif $GNOME_DESKTOP_SESSION_ID != ""
        let g:vikiOpenFileWith_ANY = "exec 'silent !gnome-open '. shellescape('%{FILE}')"
    elseif $KDEDIR != ""
        let g:vikiOpenFileWith_ANY = "exec 'silent !kfmclient exec '. shellescape('%{FILE}')"
    endif
endif

if !exists('*VikiOpenSpecialFile') "{{{2
    function! VikiOpenSpecialFile(file) "{{{3
        " let proto = tolower(matchstr(a:file, '\c\.\zs[a-z]\+$'))
        let proto = tolower(fnamemodify(a:file, ':e'))
        if exists('g:vikiOpenFileWith_'. proto)
            let prot = g:vikiOpenFileWith_{proto}
        elseif exists('g:vikiOpenFileWith_ANY')
            let prot = g:vikiOpenFileWith_ANY
        else
            let prot = ''
        endif
        if prot != ''
            " let openFile = viki#SubstituteArgs(prot, 'FILE', fnameescape(a:file))
            let openFile = viki#SubstituteArgs(prot, 'FILE', a:file)
            " TLogVAR openFile
            call viki#ExecExternal(openFile)
        else
            throw 'Viki: Please define g:vikiOpenFileWith_'. proto .' or g:vikiOpenFileWith_ANY!'
        endif
    endf
endif


" Special protocol handlers {{{1
if !exists('g:vikiOpenUrlWith_mailbox') "{{{2
    let g:vikiOpenUrlWith_mailbox="call VikiOpenMailbox('%{URL}')"
    function! VikiOpenMailbox(url) "{{{3
        exec viki#DecomposeUrl(strpart(a:url, 10))
        let idx = matchstr(args, 'number=\zs\d\+$')
        if filereadable(filename)
            call viki#OpenLink(filename, '', 0, 'go '.idx)
        else
            throw 'Viki: Can't find mailbox url: '.filename
        endif
    endf
endif

" Possible values: special*, query, normal
if !exists("g:vikiUrlFileAs") | let g:vikiUrlFileAs = 'special' | endif "{{{2

if !exists("g:vikiOpenUrlWith_file") "{{{2
    let g:vikiOpenUrlWith_file="call VikiOpenFileUrl('%{URL}')"
    function! VikiOpenFileUrl(url) "{{{3
        " TLogVAR url
        if viki#IsSpecialFile(a:url)
            if g:vikiUrlFileAs == 'special'
                let as_special = 1
            elseif g:vikiUrlFileAs == 'query'
                echo a:url
                let as_special = input('Treat URL as special file? (Y/n) ')
                let as_special = (as_special[0] !=? 'n')
            else
                let as_special = 0
            endif
            " TLogVAR as_special
            if as_special
                call VikiOpenSpecialFile(a:url)
                return
            endif
        endif
        exec viki#DecomposeUrl(strpart(a:url, 7))
        if filereadable(filename) || isdirectory(filename)
            call viki#OpenLink(filename, anchor)
        else
            throw "Viki: Can't find file url: ". filename
        endif
    endf
endif

if !exists("g:vikiOpenUrlWith_ANY") "{{{2
    " let g:vikiOpenUrlWith_ANY = "exec 'silent !". g:netrw_browsex_viewer ." '. escape('%{URL}', ' &!%')"
    if has("win32")
        let g:vikiOpenUrlWith_ANY = "exec 'silent !rundll32 url.dll,FileProtocolHandler '. shellescape('%{URL}')"
    elseif has("mac")
        let g:vikiOpenUrlWith_ANY = "exec 'silent !open '. escape('%{URL}', ' &!%')"
    elseif $GNOME_DESKTOP_SESSION_ID != ""
        let g:vikiOpenUrlWith_ANY = "exec 'silent !gnome-open '. shellescape('%{URL}')"
    elseif $KDEDIR != ""
        let g:vikiOpenUrlWith_ANY = "exec 'silent !kfmclient exec '. shellescape('%{URL}')"
    endif
endif

if !exists("*VikiOpenSpecialProtocol") "{{{2
    function! VikiOpenSpecialProtocol(url) "{{{3
        " TLogVAR a:url
        " TLogVAR a:url
        let proto = tolower(matchstr(a:url, '\c^[a-z]\{-}\ze:'))
        let prot  = 'g:vikiOpenUrlWith_'. proto
        let protp = exists(prot)
        if !protp
            let prot  = 'g:vikiOpenUrlWith_ANY'
            let protp = exists(prot)
        endif
        if protp
            exec 'let openURL = '. prot
            " let url = shellescape(a:url)
            let url = a:url
            " TLogVAR url, a:url
            let openURL = viki#SubstituteArgs(openURL, 'URL', url)
            " TLogVAR openURL
            call viki#ExecExternal(openURL)
        else
            throw 'Viki: Please define g:vikiOpenUrlWith_'. proto .' or g:vikiOpenUrlWith_ANY!'
        endif
    endf
endif


" This is mostly a legacy function. Using set ft=viki should work too.
" Set filetype=viki
function! VikiMode(...) "{{{3
    TVarArg 'family'
    " if exists('b:vikiEnabled')
    "     if b:vikiEnabled
    "         return 0
    "     endif
    "     " if b:vikiEnabled && a:state < 0
    "     "     return 0
    "     " endif
    "     " echom "VIKI: Viki mode already set."
    " endif
    unlet! b:did_ftplugin
    if !empty(family)
        let b:vikiFamily = family
    endif
    set filetype=viki
endf


if g:vikiMenuPrefix != '' "{{{2
    exec 'amenu '. g:vikiMenuPrefix .'Home :VikiHome<cr>'
    exec 'amenu '. g:vikiMenuPrefix .'-SepViki1- :'
endif


command! -nargs=+ VikiDefine call viki#Define(<f-args>)
command! -count VikiFindNext call viki#DispatchOnFamily('Find', '', '',  <count>)
command! -count VikiFindPrev call viki#DispatchOnFamily('Find', '', 'b', <count>)

" command! -nargs=* -range=% VikiMarkInexistent
"             \ call VikiSaveCursorPosition()
"             \ | call <SID>VikiMarkInexistent(<line1>, <line2>, <f-args>)
"             \ | call VikiRestoreCursorPosition()
"             \ | call <SID>ResetSavedCursorPosition()
command! -nargs=* -range=% VikiMarkInexistent call viki#MarkInexistentInRange(<line1>, <line2>)

command! -nargs=? -bar VikiMinorMode call viki#DispatchOnFamily('MinorMode', empty(<q-args>) && exists('b:vikiFamily') ? b:vikiFamily : <q-args>, 1)
command! -nargs=? -bar VikiMinorModeMaybe echom "Deprecated command: VikiMinorModeMaybe" | VikiMinorMode <q-args>
command! VikiMinorModeViki call viki_viki#MinorMode(1)
command! VikiMinorModeLaTeX call viki_latex#MinorMode(1)
command! VikiMinorModeAnyWord call viki_anyword#MinorMode(1)

" this requires imaps to be installed
command! -range VikiQuote :call VEnclose("[-", "-]", "[-", "-]")

command! -nargs=? -bar VikiMode call VikiMode(<q-args>)
command! -nargs=? -bar VikiModeMaybe echom "Deprecated command: VikiModeMaybe: Please use 'set ft=viki' instead" | call VikiMode(<q-args>)

command! -narg=? VikiGoBack call viki#GoBack(<f-args>)

command! VikiJump call viki#MaybeFollowLink(0,1)

command! VikiIndex :call viki#Index()

command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEdit :call viki#Edit(<q-args>, "<bang>")
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInVim :call viki#Edit(<q-args>, "<bang>", 0, 1)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditTab :call viki#Edit(<q-args>, "<bang>", 'tab')
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin1 :call viki#Edit(<q-args>, "<bang>", 1)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin2 :call viki#Edit(<q-args>, "<bang>", 2)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin3 :call viki#Edit(<q-args>, "<bang>", 3)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin4 :call viki#Edit(<q-args>, "<bang>", 4)

command! -nargs=1 -complete=customlist,viki#BrowseComplete VikiBrowse :call viki#Browse(<q-args>)

command! VikiHome :call viki#Edit('*', '!')
command! VIKI :call viki#Edit('*', '!')

command! VikiFilesUpdate call viki#FilesUpdate()
command! VikiFilesUpdateAll call viki#FilesUpdateAll()

command! -nargs=* -bang -complete=command VikiFileExec call viki#FilesExec(<q-args>, '<bang>', 1)
command! -nargs=* -bang -complete=command VikiFilesExec call viki#FilesExec(<q-args>, '<bang>')
command! -nargs=* -bang VikiFilesCmd call viki#FilesCmd(<q-args>, '<bang>')
command! -nargs=* -bang VikiFilesCall call viki#FilesCall(<q-args>, '<bang>')


augroup viki
    au!
    autocmd BufEnter * call viki#MinorModeReset()
    autocmd BufEnter * call viki#CheckInexistent()
    autocmd BufLeave * if &filetype == 'viki' | let b:vikiCheckInexistent = line(".") | endif
    autocmd BufWritePost,BufUnload * if &filetype == 'viki' | call viki#SaveCache() | endif
    autocmd VimLeavePre * let g:vikiEnabled = 0
    if g:vikiSaveHistory
        autocmd VimEnter * if exists('VIKIBACKREFS_STRING') | exec 'let g:VIKIBACKREFS = '. VIKIBACKREFS_STRING | unlet VIKIBACKREFS_STRING | endif
        autocmd VimLeavePre * let VIKIBACKREFS_STRING = string(g:VIKIBACKREFS)
    endif
    " As viki uses its own styles, we have to reset &filetype.
    autocmd ColorScheme * if &filetype == 'viki' | set filetype=viki | endif
augroup END


finish "{{{1
______________________________________________________________________________

* Change Log
1.0
- Extended names: For compatibility reasons with other wikis, the anchor is 
now in the reference part.
- For compatibility reasons with other wikis, prepending an anchor with 
b:commentStart is optional.
- g:vikiUseParentSuffix
- Renamed variables & functions (basically s/Wiki/Viki/g)
- added a ftplugin stub, moved the description to a help file
- "[--]" is reference to current file
- Folding support (at section level)
- Intervikis
- More highlighting
- g:vikiFamily, b:vikiFamily
- VikiGoBack() (persistent history data)
- rudimentary LaTeX support ("soft" viki names)

1.1
- g:vikiExplorer (for viewing directories)
- preliminary support for "soft" anchors (b:vikiAnchorRx)
- improved VikiOpenSpecialProtocol(url); g:vikiOpenUrlWith_{PROTOCOL}, 
g:vikiOpenUrlWith_ANY
- improved VikiOpenSpecialFile(file); g:vikiOpenFileWith_{SUFFIX}, 
g:vikiOpenFileWith_ANY
- anchors may contain upper characters (but must begin with a lower char)
- some support for Mozilla ThunderBird mailbox-URLs (this requires spaces to 
be encoded as %20)
- changed g:vikiDefSep to ''

1.2
- syntax file: fix nested regexp problem
- deplate: conversion to html/latex; download from 
http://sourceforge.net/projects/deplate/
- made syntax a little bit more restrictive (*WORD* now matches /\*\w+\*/ 
instead of /\*\S+\*/)
- interviki definitions can now be buffer local variables, too
- fixed <SID>DecodeFileUrl(dest)
- some kind of compiler plugin (uses deplate)
- removed g/b:vikiMarkupEndsWithNewline variable
- saved all files in unix format (thanks to Grant Bowman for the hint)
- removed international characters from g:vikiLowerCharacters and 
g:vikiUpperCharacters because of difficulties with different encodings (thanks 
to Grant Bowman for pointing out this problem); non-english-speaking users have 
to set these variables in their vimrc file

1.3
- basic ctags support (see |viki-tags|)
- mini-ftplugin for bibtex files (use record labels as anchors)
- added mapping <LocalLeader><c-cr>: follow link in other window (if any)
- disabled the highlighting of italic char styles (i.e., /text/)
- the ftplugin doesn't set deplate as the compiler; renamed the compiler plugin to deplate
- syntax: sync minlines=50
- fix: VikiFoldLevel()

1.3.1
- fixed bug when VikiBack was called without a definitiv back-reference
- fixed problems with latin-1 characters

1.4
- fixed problem with table highlighting that could cause vim to hang
- it is now possible to selectivly disable simple or quoted viki names
- indent plugin

1.5
- distinguish between links to existing and non-existing files
- added key bindings <LL>vs (split) and <LL>vv (split vertically)
- added key bindings <LL>v1 through to <LL>v4: open the viki link under cursor 
in the windows 1 to 4
- handle variables g:vikiSplit, b:vikiSplit
- don't indent regions
- regions can be indented
- When a file doesn't exist, ESC or "n" aborts creation

1.5.1
- depends on multvals >= 3.8.0
- new viki family "AnyWord" (see |viki-any-word|), which turns any word into a 
potential viki link
- <LocalLeader>vq, VikiQuote: mark selected text as a quoted viki name 
(requires imaps.vim, vimscript #244 or vimscript #475)
- check for null links when pressing <space>, <cr>, ], and some other keys 
(defined in g:vikiMapKeys)
- a global suffix for viki files can be defined by g:vikiNameSuffix
- fix syntax problem when checking for links to inexistent files

1.5.2
- changed default markup of textstyles: __emphasize__, ''code''; the 
previous markup can be re-enabled by setting g:vikiTextstylesVer to 1)
- fixed problem with VikiQuote
- on follow link check for yet unsaved buffers too

1.6
- b:vikiInverseFold: Inverse folding of subsections
- support for some regions/commands/macros: #INC/#INCLUDE, #IMG, #Img 
(requires an id to be defined), {img}
- g:vikiFreeMarker: Search for the plain anchor text if no explicitly marked 
anchor could be found.
- new command: VikiEdit NAME ... allows editing of arbitrary viki names (also 
understands extended and interviki formats)
- setting the b:vikiNoSimpleNames to true prevents viki from recognizing 
simple viki names
- made some script local functions global so that it should be easier to 
integrate viki with other plugins
- fixed moving cursor on <SID>VikiMarkInexistent()
- fixed typo in b:VikiEnabled, which should be b:vikiEnabled (thanks to Ned 
Konz)

1.6.1
- removed forgotten debug message
- fixed indentation bug

1.6.2
- b:vikiDisableType
- Put AnyWord-related stuff into a file of its own.
- indentation for notices (!!!, ??? etc.)

1.6.3
- When creating a new file by following a link, the desired window number was 
ignored
- (VikiOpenSpecialFile) Escape blanks in the filename
- Set &include and &define (ftplugin)
- Set g:vikiFolds to '' to avoid using Headings for folds (which may cause a 
major slowdown on slower machines)
- renamed <SID>DecodeFileUrl(dest) to VikiDecomposeUrl()
- fixed problem with table highlighting
- file type URLs (file://) are now treated like special files
- indent: if g:vikiIndentDesc is '::', align a definition's description to the 
first non-blank position after the '::' separator

1.7
- g:vikiHomePage: If you call VikiEdit! (with "bang"), the homepage is opened 
first so that its customizations are in effect. Also, if you call :VikiHome or 
:VikiEdit *, the homepage is opened.
- basic highlighting & indentation of emacs-planner style task lists (sort of)
- command line completion for :VikiEdit
- new command/function VikiDefine for defining intervikis
- added <LocalLeader>ve map for :VikiEdit
- fixed problem in VikiEdit (when the cursor was on a valid viki link, the 
text argument was ignored)
- fixed opening special files/urls in a designated window
- fixed highlighting of comments
- vikiLowerCharacters and vikiUpperCharacters can be buffer local
- fixed problem when an url contained an ampersand
- fixed error message when the &hidden option wasn't set (see g:vikiHide)

1.8
- Fold lists too (see also g:vikiFolds)
- Allow interviki names in extended viki names (e.g., 
[[WIKI::WikiName][Display Name]])
- Renamed <SID>GetSimpleRx4SimpleWikiName() to 
VikiGetSimpleRx4SimpleWikiName() (required in some occasions; increased the 
version number so that we can check against it)
- Fix: Problem with urls/fnames containing '!' and other special characters 
(which now have to be escaped by the handler; so if you defined a custom 
handler, e.g. g:vikiOpenFileWith_ANY, please adapt its definition)
- Fix: VikiEdit! opens the homepage only when b:vikiEnabled is defined in the 
current buffer (we assume that for the homepage the global configuration is in 
effect)
- Fix: Problem when g:vikiMarkInexistent was false/0
- Fix: Removed \c from the regular expression for extended names, which caused 
FindNext to malfunction and caused a serious slowdown when matching of 
bad/unknown links
- Fix: Re-set viki minor mode after entering a buffer
- The state argument in Viki(Minor)Mode is now mostly ignored
- Fix: A simple name's anchor was ignored

1.9
- Register mp3, ogg and some other multimedia related suffixes as 
special files
- Add a menu of Intervikis if g:vikiMenuPrefix is != ''
- g:vikiMapKeys can contain "\n" and " " (supplement g:vikiMapKeys with 
the variables g:vikiMapQParaKeys and g:vikiMapBeforeKeys)
- FIX: <SID>IsSupportedType
- FIX: Only the first inexistent link in a line was highlighted
- FIX: Set &buflisted when editing an existing buffer
- FIX: VikiDefine: Non-viki index names weren't quoted
- FIX: In "minor mode", vikiFamily wasn't correctly set in some 
situations; other problems related to b:vikiFamily
- FIX: AnyWord works again
- Removed: VikiMinorModeMaybe
- VikiDefine now takes an optional fourth argument (an index file; 
default=Index) and automatically creates a vim command with the name of 
the interviki that opens this index file

1.10
- Pseudo anchors (not supported by deplate):
-- Jump to a line number, e.g. [[file#l=10]] or [[file#line=10]]
-- Find an regexp, e.g. [[file#rx=\\d]]
-- Execute some vim code, e.g. [[file#vim=call Whatever()]]
-- You can define your own handlers: VikiAnchor_{type}(arg)
- g:vikiFolds: new 'b' flag: the body has a higher level than all 
headings (gives you some kind of outliner experience; the default value 
for g:vikiFolds was changed to 'h')
- FIX: VikiFindAnchor didn't work properly in some situations
- FIX: Escape blanks when following a link (this could cause problems in 
some situations, not always)
- FIX: Don't try to mark inexistent links when pressing enter if the current 
line is empty.
- FIX: Restore vertical cursor position in window after looking for 
inexistent links.
- FIX: Backslashes got lost in some situations.

1.11
- Enable [[INTERVIKI::]]
- VikiEdit also creates commands for intervikis that have no index
- Respect "!" and "*" modifiers in extended viki links
- New g:vikiMapFunctionalityMinor variable
- New g:vikiMapLeader variable
- CHANGE: Don't map VikiMarkInexistent in minor mode (see 
g:vikiMapFunctionalityMinor)
- CHANGE: new attributes for g:vikiMapFunctionality: c, m[fb], i, I
- SYNTAX: cterm support for todo lists, emphasize
- FIX: Erroneous cursor movement
- FIX: VikiEdit didn't check if a file was already opened, which caused 
a file to be opened in two buffers under certain conditions
- FIX: Error in <SID>MapMarkInexistent()
- FIX: VikiEdit: Non-viki names were not quoted
- FIX: Use fnamemodify() to expand tildes in filenames
- FIX: Inexistent quoted viki names with an interviki prefix weren't 
properly highlighted
- FIX: Minor problem with suffixes & extended viki names
- FIX: Use keepjumps
- FIX: Catch E325
- FIX: Don't catch errors in <SID>EditWrapper() if the command matches 
g:vikiNoWrapper (due to possible compatibility problems eg with :Explore 
in vim 6.4)
- OBSOLETE: Negative arguments to VikiMode or VikiMinorMode are obsolete 
(or they became the default to be precise)
- OBSOLETE: g:vikiMapMouse
- REMOVED: mapping to <LocalLeader><c-cr>
- DEPRECATED: VikiModeMaybe

1.12
- Define some keywords in syntax file (useful for omnicompletion)
- Define :VIKI command as an alias for :VikiHome
- FIX: Problem with names containing spaces
- FIX: Extended names with suffix & interviki
- FIX: Indentation of priority lists.
- FIX: VikiDefine created wrong (old-fashioned) VikiEdit commands under 
certain conditions.
- FIX: Directories in extended viki names + interviki names were marked 
as inexistent
- FIX: Syntax highlighting of regions or commands the headline of which 
spanned several lines
- Added ppt to g:vikiSpecialFiles.

1.13
- Intervikis can now be defined as function ('*Function("%s")', this 
breaks conversion via deplate) or format string ('%/foo/%s/bar', not yet 
supported by deplate)
- Task lists take optional tags, eg #A [tag] foo; they may also be 
tagged with the letters G-Z, which are highlighted as general task (not 
supported by deplate)
- Automatically set marks for labels prefixed with "m" (eg #ma -> 'a, 
#mB -> 'B)
- Two new g:vikiNameTypes: w = (Hyper)Words, f = File names in cwd as 
hyperwords (experimental, not implemented in deplate)
- In extended viki names: add the suffix only if the destination hasn't 
got one
- A buffer local b:vikiOpenInWindow allows links to be redirected to a 
certain window (ie, if b:vikiOpenInWindow = 2, pressing <c-cr> behaves 
like <LocalLeader>v2); this is useful if you use some kind of 
directory/catalog metafile; possible values: absolute number, +/- 
relative number, "last"
- Switched back to old regexp for simple names in order to avoid 
highlighting of names like LaTeX
- VikiEdit opens the homepage only if b:vikiFamily is set
- Map <LocalLeader>vF to <LocalLeader>vn<LocalLeader>vf
- Improved syntax for (nested) macros
- Set &suffixesadd so that you can use vim's own gf in some situations
- SYNTAX: Allow empty lines as region delimiters (deplate 0.8.1)
- FIX: simple viki names with anchors where not recognised
- FIX: don't mark simple (inter)viki names as inexistent that expand to 
links matching g:vikiSpecialProtocols
- FIX: file names containing %
- FIX: added a patch (VikiMarkInexistentInElement) by Kevin Kleinfelter 
for compatibility with an unpatched vim70 (untested)
- FIX: disabling simple names (s) also properly disables the name types: 
Scwf

2.0
- Got rid of multvals & genutils dependencies (use vim7 lists instead)
- New dependency: tlib.vim (vimscript #1863)
- INCOMPATIBLE CHANGE: The format of g:vikiMapFunctionality has changed.
- INCOMPATIBLE CHANGE: g:vikiSpecialFiles is now a list!
- Viki now has a special #Files region that can be automatically 
updated. This way we can start thinking about using viki for as 
project/file management tool. This is for vim only and not supported yet 
in deplate. New related maps & commands: :VikiFilesUpdate (<LL>vu), 
:VikiFilesUpdateAll (<LL>vU), :VikiFilesCmd, :VikiFilesCall, 
:VikiFilesExec (<LL>vx), and VikiFileExec.
- VikiGoParent() (mapped to <LL>v<bs> or <LL>v<up>): If b:vikiParent is 
defined, open this viki name, otherwise follow the backlink.
- New :VikiEditTab command.
- Map <LL>vt to open in tab.
- Map <LL>v<left> to open go back.
- Keys listed in g:vikiMapQParaKeys are now mapped to 
s:VikiMarkInexistentInParagraphVisible() which checks only the visible 
area and thus avoids scrolling.
- Highlight lines containing blanks (which vim doesn't treat as 
paragraph separators)
- When following a link, check if it is an special viki name before 
assuming it's a simple one.
- Map [[, ]], [], ][
- If an interviki has an index file, a viki name like [[INTERVIKI::]] 
will now open the index file. In order to browse the directory, use 
[[INTERVIKI::.]]. If no index file is defined, the directory will be 
opened either way.
- Set the default value of g:vikiFeedbackMin to &lines.
- Added ws as special files to be opened with :WsOpen if existent.
- Replaced most occurences of <SID> with s:
- Use tlib#input#List() for selecting back references.
- g:vikiOpenFileWith_ANY now uses g:netrw_browsex_viewer by default.
- CHANGE: g:vikiSaveHistory: We now rely on viminfo's "!" option to save 
back-references.
- FIX: VikiEdit now works properly with protocols that are to be opened 
with an external viewer
- FIX: VikiEdit completion, which is more usable now

2.1
- Cache inexistent patterns (experimental)
- s:EditWrapper: Don't escape ' '.
- FIX: VikiMode(): Error message about b:did_ftplugin not being defined
- FIX: Check if g:netrw_browsex_viewer is defined (thanks to Erik Olsson 
for pointing this and some other problems out)
- ftplugin/viki.vim: FIX: Problem with heading in the last line.  
Disabled vikiFolds type 's' (until I find out what this was about)
- Always check the current line for inexistent links when re-entering a 
viki buffer

2.2
- Re-Enabled the previously (2.1) made and then disabled change 
concerning re-entering a viki buffer
- Don't try to use cached values for buffers that have no file attached 
yet (thanks to Erik Olsson)
- Require tlib >= 0.8

2.3
- Require tlib >= 0.9
- FIX: Use absolute file names when editing a local file (avoid problem 
when opening a file in a different window with a different CWD).
- New folding routine. Use the old folding method by setting 
g:vikiFoldMethodVersion to 1.

2.4
- The shortcuts automatically defined by VikiDefine may now take an 
optional argument (the file on an interviki) (:WIKI thus is the same as 
:VikiEdit WIKI:: and supports the same command-line completion)
- Read ".vikiWords" in parent directories (top-down); 
g:vikiHyperWordsFiles: Changed order (read global words first)
- In .vikiWords: destination can be an interviki name (if not, it is 
assumed to be a relative filename); if destination is -, the word will 
be removed from the jump table; blanks in "hyperwords" will be replaced 
with \s\+ in the regular expression.
- New :VikiBrowse command.
- FIX: wrong value for &comments
- FIX: need to reset filetype on color-scheme change (because of viki's 
own styles)
- FIX: Caching of inexistent viki names.
- In minor mode, don't map keys that trigger a check for inexistent 
links.
- Don't highlight textstyles (emphasized, typewriter) in comments.
- Removed configuration by: VikiInexistentColor(), 
g:vikiInexistentColor, VikiHyperLinkColor(), g:vikiHyperLinkColor; use 
g:viki_highlight_hyperlink_light, g:viki_highlight_hyperlink_dark, 
g:viki_highlight_inexistent_light, g:viki_highlight_inexistent_dark 
instead. By default, links are no longer made bold.
- The new default fold expression (g:vikiFoldMethodVersion=4) support 
only hH folds (normal and inverse headings based; see g:vikiFolds). 
Previous fold methods can be used by setting g:vikiFoldMethodVersion.

3.0
- VikiFolds() rev4: The text body is set to max heading level + 1 in 
order to avoid lookups and thus speed-up the code.
- g:vikiPromote: Don't set viki minor modes for any files opened via 
viki, unless this variable is set
- Added support for 'l' vikiFolds to the default fold expression.
- Added support for the {ref} macro (the referenced label has to be in 
the same file though)
- INCOMPATIBLE CHANGE: Moved most function to autoload/viki.vim; moved 
support for deplate/viki markup to vikiDeplate.vim.
- The argument of the VikiMode() has changed. (But this function 
shouldn't be used anyway.)
- With g:vikiFoldMethodVersion=4 (the default), the text body is at the 
level of the heading. This uses "=" for the body, which can be a problem 
on slow machines. With g:vikiFoldMethodVersion=5, the body is below the 
lowest heading, which can cause other problem.
- :VikiEditInVim ... edit special files in vim
- Set the default value for g:vikiCacheInexistent in order not to 
surprise users with the abundance of cached data.
- Require tlib 0.15
- Use tlib#progressbar
- Improved (poor-man's) tex/math syntax highlighting
- Removed norm! commands form s:MarkInexistent().
- FIX: Wrong value for b:vikiSimpleNameAnchorIdx when simple viki names 
weren't disabled.
- Optionally use hookcursormoved for improved detection of hyperlinks to 
inexistent sources. If this plugin causes difficulties, please tell me 
and temporarily remove it.
- Use matchlist() instead of substitute(), which could speed things up a 
little.

3.1
- Slightly improved performance of s:MarkInexistent() and 
viki#HookCheckPreviousPosition().

3.2
- viki_viki.vim: Wrong value for b:vikiCmdDestIdx and 
b:vikiCmdAnchorIdx.
- Moved :VikiMinorModeViki, :VikiMinorModeLaTeX, and 
:VikiMinorModeAnyWord to plugin/viki.vim

3.3
- Use hookcursormoved >= 0.3
- Backslash-save command-line completion
- Mark unknown intervikis as inexistent

3.4
- Promote anchors to VikiOpenSpecialProtocol().
- viki_viki: Enabled #INCLUDE
- Put the poor-man's math highlighting into syntax/texmath.vim so that 
it can be included from other syntax files.
- Cascade menu of intervikis
- FIX: don't register viki names as known/unknown more than once

3.5
- Don't try to append an empty anchor to an url (Thanks RM Schmid).
- New variable g:viki_intervikis to define intervikis in ~/.vimrc.
- Minor updates to the help file.

3.6
- Forgot to define a default value for g:viki_intervikis.

3.7
- In a file that doesn't contain headings, return 0 instead of '=' as 
default value if g:vikiFoldMethodVersion == 4.
- FIX: "=" in if expressions in certain versions of VikiFoldLevel()

3.8
- FIX: viki#MarkInexistentInElement() for pre 7.0.009 vim (thanks to M 
Brandmeyer)
- FIX: Make sure tlib is loaded even if it is installed in a different 
rtp-directory (thanks to M Brandmeyer)
- Added dia to g:vikiSpecialFiles
- FIX: Scrambled window when opening an url from vim (thanks A Moell)

3.9
- VikiOpenSpecialFile() uses fnameescape()

3.10
- FIX: automatically set marks (#m? type of anchors)
- Anchor regexp can be configured via g:vikiAnchorNameRx

3.11
- Disabled regions' #END-syntax
- Don't define interviki commands if a command of the same name already 
exists.
- Default values for g:vikiOpenUrlWith_ANY and g:vikiOpenFileWith_ANY on 
Macs (thanks mboniou)
- Correct default value for g:vikiOpenFileWith_ANY @ Windows

" vim: ff=unix
