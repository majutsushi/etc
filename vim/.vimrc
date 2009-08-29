" This must be at the beginning
set nocompatible

" Autocommands {{{1

" remove all autocommands to avoid sourcing them twice
autocmd!

"au BufWritePost ~/.vimrc so ~/.vimrc

"if has("gui_running")
    autocmd InsertLeave * set nocul
    autocmd InsertEnter * set cul
"endif

autocmd BufNewFile,BufReadPost * call LoadProjectConfig()

" create undo break point
autocmd CursorHoldI * call feedkeys("\<C-G>u", "nt")

"au BufWritePre * let &bex = '-' . strftime("%Y%b%d%X") . '~'

" set the textwidth to 72 characters for replies (email&usenet)
au BufNewFile,BufReadPost .followup,.letter,mutt-*,muttng-*,nn.*,snd.* setlocal tw=72 completefunc=LBDBCompleteFn

" filetype-specific settings
au Filetype html,xml,xsl source ~/.vim/macros/closetag.vim
au FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
au FileType tex let b:vikiFamily="LaTeX"
au FileType viki compiler deplate
au FileType gtkrc setlocal tabstop=2 shiftwidth=2
au FileType haskell compiler ghc
au FileType mkd setlocal ai formatoptions=tcroqn2 comments=n:>
au FileType ruby setlocal omnifunc=rubycomplete#Complete
au FileType gitcommit DiffGitCached | wincmd p
au FileType python setlocal foldmethod=indent
au FileType python setlocal omnifunc=pythoncomplete#Complete

augroup cfile
    "au FileType c setlocal path+=/usr/include,/usr/include/sys,/usr/include/linux
    au FileType c,cpp setlocal foldmethod=syntax
    au FileType c,cpp setlocal tags+=~/.vim/systags/systags
    au FileType c,cpp setlocal cinoptions=t0,(0,)50
augroup END

augroup java
    au FileType java compiler javac
    au FileType java setlocal omnifunc=javacomplete#Complete
    au FileType java setlocal completefunc=javacomplete#CompleteParamsInfo
"    au FileType java setlocal cinoptions=t0,(0,j1,)50 " see after/indent/java.vim
augroup END

" setup templates
au BufNewFile *.tex Vimplate LaTeX
au BufNewFile *.sh Vimplate shell
au BufNewFile *.c Vimplate c
au BufNewFile *.vim Vimplate vim
au BufNewFile *.rb Vimplate ruby
au BufNewFile Makefile Vimplate Makefile-C

au BufWritePost,FileWritePost *.c TlistUpdate
"au CursorMoved,CursorMovedI * if bufwinnr(g:TagList_title) != -1
"au CursorMoved,CursorMovedI *   TlistHighlightTag
"au CursorMoved,CursorMovedI * endif

au BufWritePost,FileWritePost *.sh silent !chmod u+x %

" important {{{1
" set cpoptions TODO

" moving around, searching and patterns {{{1

" list of flags specifying which commands wrap to another line (local to window)
set whichwrap=<,>,b,s,[,]
" change to directory of file in buffer
"set autochdir

" show match for partly typed search command
set incsearch
" ignore case when using a search pattern
set ignorecase
" override 'ignorecase' when pattern has upper case characters
set smartcase

" pattern for a macro definition line (global or local to buffer)
set define=^\\(\\s*#\\s*define\\\|[a-z]*\\s*const\\s*[a-z]*\\)

" tags {{{1

" use cscope for tag commands
set cscopetag
" give messages when adding a cscope database
set cscopeverbose
" When to open a quickfix window for cscope
set cscopequickfix=s-,c-,d-,i-,t-,e-

" displaying text {{{1

" number of screen lines to show around the cursor
set scrolloff=8

" long lines wrap
set wrap
" wrap long lines at a character in 'breakat' (local to window)
set linebreak
" which characters might cause a line break
"set breakat=\ ^I
" string to put before wrapped screen lines
set showbreak=+\ 

" include "lastline" to show the last line even if it doesn't fit
" include "uhex" to show unprintable characters as a hex number
set display=lastline
" number of lines used for the command-line
"set cmdheight=2
" don't redraw while executing macros
set lazyredraw

" show <Tab> as ^I and end-of-line as $ (local to window)
set list
" list of strings used for list mode
if has("gui_running")
    set listchars=tab:»-,trail:␣,nbsp:~
else
    set listchars=tab:»-,trail:·,nbsp:~
endif

" show the line number for each line (local to window)
set number

" syntax, highlighting and spelling {{{1

" "dark" or "light"; the background color brightness
set background=dark
" highlight all matches for the last used search pattern
set hlsearch

if has("gui_running")
    colorscheme desert
else
    colorscheme desert256
endif

" multiple windows {{{1

" 0, 1 or 2; when to use a status line for the last window
set laststatus=2
" alternate format to be used for a status line
set statusline=%!GenerateStatusline()
" default height for the preview window
set previewheight=9
" don't unload a buffer when no longer shown in a window
set hidden
" "useopen" and/or "split"; which window to use when jumping to a buffer
set switchbuf=useopen " or usetab
" a new window is put below the current one
"set splitbelow

" multiple tab pages {{{1

if exists("+showtabline")
    " 0, 1 or 2; when to use a tab pages line
    set showtabline=1
    " custom tab pages line
    set tabline=%!MyTabLine()
endif

" terminal {{{1

" terminal connection is fast
set ttyfast
" show info in the window title
set title

if (&term =~ "xterm")
    set t_Co=256
endif

" http://ft.bewatermyfriend.org/comp/vim/vimrc.html
if (&term =~ '^screen')
    set t_ts=k
    set t_fs=\
    autocmd BufEnter * let &titlestring = "vim(" . expand("%:t") . ")"
endif

" using the mouse {{{1

" list of flags for using the mouse
set mouse=a
" "extend", "popup" or "popup_setpos"; what the right mouse button is used for
set mousemodel=popup
" "xterm", "xterm2", "dec" or "netterm"; type of mouse
set ttymouse=xterm

" GUI {{{1

if has("gui_running")
    " list of font names to be used in the GUI
    set guifont=Monospace\ 8

    " list of flags that specify how the GUI works
    set guioptions+=c
    set guioptions-=T
    set guioptions-=e

    " "no", "yes" or "menu"; how to use the ALT key
    "set winaltkeys=no

    hi SignColumn guibg=grey20
endif

if exists('&macatsui')
    set nomacatsui
endif

" printing {{{1

" list of items that control the format of :hardcopy output
set printoptions=number:y,paper:A4,left:5pc,right:5pc,top:5pc,bottom:5pc
" name of the font to be used for :hardcopy
set printfont=Monospace\ 8

" expression used to print the PostScript file for :hardcopy
set printexpr=PrintFile(v:fname_in)
function! PrintFile(fname)
"    call system("lp " . (&printdevice == '' ? '' : ' -s -d' . &printdevice) . ' ' . a:fname)
    call system("evince " . a:fname)
    call delete(a:fname)
    return v:shell_error
endfunc

" messages and info {{{1

" list of flags to make messages shorter
set shortmess=atI
" show (partial) command keys in the status line
set showcmd
" display the current mode in the status line
set showmode
" show cursor position below each window
set ruler
" pause listings when the screen is full
set more
" start a dialog when a command fails
set confirm

" selecting text {{{1

" editing text {{{1

" maximum number of changes that can be undone
set undolevels=1000
" line length above which to break a line (local to buffer)
set textwidth=78
" specifies what <BS>, CTRL-W, etc. can do in Insert mode
set backspace=indent,eol,start
" list of flags that tell how automatic formatting works (local to buffer)
set formatoptions+=rol2n

" specifies how Insert mode completion works for CTRL-N and CTRL-P
" (local to buffer)
set complete+=k
set complete-=i
" whether to use a popup menu for Insert mode completion
"set completeopt=longest,menu,preview
set completeopt=longest,menu

" the "~" command behaves like an operator
set tildeop
" When inserting a bracket, briefly jump to its match
set showmatch
" use two spaces after '.' when joining a line
set nojoinspaces

" tabs and indenting {{{1

" number of spaces a <Tab> in the text stands for (local to buffer)
set tabstop=8     " should always be 8
" number of spaces used for each step of (auto)indent (local to buffer)
set shiftwidth=4
" a <Tab> in an indent inserts 'shiftwidth' spaces
"set smarttab      " shiftwidth at start of line, tabstop/sts elsewhere
" if non-zero, number of spaces to insert for a <Tab> (local to buffer)
set softtabstop=4 " WARNING: mixes spaces and tabs if >0 and noexpandtab!
" round to 'shiftwidth' for "<<" and ">>"
set shiftround
" expand <Tab> to spaces in Insert mode (local to buffer)
set expandtab     " WARNING: don't unset if ts != sw

" automatically set the indent of a new line (local to buffer)
set autoindent
" do clever autoindenting (local to buffer)
set smartindent

" folding {{{1

" set to display all folds open (local to window)
set nofoldenable
" folds with a level higher than this number will be closed (local to window)
"set foldlevel=100
" width of the column used to indicate folds (local to window)
"set foldcolumn=3

" diff mode {{{1

" options for using diff mode
set diffopt=filler,vertical

" reading and writing files {{{1

" enable using settings from modelines when reading a file (local to buffer)
set modeline
" number of lines to check for modelines
set modelines=5
" list of file formats to look for when editing a file
set fileformats=unix,dos,mac

" keep a backup after overwriting a file
"set backup
" list of directories to put backup files in
"set backupdir= " where to put backup files

" automatically read a file when it was modified outside of Vim
" (global or local to buffer)
set autoread

" keep oldest version of a file; specifies file name extension
"set patchmode=.orig

" the swap file {{{1

" list of directories for the swap file
"set directory=
" number of characters typed to cause a swap file update
set updatecount=100
" time in msec after which the swap file will be updated
set updatetime=2000

" command line editing {{{1

" how many command lines are remembered
set history=100

" specifies how command line completion works
set wildmode=list:longest,full
" list of file name extensions that have a lower priority
set suffixes=.pdf,.bak,~,.info,.log,.bbl,.blg,.brf,.cb,.ind,.ilg,.inx,.nav,.snm
" list of file name extensions added when searching for a file (local to buffer)
set suffixesadd=.rb
" list of patterns to ignore files for file name completion
set wildignore=*.o,CVS,.svn,.git,*.aux,*.swp,*.idx,*.hi,*.dvi,*.lof,*.lol,*.toc,*.out,*.class
" command-line completion shows a list of matches
"set wildmenu

" running make and jumping to errors {{{1

" program used for the ":grep" command (global or local to buffer)
set grepprg=ack-grep

" multi-byte characters {{{1

" character encoding used in Vim: "latin1", "utf-8" "euc-jp", "big5", etc.
set encoding=utf-8
" automatically detected character encodings
set fileencodings=ucs-bom,utf-8,default,latin1

" various {{{1

filetype plugin indent on
syntax enable

" when to use virtual editing: "block", "insert" and/or "all"
set virtualedit=block
" list that specifies what to write in the viminfo file
set viminfo=!,%,'20,<500,:500,s100,h,n~/.cache/vim/viminfo

" Plugin and script options {{{1

" autocomplpop {{{2
let g:AutoComplPop_NotEnableAtStartup = 1
let g:AutoComplPop_MappingDriven = 1
"let g:AutoComplPop_Behavior = 

" CCTree {{{2
let g:CCTreeRecursiveDepth = 2
let g:CCTreeMinVisibleDepth = 2
let g:CCTreeOrientation = "leftabove"

" changelog {{{2
let g:changelog_username = "Jan Larres <jan@majutsushi.net>"

" code_complete {{{2
let s:rs = '<+'
let s:re = '+>'

" detectindent {{{2
let g:detectindent_preferred_expandtab = 1
let g:detectindent_preferred_indent = 4

" devhelp {{{2
let g:devhelpSearch = 1
let g:devhelpAssistant = 0
let g:devhelpSearchKey = '<F7>'
let g:devhelpWordLength = 5

" enhanced-commentify {{{2
" let g:EnhCommentifyRespectIndent = 'Yes'
" let g:EnhCommentifyPretty = 'Yes'
let g:EnhCommentifyTraditionalMode = 'No'
let g:EnhCommentifyFirstLineMode = 'Yes'

" git {{{2
"let g:git_diff_spawn_mode = 1

" haskellmode {{{2
let g:haddock_browser="/usr/bin/gnome-www-browser"
let g:haddock_docdir="/usr/share/doc/ghc6-doc/libraries/"
let g:haddock_indexfiledir="~/.vim/cache/"

"let hs_highlight_delimiters = 1
let hs_highlight_boolean = 1
let hs_highlight_types = 1
let hs_highlight_more_types = 1
let hs_highlight_debug = 1

" mail.tgz {{{2
let g:mail_erase_quoted_sig = 1
let g:mail_alias_source = "MuttQuery"
let g:mail_mutt_query_command = "lbdbq"

" NERD_Tree {{{2
"let NERDTreeCaseSensitiveSort = 1
let NERDTreeChDirMode = 2 " change pwd with nerdtree root change
let NERDTreeIgnore = ['\~$', '\.o$', '\.swp$']
let NERDTreeHijackNetrw = 0

" omnicppcomplete {{{2
let g:OmniCpp_SelectFirstItem = 2 " select first completion item, but don't insert it
"let g:OmniCpp_ShowPrototypeInAbbr = 1

" po {{{2
let g:po_translator = 'Jan Larres <jan@majutsushi.net>'
let g:po_lang_team = ''
"let g:po_path = '.,..'

" rubycomplete {{{2
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 1

" selectbuf {{{2
let g:selBufAlwaysShowDetails = 1
let g:selBufLauncher = "!see"

" taglist {{{2
"let Tlist_File_Fold_Auto_Close = 1
"let Tlist_Display_Prototype = 1
let Tlist_Show_One_File = 1
"let Tlist_Auto_Highlight_Tag = 0
let Tlist_Enable_Fold_Column = 0
let Tlist_Use_Right_Window = 1
let Tlist_Inc_Winwidth = 0 " to prevent problems with project.vim
let Tlist_Sort_Type = "name"

" timestamp {{{2
let g:timestamp_modelines = 20
let g:timestamp_rep = '%Y-%m-%d %H:%M:%S %z %Z'
"let g:timestamp_regexp = '\v\C%(<%(Last %([cC]hanged?|modified)|Modified)\s*:\s+)@<=\a+ \d{2} \a+ \d{4} \d{2}:\d{2}:\d{2}  ?%(\a+)?|TIMESTAMP'
let g:timestamp_regexp = '\v\C%(<Last changed\s*:\s+)@<=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4} \a+|TIMESTAMP'

" TOhtml syntax script {{{2
let html_use_css = 1
let html_number_lines = 0
let use_xhtml = 1
let html_ignore_folding = 1

" Viki {{{2
let g:vikiLowerCharacters = "a-zäöüßáàéèíìóòçñ"
let g:vikiUpperCharacters = "A-ZÄÖÜ"
let g:vikiUseParentSuffix = 1
let g:vikiOpenUrlWith_http = "silent !firefox %{URL}"
let g:vikiOpenFileWith_html  = "silent !firefox %{FILE}"
let g:vikiOpenFileWith_ANY   = "silent !start %{FILE}"
let g:vikiMapQParaKeys = ""
" we want to allow deplate to execute ruby code and external helper 
" application
let g:deplatePrg = "deplate -x -X "
let g:vikiNameSuffix=".viki"
let g:vikiHomePage = "~/projects/viki/Main.viki"

" vim-latexsuite {{{2
" default format for .tex filetype recognition
let g:tex_flavor = "latex"
let g:Tex_DefaultTargetFormat = "pdf"
let g:Tex_IgnoredWarnings = 
            \'Underfull'."\n".
            \'Overfull'."\n".
            \'specifier changed to'."\n".
            \'You have requested'."\n".
            \'Missing number, treated as zero.'."\n".
            \'There were undefined references'."\n".
            \'Citation %.%# undefined'."\n".
            \'LaTeX Font Warning'
"let g:Tex_ViewRule_pdf = 'xpdf -remote TexServer'
let g:Tex_ViewRule_pdf = 'evince'
let g:Tex_MultipleCompileFormats = 'dvi,pdf'

" vimblog {{{2
if !exists('*Wordpress_vim')
    runtime vimblog.vim
endif

" vimplate {{{2
let Vimplate = "~/.vim/tools/vimplate"

" Functions {{{1

" Bclose() {{{2
" delete buffer without closing window
function! Bclose()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" DiffOrig {{{2
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

" GenerateStatusline() {{{2
" some code taken from
" http://cream.cvs.sourceforge.net/cream/cream/cream-statusline.vim?revision=1.38&view=markup
function! GenerateStatusline()
"    let filestate = "%1*%f %2*%{GetState()}%*%w"
    let filestate = "%1*%{GetFileName()} %2*%{GetState()}%*%w"
"    let filestate = "%f%m%r%h%w"
    let fileinfo = "%3*|%{GetFileformat()}:%{GetFileencoding()}:%{GetFiletype()}%{GetSpellLang()}|%*"
    let curdir = "%<%{GetCurDir()}"
    let tabinfo = "%3*|%1*%{GetExpandTab()}%3*:%{&tabstop}:%{&softtabstop}:%{&shiftwidth}|%*"
"    let tabinfo = "[%{GetExpandTab()}:%{GetTabstop()}]"
    let lineinfo = "%(%3*%05(%l%),%03(%c%V%)%*%)\ %1*%p%%"
"    let lineinfo = "%(%3*%l,%c%V%*%)\ %1*%p%%"

    return filestate .
         \ fileinfo .
         \ curdir .
         \ "%=" .
         \ tabinfo .
         \ lineinfo
endfunction

" GetFileName() {{{3
function! GetFileName()
    if &buftype == "help"
        return expand('%:p:t')
    elseif &buftype == "quickfix"
        return "[Quickfix List]"
    elseif bufname('%') == ""
        return "[No Name]"
    else
        return expand('%:p:~:.')
    endif
endfunction

" GetState() {{{3
function! GetState()
    if &buftype == "help"
        return 'H'
    elseif &readonly || &buftype == "nowrite" || &modifiable == 0
        return '-'
    elseif &modified != 0
        return '*'
    else
        return ''
    endif
endfunction

" GetFileformat() {{{3
function! GetFileformat()
    if &fileformat == ""
        return "--"
    else
        return &fileformat
    endif
endfunction

" GetFileencoding() {{{3
function! GetFileencoding()
    if &fileencoding == ""
        if &encoding != ""
            return &encoding
        else
            return "--"
        endif
    else
        return &fileencoding
    endif
endfunction

" GetFiletype() {{{3
function! GetFiletype()
    if &filetype == ""
        return "--"
    else
        return &filetype
    endif
endfunction

" GetSpellLang() {{{3
function! GetSpellLang()
    if &spell == 0
        return ""
    elseif &spelllang == ""
        return ":--"
    else
        return ":" . &spelllang
    endif
endfunction

" GetExpandTab() {{{3
function! GetExpandTab()
    if &expandtab
        return "S"
    else
        return "T"
    endif
endfunction

" GetCurDir() {{{3
function! GetCurDir()
    let curdir = fnamemodify(getcwd(), ":~")
    return curdir
endfunction

" GetTabstop() {{{3
function! GetTabstop()
    " show by Vim option, not Cream global (modelines)
    let str = "" . &tabstop
    " show softtabstop or shiftwidth if not equal tabstop
    if   (&softtabstop && (&softtabstop != &tabstop))
    \ || (&shiftwidth  && (&shiftwidth  != &tabstop))
        if &softtabstop
            let str = str . ":sts" . &softtabstop
        endif
        if &shiftwidth != &tabstop
            let str = str . ":sw" . &shiftwidth
        endif
    endif
    return str
endfunction

" LBDBCompleteFn() {{{2
" from http://dollyfish.net.nz/blog/2008-04-01/mutt-and-vim-custom-autocompletion
fun! LBDBCompleteFn(findstart, base)
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '[^:,]'
          let start -= 1
        endwhile
        while start < col('.') && line[start] =~ '[:, ]'
            let start += 1
        endwhile
        return start
    else
        let res = []
        let query = substitute(a:base, '"', '', 'g')
        let query = substitute(query, '\s*<.*>\s*', '', 'g')
        for m in LbdbQuery(query)
            call add(res, printf('"%s" <%s>', escape(m[0], '"'), m[1]))
        endfor
        return res
    endif
endfun

" LoadProjectConfig() {{{2
function! LoadProjectConfig()
    if filereadable('project_config.vim')
        exe 'sandbox source project_config.vim'
    endif
    if filereadable(expand('%:h') . '/project_config.vim')
        exe 'sandbox source %:h/project_config.vim'
    endif
endfunction

" ManCscopeAndTags() {{{2
function! ManCscopeAndTags()
    execute '!cscope -Rqbc'
    " see ~/.ctags
    execute '!ctags -R'
    if cscope_connection() == 0
        execute 'cs add cscope.out'
    else
        execute 'cs reset'
    endif
    execute 'CCTreeLoadDB'
endfunction

" MyTabLine() {{{2
if exists("+guioptions")
     set go-=e
endif
if exists("+showtabline")
    function! MyTabLine()
        let s = ''
        let t = tabpagenr()
        let i = 1
        while i <= tabpagenr('$')
            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)
            let s .= '%' . i . 'T'
            let s .= (i == t ? '%5*' : '%4*')
            let s .= ' '
            let s .= i . ':'
"            let s .= winnr . '/' . tabpagewinnr(i,'$')
            let s .= tabpagewinnr(i,'$')
            let mod = '%6*'
            let j = 1
            while j <= tabpagewinnr(i,'$')
                if getbufvar(buflist[j - 1], "&modified") != 0
                    let mod .= '+'
                    break
                endif
                let j = j + 1
            endwhile
            let s .= mod
            let s .= ' %*'
            let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let file = bufname(buflist[winnr - 1])
            let file = fnamemodify(file, ':p:t')
            if file == ''
                let file = '[No Name]'
            endif
            let s .= file
"            let s .= file . ' '
            let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
"    set stal=2
endif

" PreviewWord() {{{2
function! PreviewWord(local)
    if &previewwindow			" don't do this in the preview window
        return
    endif

    let l:editwinnum = winnr()

    let w = expand("<cword>")		" get the word under cursor
    if w =~ '\a'			" if the word contains a letter

        " Delete any existing highlight before showing another tag
        silent! wincmd P		" jump to preview window
        if &previewwindow		" if we really get there...
            match none			" delete existing highlight
            silent! exe l:editwinnum . "wincmd w"
        endif

        if a:local == 1
            call PreviewWordLocal(w, l:editwinnum)
        else
            " Try displaying a matching tag for the word under the cursor
            try
                exe "ptag " . w
            catch
                call PreviewWordLocal(w, l:editwinnum)
            endtry
        endif

        silent! wincmd P		" jump to preview window
        if &previewwindow		" if we really get there...
            if has("folding")
                silent! .foldopen	" don't want a closed fold
            endif
            call search("$", "b")	" to end of previous line
            let w = substitute(w, '\\', '\\\\', "")
            call search('\<\V' . w . '\>')	" position cursor on match
            " Add a match highlight to the word at this position
            hi previewWord term=bold ctermbg=green guibg=green
            exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
            normal zz
            redraw!
            silent! exe l:editwinnum . "wincmd w"
        endif
    endif
endfun

function! PreviewWordLocal(w, editwinnum)
    let l:editpath   = expand("%:p")

    let l:eoldline = line(".")
    let l:eoldcol  = col(".")
    call searchdecl(a:w, 0, 1)
    let l:enewline = line(".")
    let l:enewcol  = col(".")
    call cursor(l:eoldline, l:eoldcol)
    exe "pedit " . l:editpath
    silent! wincmd P
    if &previewwindow
        call cursor(l:enewline, l:enewcol)
        silent! exe a:editwinnum . "wincmd w"
    endif
endfun

" RunShellCommand() {{{2
function! s:RunShellCommand(cmdline)
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
    setlocal nowrap
"    call setline(1,a:cmdline)
"    call setline(2,substitute(a:cmdline,'.','=','g'))
    if v:version >= 702
        if stridx(a:cmdline, "git") == 0
            setlocal filetype=git
        endif
    elseif stridx(a:cmdline, "diff") >= 0
        set filetype=diff
    endif
    execute 'silent 0read !'.escape(a:cmdline,'%#')
    setlocal nomodifiable
    1
endfunction

command! -complete=file -nargs=* Git   call s:RunShellCommand('git '.<q-args>)
command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)

" SmartTOHtml() {{{2
"A function that inserts links & anchors on a TOhtml export.
" Notice:
" Syntax used is:
"   *> Link
"   => Anchor
function! SmartTOHtml()
    TOhtml
    try
        %s/&quot;\s\+\*&gt; \(.\+\)</" <a href="#\1" style="color: cyan">\1<\/a></g
        %s/&quot;\(-\|\s\)\+\*&gt; \(.\+\)</" \&nbsp;\&nbsp; <a href="#\2" style="color: cyan;">\2<\/a></g
        %s/&quot;\s\+=&gt; \(.\+\)</" <a name="\1" style="color: #fff">\1<\/a></g
    catch
    endtry
    exe ":write!"
    exe ":bd"
endfunction

" Tab2Space/Space2Tab {{{2
command! -range=% -nargs=0 Tab2Space exec "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', "repeat(' ', ".&ts."), 'g')"
command! -range=% -nargs=0 Space2Tab exec "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" ToggleExpandTab() {{{2
function! ToggleExpandTab()
    if &sts == 4
        setlocal softtabstop=0
        setlocal shiftwidth=8
        setlocal noexpandtab
    else
        setlocal softtabstop=4
        setlocal shiftwidth=4
        setlocal expandtab
    endif
    set expandtab?
endfunction

" ToggleFold() {{{2
" Toggle fold state between closed and opened.
" If there is no fold at current line, just moves forward.
" If it is present, reverse its state.
fun! ToggleFold()
    if foldlevel('.') == 0
        normal! l
    else
        if foldclosed('.') < 0
            . foldclose
        else
            . foldopen
        endif
    endif
    " Clear status line
    echo
endfun

" VisualSearch() {{{2
" From an idea by Michael Naumann
function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    else
        execute "normal /" . l:pattern . "^M"
    endif
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Abbrevs {{{1
source ~/.vim/abbrevs.vim

" Terminal keycodes {{{1

if !has("gui_running")
    if &term == "rxvt-unicode" || &term == "screen-256color-bce"
        set t_ku=OA
        set t_kd=OB
        set t_kr=OC
        set t_kl=OD
        map [23~ <S-F1>
        map [24~ <S-F2>
        map [25~ <S-F3>
        map [26~ <S-F4>
        map [28~ <S-F5>
        map [29~ <S-F6>
        map [31~ <S-F7>
        map [32~ <S-F8>
        map [33~ <S-F9>
        map [34~ <S-F10>
        map [23$ <S-F11>
        map [24$ <S-F12>
"        set <S-F1>=[23~
"        set <S-F2>=[24~
"        set <S-F3>=[25~
"        set <S-F4>=[26~
"        set <S-F5>=[28~
"        set <S-F6>=[29~
"        set <S-F7>=[31~
"        set <S-F8>=[32~
"        set <S-F9>=[33~
"        set <S-F10>=[34~
"        set <S-F11>=[23$
"        set <S-F12>=[24$
    elseif &term == "xterm"
        set <S-F1>=[1;2P
        set <S-F2>=[1;2Q
    endif
endif

" Mappings {{{1

let mapleader=","

let vimrc='~/.vimrc'
let myabbr='~/.vim/abbrevs.vim'
nn  <leader>vs :source <C-R>=vimrc<CR><CR>
nn  <leader>ve :edit   <C-R>=vimrc<CR><CR>
nn  <leader>va :edit   <C-R>=myabbr<CR><CR>

nmap <C-W>e :enew<CR>

" Control-Space for omnicomplete
inoremap <C-Space> <C-X><C-O>

" create undo break points
inoremap <C-U> <C-G>u<C-U>

" make some jumps more intuitive
nnoremap ][ ]]
nnoremap ]] ][

" copy to/from the x cut-buffer
vmap <C-Insert> "+y
vmap <S-Insert> "-d"+P
nmap <S-Insert> "+P
imap <S-Insert> <C-R><C-O>+

noremap <expr> <Up> pumvisible() ? "\<Up>" : "gk"
noremap <expr> <Down> pumvisible() ? "\<Down>" : "gj"

" change tabs fast
nmap <M-1> 1gt
nmap <M-2> 2gt
nmap <M-3> 3gt
nmap <M-4> 4gt
nmap <M-5> 5gt
nmap <M-6> 6gt
nmap <M-7> 7gt
nmap <M-8> 8gt
nmap <M-9> 9gt

inoremap <M-j> <C-O>gj
inoremap <M-k> <C-O>gk
noremap! <M-h> <Left>
noremap! <M-l> <Right>

" create an undo point after each word
" imap <Space> <Space><C-G>u
"inoremap <Tab>   <Tab><C-G>u
imap <CR>    <CR><C-G>u

nmap <silent> <leader>b <Plug>SelectBuf
" needed to keep SelectBuf from complaining about existing maps
imap <silent> <S-F1> <ESC><Plug>SelectBuf

" have \tl ("toggle list") toggle list on/off and report the change:
nnoremap \tl :set invlist list?<CR>
nmap <F2> \tl
nmap <S-F2> :call ToggleExpandTab()<CR>

" have \tf ("toggle format") toggle the automatic insertion of line breaks
" during typing and report the change:
nnoremap \tf :if &fo =~ 't' <Bar> set fo-=t <Bar> else <Bar> set fo+=t <Bar>
   \ endif <Bar> set fo?<CR>
nmap <F3> \tf
imap <F3> <C-O>\tf

" have \tp ("toggle paste") toggle paste on/off and report the change, and
" where possible also have <F4> do this both in normal and insert mode:
nnoremap \tp :set invpaste paste?<CR>
nmap <F4> \tp
imap <F4> <C-O>\tp
set pastetoggle=<F4>

" remove search highlighting
"map <silent> <F5> :silent nohl<cr>
map <silent> <M-/> :silent nohl<cr>

" delete buffer and close window
map <F8>  :bd<C-M>
" delete buffer, but keep window
map <S-F8> :call Bclose()<cr>

nmap <silent> <F9>  :Tlist<CR>
"nmap <silent> <C-F9> :call PreviewWord(0)<CR>
"nmap <silent> <S-F9> :call PreviewWord(1)<CR>
nmap <silent> <leader>pw :call PreviewWord(0)<CR>
nmap <silent> <leader>pl :call PreviewWord(1)<CR>

nmap <silent> <F10> :NERDTreeToggle<CR>
nnoremap <S-F10> :call ManCscopeAndTags()<CR>

imap <expr> <c-e> pumvisible() ? "\<c-e>" : "\<esc>$a"
imap <c-a> <esc>0i

" Switch to current dir
map <silent> <leader>cd :cd %:p:h<cr>

" quickfix
map <leader>cn :cnext<cr>
map <leader>cp :cprevious<cr>
map <leader>co :botright copen<cr>
map <leader>cc :cclose<cr>
map <leader>cl :clist<cr>

" cycle fast through errors ...
map <m-n> :cn<cr>
map <m-p> :cp<cr>

map <silent> <leader>g :silent !gitk<cr>

" highlight long lines
nnoremap <silent> <Leader>hl
      \ :if exists('w:long_line_match') <Bar>
      \   silent! call matchdelete(w:long_line_match) <Bar>
      \   unlet w:long_line_match <Bar>
      \ elseif &textwidth > 0 <Bar>
      \   let w:long_line_match = matchadd('ErrorMsg', '\%>'.&tw.'v.\+', -1) <Bar>
      \ else <Bar>
      \   let w:long_line_match = matchadd('ErrorMsg', '\%>80v.\+', -1) <Bar>
      \ endif<CR>

" crefvim
"map <silent> <Leader>cw <Plug>CRV_CRefVimAsk
map <silent> <Leader>ct <Plug>CRV_CRefVimInvoke

" for pupop-menu completion
" http://www.vim.org/tips/tip.php?tip_id=1386
"inoremap <expr> <m-'> pumvisible() ? "\<c-y>" : "\<c-g>u\<cr>"
"inoremap <expr> <c-n> pumvisible() ? "\<lt>c-n>" : "\<lt>c-n>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"
"inoremap <expr> <m-;> pumvisible() ? "\<lt>c-n>" : "\<lt>c-x>\<lt>c-o>\<lt>c-n>\<lt>c-p>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"
" http://www.vim.org/tips/tip.php?tip_id=1228
inoremap <expr> <Esc>      pumvisible()?"\<C-E>":"\<Esc>"
inoremap <expr> <CR>       pumvisible()?"\<C-Y>":"\<CR>"
inoremap <expr> <Down>     pumvisible()?"\<C-N>":"\<Down>"
inoremap <expr> <Up>       pumvisible()?"\<C-P>":"\<Up>"
inoremap <expr> <PageDown> pumvisible()?"\<PageDown>\<C-P>\<C-N>":"\<PageDown>"
inoremap <expr> <PageUp>   pumvisible()?"\<PageUp>\<C-P>\<C-N>":"\<PageUp>"

" Parenthesis/bracket expanding
vnoremap §§ <esc>`>a"<esc>`<i"<esc>
vnoremap §q <esc>`>a'<esc>`<i'<esc>
vnoremap §1 <esc>`>a)<esc>`<i(<esc>
vnoremap §2 <esc>`>a]<esc>`<i[<esc>
vnoremap §3 <esc>`>a}<esc>`<i{<esc>

" Fast open a buffer by searching for a name
map <c-q> :b 

" Search for the current selection
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

" indent for C programs
nmap <Leader>i :%!indent<CR>

" open main viki
nmap <Leader>vo :VikiHome<CR>

" see functions
noremap <space> :call ToggleFold()<CR>

" have Y behave analogously to D and C rather than to dd and cc (which is
" already done by yy):
noremap Y y$

" insert mode completion
inoremap  
inoremap  
inoremap  
inoremap  

" scroll whole buffer without cursor
map <silent> <C-Down> 1<C-d>:set scroll=0<cr>
map <silent> <C-Up> 1<C-u>:set scroll=0<cr>

map <M-,>     :bprevious!<CR>
map <M-.>     :bnext!<CR>
map <M-Left>  :tabprevious<CR>
map <M-Right> :tabnext<CR>

" Remove quoted signatures
map ## :/^> -- $/,/^$/d

" ;rcm = remove "control-m"s - for those mails sent from DOS:
cmap ;rcm %s/<C-M>//g

" vim:tw=78 expandtab comments=\:\" foldmethod=marker foldenable
