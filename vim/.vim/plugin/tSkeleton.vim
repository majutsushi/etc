" tSkeleton.vim
" @Author:      Thomas Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     21-Sep-2004.
" @Last Change: 2008-11-17.
" @Revision:    3791
"
" GetLatestVimScripts: 1160 1 tSkeleton.vim
" http://www.vim.org/scripts/script.php?script_id=1160
"
" TODO:
" - When bits change, opened hidden buffer don't get updated it seems.
" - Enable multiple skeleton directories (and maybe other sources like 
"   DBs).
" - Sorted menus.
" - ADD: More html bits
" - ADD: <tskel:post> embedded tag (evaluate some vim code on the visual 
"   region covering the final expansion)


if &cp || exists("loaded_tskeleton") "{{{2
    finish
endif
if !exists('loaded_tlib') || loaded_tlib < 14
    runtime plugin/02tlib.vim
    if !exists('loaded_tlib') || loaded_tlib < 14
        echoerr "tSkeleton requires tlib >= 0.14"
        finish
    endif
endif
let loaded_tskeleton = 405


if !exists("g:tskelDir") "{{{2
    let g:tskelDir = get(split(globpath(&rtp, 'skeletons/'), '\n'), 0, '')
endif
if !isdirectory(g:tskelDir) "{{{2
    echoerr 'tSkeleton: g:tskelDir ('. g:tskelDir .') isn''t readable. See :help tSkeleton-install for details!'
    finish
endif
let g:tskelDir = tlib#dir#CanonicName(g:tskelDir)


if !exists('g:tskelMapsDir') "{{{2
    let g:tskelMapsDir = g:tskelDir .'map/'
endif
let g:tskelMapsDir = tlib#dir#CanonicName(g:tskelDir)

if !exists('g:tskelBitsDir') "{{{2
    let g:tskelBitsDir = g:tskelDir .'bits/'
    call tlib#dir#Ensure(g:tskelBitsDir)
endif


if !exists("g:tskelTypes") "{{{2
    " 'skeleton' (standard tSkeleton functionality)
    " 'abbreviations' (VIM abbreviations)
    " 'functions' (VIM script functions extracted from :function)
    " 'mini' ("mini" bits, one-liners etc.)
    " 'tags' (tags-based code templates, requires ctags, I presume)
    let g:tskelTypes = ['skeleton', 'mini']
endif

if !exists('g:tskelLicense') "{{{2
    let g:tskelLicense = 'GPL (see http://www.gnu.org/licenses/gpl.txt)'
endif

if !exists("g:tskelMapLeader")     | let g:tskelMapLeader     = "<Leader>#"   | endif "{{{2
if !exists("g:tskelMapInsert")     | let g:tskelMapInsert     = '<c-\><c-\>'  | endif "{{{2
if !exists("g:tskelAddMapInsert")  | let g:tskelAddMapInsert  = 0             | endif "{{{2
if !exists("g:tskelMarkerHiGroup") | let g:tskelMarkerHiGroup = 'Special'     | endif "{{{2
if !exists("g:tskelMarkerLeft")    | let g:tskelMarkerLeft    = "<+"           | endif "{{{2
if !exists("g:tskelMarkerRight")   | let g:tskelMarkerRight   = "+>"           | endif "{{{2
if !exists('g:tskelMarkerExtra')   | let g:tskelMarkerExtra   = '???\|+++\|!!!\|###' | endif
if !exists("g:tskelMarkerCursor_mark") | let g:tskelMarkerCursor_mark = "CURSOR"           | endif "{{{2
if !exists("g:tskelMarkerCursor_volatile") | let g:tskelMarkerCursor_volatile = "/CURSOR"           | endif "{{{2
if !exists("g:tskelMarkerCursor_rx")   | let g:tskelMarkerCursor_rx = 'CURSOR\(/\(.\{-}\)\)\?' | endif "{{{2
if !exists("g:tskelDateFormat")    | let g:tskelDateFormat    = '%Y-%m-%d'    | endif "{{{2
if !exists("g:tskelUserName")      | let g:tskelUserName      = g:tskelMarkerLeft."NAME".g:tskelMarkerRight    | endif "{{{2
if !exists("g:tskelUserAddr")      | let g:tskelUserAddr      = g:tskelMarkerLeft."ADDRESS".g:tskelMarkerRight | endif "{{{2
if !exists("g:tskelUserEmail")     | let g:tskelUserEmail     = g:tskelMarkerLeft."EMAIL".g:tskelMarkerRight   | endif "{{{2
if !exists("g:tskelUserWWW")       | let g:tskelUserWWW       = g:tskelMarkerLeft."WWW".g:tskelMarkerRight     | endif "{{{2

if !exists("g:tskelRevisionMarkerRx") | let g:tskelRevisionMarkerRx = '@Revision:\s\+' | endif "{{{2
if !exists("g:tskelRevisionVerRx")    | let g:tskelRevisionVerRx = '\(RC\d*\|pre\d*\|p\d\+\|-\?\d\+\)\.' | endif "{{{2
if !exists("g:tskelRevisionGrpIdx")   | let g:tskelRevisionGrpIdx = 3 | endif "{{{2

if !exists("g:tskelMaxRecDepth") | let g:tskelMaxRecDepth = 10 | endif "{{{2
if !exists("g:tskelChangeDir")   | let g:tskelChangeDir   = 1  | endif "{{{2
if !exists("g:tskelMapComplete") | let g:tskelMapComplete = 1  | endif "{{{2
if g:tskelMapComplete
    set completefunc=tskeleton#Complete
endif

if !exists("g:tskelMenuPrefix")     | let g:tskelMenuPrefix  = 'TSke&l'    | endif "{{{2
if !exists("g:tskelMenuCache")      | let g:tskelMenuCache = '.tskelmenu'  | endif "{{{2
if !exists("g:tskelMenuPriority")   | let g:tskelMenuPriority = 90         | endif "{{{2
if !exists("g:tskelMenuMiniPrefix") | let g:tskelMenuMiniPrefix = 'etc.'   | endif "{{{2
if !exists("g:tskelAutoAbbrevs")    | let g:tskelAutoAbbrevs = 0           | endif "{{{2
if !exists("g:tskelAbbrevPostfix")  | let g:tskelAbbrevPostfix = '#'       | endif "{{{2

" By default bit names are case sensitive.
"  1 ... case sensitive
" -1 ... default (see 'smartcase')
"  0 ... case insensitive
if !exists("g:tskelCaseSensitive")        | let g:tskelCaseSensitive = 1        | endif "{{{2
if !exists("g:tskelCaseSensitive_html")   | let g:tskelCaseSensitive_html = 0   | endif "{{{2
if !exists("g:tskelCaseSensitive_bbcode") | let g:tskelCaseSensitive_bbcode = 0 | endif "{{{2

if !exists("g:tskelUseBufferCache") | let g:tskelUseBufferCache = 0             | endif "{{{2
if !exists("g:tskelBufferCacheDir") | let g:tskelBufferCacheDir = '.tskeleton'  | endif "{{{2

if !exists("g:tskelMenuPrefix_tags") | let g:tskelMenuPrefix_tags = 'Tags.' | endif "{{{2

if !exists("g:tskelQueryType") "{{{2
    " if has('gui_win32') || has('gui_win32s') || has('gui_gtk')
    "     let g:tskelQueryType = 'popup'
    " else
        let g:tskelQueryType = 'query'
    " end
endif

if !exists("g:tskelPopupNumbered") | let g:tskelPopupNumbered = 1 | endif "{{{2

" set this to v for using visual mode when calling TSkeletonGoToNextTag()
if !exists("g:tskelSelectTagMode") | let g:tskelSelectTagMode = 's' | endif "{{{2

if !exists("g:tskelKeyword_bbcode") | let g:tskelKeyword_bbcode = '\(\[\*\|[\[\\][*[:alnum:]]\{-}\)' | endif "{{{2
if !exists("g:tskelKeyword_bib")  | let g:tskelKeyword_bib  = '[@[:alnum:]]\{-}'       | endif "{{{2
if !exists("g:tskelKeyword_java") | let g:tskelKeyword_java = '[[:alnum:]_@<&]\{-}'    | endif "{{{2
if !exists("g:tskelKeyword_php")  | let g:tskelKeyword_java = '[[:alnum:]_@<&$]\{-}'   | endif "{{{2
if !exists("g:tskelKeyword_html") | let g:tskelKeyword_html = '<\?[^>[:blank:]]\{-}'   | endif "{{{2
if !exists("g:tskelKeyword_sh")   | let g:tskelKeyword_sh   = '[\[@${([:alpha:]]\{-}'  | endif "{{{2
if !exists("g:tskelKeyword_tex")  | let g:tskelKeyword_tex  = '\\\?\w\{-}'             | endif "{{{2
if !exists("g:tskelKeyword_viki") | let g:tskelKeyword_viki = '\(#\|{\|\\\)\?[^#{[:blank:][:punct:]-]\{-}' | endif "{{{2
" if !exists("g:tskelKeyword_viki") | let g:tskelKeyword_viki = '\(#\|{\)\?[^#{[:blank:]]\{-}' | endif "{{{2

if !exists("g:tskelBitGroup_html") "{{{2
    let g:tskelBitGroup_html = ['html', 'html_common']
endif
if !exists("g:tskelBitGroup_bbcode") "{{{2
    let g:tskelBitGroup_bbcode = ['bbcode', 'tex']
endif
if !exists("g:tskelBitGroup_php") "{{{2
    let g:tskelBitGroup_php  = ['php', 'html', 'html_common']
endif
if !exists("g:tskelBitGroup_java") "{{{2
    let g:tskelBitGroup_java = ['java', 'html_common']
endif
if !exists("g:tskelBitGroup_viki") "{{{2
    let g:tskelBitGroup_viki = ['tex', 'viki']
endif
if !exists("g:tskelBitGroup_xslt") "{{{2
    let g:tskelBitGroup_xslt = ['xslt', 'xml']
endif

let g:tskeleton_SetFiletype = 1


if !exists('*TSkeleton_FILE_DIRNAME') "{{{2
    function! TSkeleton_FILE_DIRNAME() "{{{3
        return tskeleton#EvalInDestBuffer('expand("%:p:h")')
    endf
endif


if !exists('*TSkeleton_FILE_SUFFIX') "{{{2
    function! TSkeleton_FILE_SUFFIX() "{{{3
        return tskeleton#EvalInDestBuffer('expand("%:e")')
    endf
endif


if !exists('*TSkeleton_FILE_NAME_ROOT') "{{{2
    function! TSkeleton_FILE_NAME_ROOT() "{{{3
        return tskeleton#EvalInDestBuffer('expand("%:t:r")')
    endf
endif


if !exists('*TSkeleton_FILE_NAME') "{{{2
    function! TSkeleton_FILE_NAME() "{{{3
        return tskeleton#EvalInDestBuffer('expand("%:t")')
    endf
endif


if !exists('*TSkeleton_NOTE') "{{{2
    function! TSkeleton_NOTE() "{{{3
        let title = tskeleton#GetVar("tskelTitle", 'input("Please describe the project: ")', '')
        let note  = title != "" ? " -- ".title : ""
        return note
    endf
endif


if !exists('*TSkeleton_DATE') "{{{2
    function! TSkeleton_DATE() "{{{3
        return strftime(tskeleton#GetVar('tskelDateFormat'))
    endf
endif


if !exists('*TSkeleton_TIME') "{{{2
    function! TSkeleton_TIME() "{{{3
        return strftime('%X')
    endf
endif


if !exists('*TSkeleton_AUTHOR') "{{{2
    function! TSkeleton_AUTHOR() "{{{3
        return tskeleton#GetVar('tskelUserName')
    endf
endif


if !exists('*TSkeleton_EMAIL') "{{{2
    function! TSkeleton_EMAIL() "{{{3
        let email = tskeleton#GetVar('tskelUserEmail')
        " return substitute(email, "@"," AT ", "g")
        return email
    endf
endif


if !exists('*TSkeleton_WEBSITE') "{{{2
    function! TSkeleton_WEBSITE() "{{{3
        return tskeleton#GetVar('tskelUserWWW')
    endf
endif


if !exists('*TSkeleton_LICENSE') "{{{2
    function! TSkeleton_LICENSE() "{{{3
        return tskeleton#GetVar('tskelLicense')
    endf
endif


function! TSkeletonCB_FILENAME() "{{{3
    return input('File name: ', '', 'file')
endf


function! TSkeletonCB_DIRNAME() "{{{3
    return input('Directory name: ', '', 'dir')
endf


function! TSkelNewScratchHook_viki()
    let b:vikiMarkInexistent = 0
endf


function! TSkeletonMapGoToNextTag() "{{{3
    nnoremap <silent> <c-j> :call tskeleton#GoToNextTag()<cr>
    vnoremap <silent> <c-j> <c-\><c-n>:call tskeleton#GoToNextTag()<cr>
    inoremap <silent> <c-j> <c-\><c-o>:call tskeleton#GoToNextTag()<cr>
endf


command! -nargs=* -complete=custom,tskeleton#SelectTemplate TSkeletonSetup 
            \ call tskeleton#Setup(<f-args>)


command! -nargs=? -complete=custom,tskeleton#SelectTemplate TSkeletonEdit 
            \ call tskeleton#Edit(<q-args>)


command! -nargs=? -complete=customlist,tskeleton#EditBitCompletion TSkeletonEditBit 
            \ call tskeleton#EditBit(<q-args>)


command! -nargs=* -complete=custom,tskeleton#SelectTemplate TSkeletonNewFile 
            \ call tskeleton#NewFile(<f-args>)


command! -bar -nargs=? TSkeletonBitReset call tskeleton#ResetBits(<q-args>)


command! -nargs=? -complete=custom,tskeleton#SelectBit TSkeletonBit
            \ call tskeleton#Bit(<q-args>)


command! TSkeletonCleanUpBibEntry call tskeleton#CleanUpBibEntry()

if !hasmapto("TSkeletonBit") "{{{2
    " noremap <unique> <Leader>tt ""diw:TSkeletonBit <c-r>"
    exec "noremap <unique> ". g:tskelMapLeader ."t :TSkeletonBit "
endif
if !hasmapto("tskeleton#ExpandBitUnderCursor") "{{{2
    exec "nnoremap <unique> ". g:tskelMapLeader ."# :call tskeleton#ExpandBitUnderCursor('n')<cr>"
    if g:tskelAddMapInsert
        exec "inoremap <unique> ". g:tskelMapInsert ." <c-\\><c-o>:call tskeleton#ExpandBitUnderCursor('i','', ". string(g:tskelMapInsert) .")<cr>"
    else
        exec "inoremap <unique> ". g:tskelMapInsert ." <c-\\><c-o>:call tskeleton#ExpandBitUnderCursor('i')<cr>"
    endif
endif
if !hasmapto("tskeleton#WithSelection") "{{{2
    exec "vnoremap <unique> ". g:tskelMapLeader ."# d:call tskeleton#WithSelection('')<cr>"
    exec "vnoremap <unique> ". g:tskelMapLeader ."<space> d:call tskeleton#WithSelection(' ')<cr>"
endif
if !hasmapto("tskeleton#LateExpand()") "{{{2
    exec "nnoremap <unique> ". g:tskelMapLeader ."x :call tskeleton#LateExpand()<cr>"
    exec "vnoremap <unique> ". g:tskelMapLeader ."x <esc>`<:call tskeleton#LateExpand()<cr>"
endif


augroup tSkeleton
    autocmd!
    if !exists("g:tskelDontSetup") "{{{2
        let s:cwd = getcwd()
        exec 'cd '. tlib#arg#Ex(g:tskelDir)
        try
            call map(split(glob('templates/**'), '\n'), 'tskeleton#DefineAutoCmd(v:val)')
        finally
            exec 'cd '. tlib#arg#Ex(s:cwd)
            unlet s:cwd
        endtry
        autocmd BufNewFile *.bat       TSkeletonSetup batch.bat
        autocmd BufNewFile *.tex       TSkeletonSetup latex.tex
        autocmd BufNewFile tc-*.rb     TSkeletonSetup tc-ruby.rb
        autocmd BufNewFile *.rb        TSkeletonSetup ruby.rb
        autocmd BufNewFile *.rbx       TSkeletonSetup ruby.rb
        autocmd BufNewFile *.sh        TSkeletonSetup shell.sh
        autocmd BufNewFile *.txt       TSkeletonSetup text.txt
        autocmd BufNewFile *.vim       TSkeletonSetup plugin.vim
        autocmd BufNewFile *.inc.php   TSkeletonSetup php.inc.php
        autocmd BufNewFile *.class.php TSkeletonSetup php.class.php
        autocmd BufNewFile *.php       TSkeletonSetup php.php
        autocmd BufNewFile *.tpl       TSkeletonSetup smarty.tpl
        autocmd BufNewFile *.html      TSkeletonSetup html.html
    endif

    " autocmd BufNewFile,BufRead */skeletons/* if g:tskeleton_SetFiletype | set ft=tskeleton | endif
    exec 'autocmd BufNewFile,BufRead '. escape(g:tskelDir, ' ') .'* if g:tskeleton_SetFiletype | set ft=tskeleton | endif'
    " exec 'autocmd BufEnter,BufNewFile,BufRead '. escape(g:tskelDir, ' ') .'* if g:tskeleton_SetFiletype | set ft=tskeleton | endif'
    " exec 'autocmd BufEnter '. escape(g:tskelDir, ' ') .'* if g:tskeleton_SetFiletype | set ft=tskeleton | endif'
    " exec 'autocmd BufWritePost '. escape(g:tskelBitsDir, ' ') .'* echom "TSkeletonBitReset ".expand("<afile>:p:h:t")'
    exec 'autocmd BufWritePost '. escape(g:tskelBitsDir, ' ') .'* exec "TSkeletonBitReset ".expand("<afile>:p:h:t")'
    " autocmd BufEnter * if (g:tskelMenuCache != '' && !tskeleton#IsScratchBuffer()) | call tskeleton#BuildBufferMenu(1) | else | call tskeleton#PrepareBits('', 1) | endif
    autocmd SessionLoadPost,BufEnter * if (g:tskelMenuCache != '' && !tskeleton#IsScratchBuffer()) | call tskeleton#BuildBufferMenu(1) | endif
    
    autocmd FileType bib if !hasmapto(":TSkeletonCleanUpBibEntry") | exec "noremap <buffer> ". g:tskelMapLeader ."c :TSkeletonCleanUpBibEntry<cr>" | endif
augroup END


call tskeleton#PrepareBits('general')


finish

-------------------------------------------------------------------
CHANGES:

1.0
- Initial release

1.1
- User-defined tags
- Modifiers <+NAME:MODIFIERS+> (c=capitalize, u=toupper, l=tolower, 
  s//=substitute)
- Skeleton bits
- the default markup for tags has changed to <+TAG+> (for 
  "compatibility" with imaps.vim), the cursor position is marked as 
  <+CURSOR+> (but this can be changed by setting g:tskelMarkerLeft, 
  g:tskelMarkerRight, and g:tskelMarkerCursor)
- in the not so simple mode, skeleton bits can contain vim code that 
  is evaluated after expanding the template tags (see 
  .../skeletons/bits/vim/if for an example)
- function TSkeletonExpandBitUnderCursor(), which is mapped to 
  <Leader>#
- utility function: TSkeletonIncreaseRevisionNumber()

1.2
- new pseudo tags: bit (recursive code skeletons), call (insert 
  function result)
- before & after sections in bit definitions may contain function 
  definitions
- fixed: no bit name given in s:SelectBit()
- don't use ={motion} to indent text, but simply shift it

1.3
- TSkeletonCleanUpBibEntry (mapped to <Leader>tc for bib files)
- complete set of bibtex entries
- fixed problem with [&bg]: tags
- fixed typo that caused some slowdown
- other bug fixes
- a query must be enclosed in question marks as in <+?Which ID?+>
- the "test_tSkeleton" skeleton can be used to test if tSkeleton is 
  working
- and: after/before blocks must not contain function definitions

1.4
- Popup menu with possible completions if 
  TSkeletonExpandBitUnderCursor() is called for an unknown code 
  skeleton (if there is only one possible completion, this one is 
  automatically selected)
- Make sure not to change the alternate file and not to distort the 
  window layout
- require genutils
- Syntax highlighting for code skeletons
- Skeleton bits can now be expanded anywhere in the line. This makes 
  it possible to sensibly use small bits like date or time.
- Minor adjustments
- g:tskelMapLeader for easy customization of key mapping (changed the 
  map leader to "<Leader>#" in order to avoid a conflict with Align; 
  set g:tskelMapLeader to "<Leader>t" to get the old mappings)
- Utility function: TSkeletonGoToNextTag(); imaps.vim like key 
  bindings via TSkeletonMapGoToNextTag()

1.5
- Menu of small skeleton "bits"
- TSkeletonLateExpand() (mapped to <Leader>#x)
- Disabled <Leader># mapping (use it as a prefix only)
- Fixed copy & paste error (loaded_genutils)
- g:tskelDir defaults to $HOME ."/vimfiles/skeletons/" on Win32
- Some speed-up

2.0
- You can define "groups of bits" (e.g. in php mode, all html bits are 
  available too)
- context sensitive expansions (only very few examples yet); this 
  causes some slowdown; if it is too slow, delete the files in 
  .vim/skeletons/map/
- one-line "mini bits" defined in either 
  ./vim/skeletons/bits/{&filetype}.txt or in $PWD/.tskelmini
- Added a few LaTeX, HTML and many Viki skeleton bits
- Added EncodeURL.vim
- Hierarchical bits menu by calling a bit "SUBMENU.BITNAME" (the 
  "namespace" is flat though; the prefix has no effect on the bit 
  name; see the "bib" directory for an example)
- the bit file may have an ampersand (&) in their names to define the 
  keyboard shortcut
- Some special characters in bit names may be encoded as hex (%XX as 
  in URLs)
- Insert mode: map g:tskelMapInsert ('<c-\><c-\>', which happens to be 
  the <c-#> key on a German qwertz keyboard) to 
  TSkeletonExpandBitUnderCursor()
- New <tskel:msg> tag in skeleton bits
- g:tskelKeyword_{&filetype} variable to define keywords by regexp 
  (when 'iskeyword' isn't flexible enough)
- removed the g:tskelSimpleBits option
- Fixed some problems with the menu
- Less use of globpath()

2.1
- Don't accidentally remove torn off menus; rebuild the menu less 
  often
- Maintain insert mode (don't switch back to normal mode) in 
  <c-\><c-\> imap
- If no menu support is available, use the s:Query function to let 
  the user select among eligible bits (see also g:tskelQueryType)
- Create a normal and an insert mode menu
- Fixed selection of eligible bits
- Ensure that g:tskelDir ends with a (back)slash
- Search for 'skeletons/' in &runtimepath & set g:tskelDir accordingly
- If a template is named "#.suffix", an autocmd is created  
  automatically.
- Set g:tskelQueryType to 'popup' only if gui is win32 or gtk.
- Minor tweak for vim 7.0 compatibility

2.2
- Don't display query menu, when there is only one eligible bit
- EncodeURL.vim now correctly en/decoded urls
- UTF8 compatibility -- use col() instead of virtcol() (thanks to Elliot 
  Shank)

2.3
- Support for current versions of genutils (> 2.0)

2.4
- Changed the default value for g:tskelDateFormat from "%d-%b-%Y" to 
'%Y-%m-%d'
- 2 changes to TSkeletonGoToNextTag(): use select mode (as does 
imaps.vim, set g:tskelSelectTagMode to 'v' to get the old behaviour), 
move the cursor one char to the left before searching for the next tag 
(thanks to M Stubenschrott)
- added a few AutoIt3 skeletons
- FIX: handle tabs properly
- FIX: problem with filetypes containing non-word characters
- FIX: check the value of &selection
- Enable normal tags for late expansion

3.0
- Partial rewrite for vim7 (drop vim6 support)
- Now depends on tlib (vimscript #1863)
- "query" now uses a more sophisticated version from autoload/tlib.vim
- The default value for g:tskelQueryType is "query".
- Experimental (proof of concept) code completion for vim script 
(already sourced user-defined functions only). Use :delf 
TSkelFiletypeBits_functions_vim to disable this as it can take some 
time on initialization.
- Experimental (proof of concept) tags-based code completion for ruby.  
Use :delf TSkelProcessTag_ruby to disable this. It's only partially 
useful as it simply works on method names and knows nothing about 
classes, modules etc. But it gives you an argument list to fill in. It 
shouldn't be too difficult to adapt this for other filetypes for which 
such an approach could be more useful.
- The code makes it now possible to somehow plug in custom bit types by 
defining TSkelFiletypeBits_{NAME}(dict, filetype), or 
TSkelFiletypeBits_{NAME}_{FILETYPE}(dict, filetype), 
TSkelBufferBits_{NAME}(dict, filetype), 
TSkelBufferBits_{NAME}_{FILETYPE}(dict, filetype).
- FIX s:RetrieveAgent_read(): Delete last line, which should fix the 
problem with extraneous return characters in recursively included 
skeleton bits.
- FIX: bits containing backslashes
- FIX TSkeletonGoToNextTag(): Moving cursor when no tag was found.
- FIX: Minibits are now properly displayed in the menu.

3.1
- Tag-based code completion for vim
- Made the supported skeleton types configurable via g:tskelTypes
- FIX: Tag-based skeletons the name of which contain blanks
- FIX: Undid shortcut that prevented the <+bit:+> tag from working
- Preliminary support for using keys like <space> for insert mode 
expansion.

3.2
- "tags" & "functions" types are disabled by default due to a noticeable 
delay on initialization; add 'tags' and 'functions' to g:tskelTypes to 
re-enable them (with the new caching strategy, it's usable, but can 
produce much noise; but this depends of course on the way you handle 
tags)
- Improved caching strategy: cache filetype bits in 
skeletons/cache_bits; cache buffer-specific bits in 
skeletons/cache_bbits/&filetype/path (set g:tskelUseBufferCache to 0 to 
turn this off; this speeds up things quite a lot but creates many files 
on the long run, so you might want to purge the cache from time to time)
- embedded <tskel:> tags are now extracted on initialization and not 
when the skeleton is expanded (I'm not sure yet if it is better this 
way)
- CHANGE: dropped support for the ~/.vim/skeletons/prefab subdirectory; 
you'll have to move the templates, if any, to ~/.vim/skeletons
- FIX: :TSkeletonEdit, :TSkeletonSetup command-line completion
- FIX: Problem with fold markers in bits when &fdm was marker
- FIX: Problems with PrepareBits()
- FIX: Problems when the skeletons/menu/ subdirectory didn't exist
- TSkeletonExecInDestBuffer(code): speed-up
- Moved functions from EncodeURL.vim to tlib.vim
- Updated the manual
- Renamed the skeletons/menu subdirectory to skeletons/cache_menu

3.3
- New :TSkeletonEditBit command
- FIX: Embedded <tskel> tags in file templates didn't work

3.4
- Automatically reset bits information after editing a bit.
- Automatically define autocommands for templates with the form "NAME 
PATTERN" (where "#" in the pattern is replaced with "*"), i.e. the 
template file "text #%2ffoo%2f#.txt" will define a template for all new 
files matching "*/foo/*.txt"; the filetype will be set to "text"
- These "auto templates" must be located in 
~/.vim/skeletons/templates/GROUP/
- TSkeletonCB_FILENAME(), TSkeletonCB_DIRNAME()
- FIX: TSkeletonGoToNextTag() didn't work properly with ### type of 
markers.
- FIX: TSkeletonLateExpand(): tag at first column
- FIX: In templates, empty lines sometimes were not inserted in the 
document
- FIX: Build menu on SessionLoadPost event.
- FIX: Protect against autocommands that move the cursor on a BufEnter 
event
- FIX: Some special characters in the skeleton bit expansion were escaped 
twice with backslashes.
- Require tlib 0.9
- Make sure &foldmethod=manual in the scratch buffer

3.5
- FIX: Minor problem with auto-templates

4.0
- Renamed g:tskelPattern* variables to g:tskelMarker*
- If g:tskelMarkerHiGroup is non-empty, place holders will be 
highlighted in this group.
- Re-enable 'mini' in g:tskelTypes.
- Calling TSkeletonBit with no argument, brings up the menu.
- Require tlib 0.12
- CHANGE: The cache is now stored in ~/vimfiles/cache/ (use 
tlib#cache#Filename)
- INCOMPATIBLE CHANGE: Use autoload/tskeleton.vim
- FIX: Problem with cache name
- FIX: Problem in s:IsDefined()
- FIX: TSkeletonEditBit completion didn't work before expanding a bit.
- FIX: Command-line completion when tSkeleton wasn't invoked yet (and 
menu wasn't built).

4.1
- Automatically define iabbreviations by adding [bg]:tskelAbbrevPostfix 
(default: '#') to the bit name (i.e., a bit with the file "foo.bar" will 
by default create the menu entry "TSkel.foo.bar" for the bit "bar" and 
the abbreviation "bar#"). If this causes problems, set 
g:tskelAutoAbbrevs to 0.
- Bits can have a <tskel:abbrev> section that defines the abbreviation.
- New type 'abbreviations': This will make your abbreviations accessible 
as a template (in case you can't remember their names)
- New experimental <tskel:condition> section (a vim expression) that 
checks if a bit is eligible in the current context.
- New <+input()+> tag.
- New <+execute()+> tag.
- New <+let(VAR=VALUE)+> tag.
- <+include(NAME)+> as synonym for <+bit:NAME+>.
- Experimental <+if()+> ... <+elseif()+> ... <+else+> ... <+endif+>, 
<+for(var in list)+> ... <+endfor+> tags.
- Special tags <+nop+>, <+joinline+>, <+nl+> to prevent certain 
problems.
- These special tags have to be lower case.
- Made tskeleton#GoToNextTag() smarter in recognizing something like: 
<+/DEFAULT+>.
- Defined <Leader>## and <Leader>#<space> (see g:tskelMapLeader) as 
visual command (the user will be queried for the name of a skeleton)
- Some functions have moved and changed names. It should now be possible 
to plug-in custom template expanders (or re-use others).
- Use append() via tlib#buffer#InsertText() to insert bits. This could 
cause old problems to reappear although it seems to work fine.
- The markup should now be properly configurable (per buffer; you can 
set template-specific markers in the tskel:here_before section).
- Require tlib 0.14
- The default value for g:tskelUseBufferCache is 0 as many people might 
find the accumulation of cached information somewhat surprising. Unless 
you use tag/functions type of skeleton bit, it's unnecessary anyway.
- Removed the dependency on genutils.
- The g:tskelMarkerCursor variable was removed and replaced with 
g:tskelMarkerCursor_mark and g:tskelMarkerCursor_rx.

4.2
- Enable <+CURSOR/foo+>. After expansion "foo" will be selected.
- New (old) default values: removed 'abbreviations' from g:tskelTypes 
and set g:tskelAutoAbbrevs to 0 in order to minimize surprises.
- Enabled tex-Skeletons for the viki filetype
- FIX: Place the cursor at the end of an inserted bit that contains no 
cursor marker (which was the original behaviour).
- Split html bits into html and html_common; the java group includes 
html_common.
- CHANGE: Made bit names case-sensitive
- NEW: select() tag (similar to the query tag)

4.3
- bbcode group
- tskelKeyword_{&ft} and tskelGroup_{&ft} variables can be buffer-local
- Case-sensitivity can be configured via [bg]:tskelCaseSensitive and 
[bg]:tskelCaseSensitive_{&filetype}
- Make sure tlib is loaded even if it is installed in a different 
rtp-directory

4.4
- Make sure tlib is loaded even if it is installed in a different 
rtp-directory

4.5
- Call s:InitBufferMenu() earlier.
- C modifier: Consider _ whitespace
- g:tskelMarkerExtra (extra markers for tskeleton#GoToNextTag)

