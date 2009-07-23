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

autocmd BufEnter * call LoadProjectConfig()

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

" add cscope databases if available
"au FileType c set nocscopeverbose
"au FileType c if filereadable("cscope.out")
"au FileType c     silent! cs add cscope.out
"au FileType c elseif $CSCOPE_DB != ""
"au FileType c     silent! cs add $CSCOPE_DB
"au FileType c endif
"au FileType c set cscopeverbose

" setup skeletons
au BufNewFile *.vim TSkeletonSetup plugin.vim
au BufNewFile ~/work/dev/studium/ppp/**.c silent TSkeletonSetup mpi.c

au BufWritePost,FileWritePost *.c TlistUpdate
"au CursorMoved,CursorMovedI * if bufwinnr(g:TagList_title) != -1
"au CursorMoved,CursorMovedI *   TlistHighlightTag
"au CursorMoved,CursorMovedI * endif

"au BufWritePost,FileWritePost ~/work/dev/ruby/filmdb/* silent !cp <afile> /var/www/filmdb/

au BufWritePost,FileWritePost *.sh silent !chmod u+x %

augroup VCSCommand
    au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr>
augroup END

" temporary LooPo setting
au BufNewFile,BufReadPost ~/apps/loopo/loopo.svn/hsloopo/** setlocal makeprg=make\ compiled-o0

" General {{{1

set confirm
filetype on
filetype plugin on
filetype indent on
"set autochdir
set history=100
"set encoding=iso-8859-15
set encoding=utf-8
"set fileencodings=ucs-bom,utf-8,default,euc-jp,iso-2022-jp,shift-jis,latin1
set fileencodings=ucs-bom,utf-8,default,latin1
set modeline
set modelines=5
"set path+=~/work/dev/ruby/cookbook/app/**
"set path+=~/work/dev/ruby/cookbook/lib/**
set suffixesadd=.rb
"set include="^\s*#\s*include"
"set includeexpr+=substitute(v:fname,'s$','','g')
set define=^\\(\\s*#\\s*define\\\|[a-z]*\\s*const\\s*[a-z]*\\)
set undolevels=1000
set viminfo=!,%,'20,<500,:500,s100,h,n~/.cache/vim/viminfo
set complete+=k
set complete-=i
"set tags+=./tags,tags
"set tags+=~/.vim/systags/systags_base,~/.vim/systags/systags_linux
let mapleader=","
set grepprg=ack-grep
"set winaltkeys=no " use alt-mappings for menu shortcuts?

" Theme/Colors {{{1

set background=dark
if  &term =~ "xterm"
    set t_Co=256
"    let g:inkpot_black_background = 1
"    colorscheme inkpot
    colorscheme desert256
elseif &term =~ "rxvt-unicode" || &term =~ "screen-256color-bce"
"    colorscheme inkpot
    colorscheme desert256
else
"    set t_Co=16
    colorscheme desert
endif
syntax on
hi SignColumn guibg=grey20

" Files/Backups {{{1

"set backup
"set backupdir= " where to put backup files
"set directory= " for temp files
"set makeef= " error file for make
"set patchmode=.orig
set path=.,./**,/usr/include,/usr/include/**,,
set updatecount=100
set updatetime=2000

" UI {{{1

" http://ft.bewatermyfriend.org/comp/vim/vimrc.html
if (&term =~ '^screen')
    set t_ts=k
    set t_fs=\
    set title
    autocmd BufEnter * let &titlestring = "vim(" . expand("%:t") . ")"
endif

if exists('&macatsui')
    set nomacatsui
endif

"set completeopt=longest,menu,preview
set completeopt=longest,menu

set cscopequickfix=s-,c-,d-,i-,t-,e-
set cscopetag
set nocscopeverbose
" add any database in current directory
if filereadable("cscope.out")
    silent! cs add cscope.out
" else add database pointed to by environment
elseif $CSCOPE_DB != ""
    silent! cs add $CSCOPE_DB
endif
set cscopeverbose

"set wildmenu
set wildmode=list:longest,full
set wildignore=*.o,CVS,.svn,.git,*.aux,*.swp,*.idx,*.hi,*.dvi,*.lof,*.lol,*.toc,*.out,*.class
set ruler " position information in status line
"set cmdheight=2
"set number " line numbers
set lazyredraw " don't update screen while running macros (faster)
set hidden
set backspace=indent,eol,start
set whichwrap=<,>,b,s,[,]
set mouse=a
set mousemodel=popup
set ignorecase " for searching
set smartcase
set shortmess=atI
set switchbuf=useopen " or usetab
"set splitbelow " split below instead of above the current buffer
"set report=0
set more
"set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.nav,.snm,.pdf,.lof,.lol,.hi
set suffixes=.pdf,.bak,~,.info,.log,.bbl,.blg,.brf,.cb,.ind,.ilg,.inx,.nav,.snm
set tildeop
set title
set ttyfast
set ttymouse=xterm
set diffopt=filler,vertical
set previewheight=9
set display=lastline,uhex

" Visual Cues {{{1

set showmatch
set hlsearch
set incsearch

if &encoding == "utf-8"
    set list
    set listchars=tab:»-,trail:·,nbsp:~
endif

"set lines=80
"set columns=160
set scrolloff=2
set laststatus=2
"set statusline=%f%m%r%h%w\ %y\ (%<%{CurDir()})\ %=%-10.(%l,%c%V%)\ %L\ %p%%
set statusline=%!GenerateStatusline()
"set ruler
"set rulerformat=%F
set wrap
set linebreak
"set breakat=\ ^I
set showbreak=+\ 
set showcmd
set showmode

" Has to be set in colorscheme files, see desert.vim and inkpot.vim
"hi User1 term=bold,reverse ctermfg=244 ctermbg=235 cterm=bold guibg=#c2bfa5 guifg=black   gui=bold
"hi User2 term=bold,reverse ctermfg=244 ctermbg=235 cterm=bold guibg=#c2bfa5 guifg=#990f0f gui=bold
"hi User3 term=reverse ctermfg=244 ctermbg=235 cterm=none guibg=#c2bfa5 guifg=grey40  gui=none

" Text Formatting/Layout {{{1

set formatoptions=tcqrol
set autoindent
set smartindent
"set cindent
set tabstop=8     " number of spaces a <Tab> counts for, should always be 8
set softtabstop=4 " WARNING: mixes spaces and tabs if >0 and noexpandtab!
set shiftwidth=4  " number of spaces used for auto-indent
"set smarttab      " shiftwidth at start of line, tabstop/sts elsewhere
set expandtab     " convert tabs -> spaces; WARNING: don't unset if ts != sw
set shiftround
"set comments=nb:>
set textwidth=75
"set pastetoggle=<C-P> " see mappings
set fileformats=unix,dos,mac

" Folding {{{1

set nofoldenable
"set foldcolumn=3
"set foldlevel=100
"set foldmethod=syntax

" Printing {{{1

"set printdevice=
set printoptions=number:y,paper:A4,left:5pc,right:5pc,top:5pc,bottom:5pc
set printfont=Monospace\ 8

set printexpr=PrintFile(v:fname_in)
function! PrintFile(fname)
"    call system("lp " . (&printdevice == '' ? '' : ' -s -d' . &printdevice) . ' ' . a:fname)
    call system("evince " . a:fname)
    call delete(a:fname)
    return v:shell_error
endfunc

" Plugin and script options {{{1

" default format for .tex filetype recognition
let g:tex_flavor = "latex"

let treeExplVertical = 1

" vim-latexsuite {{{2
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

" TOhtml syntax script {{{2
let html_use_css = 1
let html_number_lines = 0
let use_xhtml = 1
let html_ignore_folding = 1

" mail.tgz {{{2
let g:mail_erase_quoted_sig = 1
"let g:mail_alias_source = "Abook"
let g:mail_alias_source = "MuttQuery"
let g:mail_mutt_query_command = "mutt-evo-query.rb"

" project {{{2
let g:proj_window_width = 30
let g:proj_window_increment = 50
let g:proj_flags = 'gimsSt'
let g:proj_run1 = ":call ManCscopeAndTags()"

let ri_unfold_nonunique = 'on'
let ri_prompt_complete = 'on'

" po {{{2
let g:po_translator = 'Jan Larres <jan@majutsushi.net>'
let g:po_lang_team = ''
"let g:po_path = '.,..'

" taglist {{{2
"let Tlist_File_Fold_Auto_Close = 1
"let Tlist_Display_Prototype = 1
let Tlist_Show_One_File = 1
"let Tlist_Auto_Highlight_Tag = 0
let Tlist_Enable_Fold_Column = 0
let Tlist_Use_Right_Window = 1
let Tlist_Inc_Winwidth = 0 " to prevent problems with project.vim
let Tlist_Sort_Type = "name"

" omnicppcomplete {{{2
let g:OmniCpp_SelectFirstItem = 2 " select first completion item, but don't insert it
"let g:OmniCpp_ShowPrototypeInAbbr = 1

" Viki {{{2
let g:vikiLowerCharacters = "a-zäöüßáàéèíìóòçñ"
let g:vikiUpperCharacters = "A-ZÄÖÜ"
let g:vikiUseParentSuffix = 1
let g:vikiOpenUrlWith_http = "silent !galeon %{URL}"
let g:vikiOpenFileWith_html  = "silent !galeon %{FILE}"
let g:vikiOpenFileWith_ANY   = "silent !start %{FILE}"
" we want to allow deplate to execute ruby code and external helper 
" application
let g:deplatePrg = "deplate -x -X "
let g:vikiNameSuffix=".viki"
let g:vikiHomePage = "~/projects/viki/Main.viki"

" tSkeleton {{{2
let g:tskelUserName = "Jan Larres"
let g:tskelUserEmail = "jan@majutsushi.net"
let g:tskelUserWWW = "http://majutsushi.net"
let g:tskelLicense = "GPLv2 (see http://www.gnu.org/licenses/gpl.txt)"
let g:tskelMenuPrefix = ""

let g:timestamp_modelines = 10
let g:timestamp_rep = '%a %d %b %Y %T %Z'
let g:timestamp_regexp = '\v\C%(<%(Last %([cC]hanged?|modified)|Modified)\s*:\s+)@<=\a+ \d{2} \a+ \d{4} \d{2}:\d{2}:\d{2}  ?%(\a+)?|TIMESTAMP'

" selectbuf {{{2
let g:selBufAlwaysShowDetails = 1
let g:selBufLauncher = "!see"

" minibufexplorer (obsolete) {{{2
let g:miniBufExplMapWindowNavVim = 0
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:miniBufExplForceSyntaxEnable = 1
let g:Tb_ModSelTarget = 1

" flagit {{{2
let icons_path = "/home/jan/.vim/signs/"
let g:Fi_Flags = { "todo" : [icons_path."emblem-important.png", "! ", 0, ""] }
let g:Fi_OnlyText = 0
let g:Fi_ShowMenu = 1

" vcscommand {{{2
let g:VCSCommandResultBufferNameExtension = ".vcs"

" vtreeexplorer {{{2
let g:treeExplDirSort = 1

" exUtilities (obsolete) {{{2
"nnoremap <silent> <F7> :ExtsToggle<CR>
"nnoremap <silent> <Leader>ts :ExtsSelectToggle<CR>
"nnoremap <silent> <Leader>tt :ExtsStackToggle<CR>
"map <silent> <Leader>] :ExtsGoDirectly<CR>
"map <silent> <Leader>[ :PopTagStack<CR>
"let g:exTS_backto_editbuf = 0
"let g:exTS_close_when_selected = 1

" SuperTab (obsolete) {{{2
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

" code_complete (obsolete) {{{2
let s:rs = '<+'
let s:re = '+>'

" cca {{{2
"let cca_hotkey = "<Tab>"
let cca_hotkey = "<S-Space>"

" detectindent {{{2
let g:detectindent_preferred_expandtab = 1
let g:detectindent_preferred_indent = 4

" haskellmode {{{2
let g:haddock_browser="/usr/bin/gnome-www-browser"
let g:haddock_docdir="/usr/share/doc/ghc6-doc/libraries/"
let g:haddock_indexfiledir="~/.vim/cache/"

"let hs_highlight_delimiters = 1
let hs_highlight_boolean = 1
let hs_highlight_types = 1
let hs_highlight_more_types = 1
let hs_highlight_debug = 1

" git {{{2
"let g:git_diff_spawn_mode = 1

" autocomplpop {{{2
let g:AutoComplPop_NotEnableAtStartup = 1
let g:AutoComplPop_MappingDriven = 1
"let g:AutoComplPop_Behavior = 

" rubycomplete {{{2
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 1

" vimblog {{{2
if !exists('*Wordpress_vim')
    runtime vimblog.vim
endif

" changelog {{{2
let g:changelog_username = "Jan Larres <jan@majutsushi.net>"

" CCTree {{{2
let g:CCTreeRecursiveDepth = 2
let g:CCTreeMinVisibleDepth = 2
let g:CCTreeOrientation = "leftabove"

" devhelp {{{2
let g:devhelpSearch = 1
let g:devhelpAssistant = 1
let g:devhelpSearchKey = '<F7>'
let g:devhelpWordLength = 5

" NERD_Tree {{{2
"let NERDTreeCaseSensitiveSort = 1
let NERDTreeChDirMode = 2 " change pwd with nerdtree root change
let NERDTreeIgnore = ['\~$', '\.o$', '\.swp$']
let NERDTreeHijackNetrw = 0

" Functions {{{1

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

" InsertTabWrapper() {{{2
" http://vim.sourceforge.net/tips/tip.php?tip_id=102
function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction

" ExtractMethod() {{{2
vmap \em :call ExtractMethod()<cr>
function! ExtractMethod() range
    let name = inputdialog("Name of new method:")
    '<
    exe "normal O\<bs>private " . name ."()\<cr>{\<esc>"
    '>
    exe "normal oreturn ;\<cr>}\<esc>k"
    s/return/\/\/ return/ge
    normal j%
    normal kf(
    exe "normal yyPi// = \<esc>wdwA;\<esc>"
    normal ==
    normal j0w
endfunction

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
    let curdir = substitute(getcwd(), '/home/jan', "~", "g")
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
    set tabline=%!MyTabLine()
"    map     <F10>    :tabnext<CR>
"    map!    <F10>    <C-O>:tabnext<CR>
"    map     <S-F10>  :tabprev<CR>
"    map!    <S-F10>  <C-O>:tabprev<CR>
endif

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

" ToggleExpandTab() {{{2
function! ToggleExpandTab()
    if &sts == 4
        set softtabstop=0
        set shiftwidth=8
        set noexpandtab
    else
        set softtabstop=4
        set shiftwidth=4
        set expandtab
    endif
    set expandtab?
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

" LoadProjectConfig() {{{2
function LoadProjectConfig()
    if filereadable(expand('%:h') . '/project_config.vim')
        exe 'source %:h/project_config.vim'
    endif
endfunction

" Tab2Space/Space2Tab {{{2
command! -range=% -nargs=0 Tab2Space exec "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', "repeat(' ', ".&ts."), 'g')"
command! -range=% -nargs=0 Space2Tab exec "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" DiffOrig {{{2
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

" Abbrevs {{{1
source ~/.vim/abbrevs.vim

" Snippets {{{1

" Java {{{2
autocmd FileType java inorea <buffer> cfun <c-r>=IMAP_PutTextWithMovement("public<++> <++>(<++>) {\n<++>;\nreturn <++>;\n}")<cr> 
autocmd FileType java inorea <buffer> cfunpr <c-r>=IMAP_PutTextWithMovement("private<++> <++>(<++>) {\n<++>;\nreturn <++>;\n}")<cr> 
autocmd FileType java inorea <buffer> cfor <c-r>=IMAP_PutTextWithMovement("for(<++>; <++>; <++>) {\n<++>;\n}")<cr> 
autocmd FileType java inorea <buffer> cif <c-r>=IMAP_PutTextWithMovement("if(<++>) {\n<++>;\n}")<cr> 
autocmd FileType java inorea <buffer> cifelse <c-r>=IMAP_PutTextWithMovement("if(<++>) {\n<++>;\n}\nelse {\n<++>;\n}")<cr>
autocmd FileType java inorea <buffer> cclass <c-r>=IMAP_PutTextWithMovement("class <++> <++> {\n<++>\n}")<cr>
autocmd FileType java inorea <buffer> cmain <c-r>=IMAP_PutTextWithMovement("public static void main(String[] argv) {\n<++>\n}")<cr>

" Terminal keycodes {{{1

if !has("gui_running")
    if &term == "rxvt-unicode" || &term == "screen-256color-bce"
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

let vimrc='~/.vimrc'
let myabbr='~/.abbr.vimrc'
nn  <leader>vs :source <C-R>=vimrc<CR><CR>
nn  <leader>ve :edit   <C-R>=vimrc<CR><CR>
nn  <leader>va :edit   <C-R>=myabbr<CR><CR>

" Control-Space for omnicomplete
inoremap <C-Space> <C-X><C-O>

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

inoremap <M-j> <C-O>gj
inoremap <M-k> <C-O>gk
noremap! <M-h> <Left>
noremap! <M-l> <Right>

" create an undo point after each word
imap <Space> <Space><C-G>u
"inoremap <Tab>   <Tab><C-G>u
imap <CR>    <CR><C-G>u

"if !empty(maparg('<F1>', 'n'))
"  nunmap <F1>
"endif
"nmap <unique> <silent> <F1> <Plug>SelectBuf
"if !empty(maparg('<F1>', 'i'))
"  iunmap <F1>
"endif
"imap <unique> <silent> <F1> <ESC><Plug>SelectBuf
nmap <silent> <leader>b <Plug>SelectBuf
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

" have \th ("toggle highlight") toggle highlighting of search matches, and
" report the change:
nnoremap \th :set invhls hls?<CR>

" delete buffer and close window
map <F8>  :bd<C-M>
" delete buffer, but keep window
map <S-F8> :call Bclose()<cr>

nmap <silent> <F9>  :Tlist<CR>
"nmap <silent> <C-F9> :call PreviewWord(0)<CR>
"nmap <silent> <S-F9> :call PreviewWord(1)<CR>
nmap <silent> <leader>pw :call PreviewWord(0)<CR>
nmap <silent> <leader>pl :call PreviewWord(1)<CR>

"nmap <silent> <F10> <Plug>ToggleProject
nmap <silent> <F10> :NERDTreeToggle<CR>

"nnoremap <S-F10> :execute '!cscope -Rqbc; ctags -R --c-kinds=+p --c++-kinds=+p --fields=+S' \| :cs reset<CR>
nnoremap <S-F10> :call ManCscopeAndTags()<CR>

imap <expr> <c-e> pumvisible() ? "\<c-e>" : "\<esc>$a"
"inoremap <expr> <m-'> pumvisible() ? "\<c-y>" : "\<c-g>u\<cr>"
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
"map ,G yaw:.!git-show -f <c-r>" <CR>

" highlight long lines
nnoremap <silent> <Leader>lw
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
vnoremap §1 <esc>`>a)<esc>`<i(<esc>
vnoremap §2 <esc>`>a]<esc>`<i[<esc>
vnoremap §3 <esc>`>a}<esc>`<i{<esc>
vnoremap §§ <esc>`>a"<esc>`<i"<esc>
vnoremap §q <esc>`>a'<esc>`<i'<esc>
vnoremap §w <esc>`>a"<esc>`<i"<esc>

" Fast open a buffer by search for a name
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
"inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>
"inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

" change VCS-mappings from cx -> sx
nmap <Leader>sa <Plug>VCSAdd
nmap <Leader>sn <Plug>VCSAnnotate
nmap <Leader>sc <Plug>VCSCommit
nmap <Leader>sd <Plug>VCSDiff
nmap <Leader>sg <Plug>VCSGotoOriginal
nmap <Leader>sG <Plug>VCSGotoOriginal!
nmap <Leader>sl <Plug>VCSLog
nmap <Leader>sL <Plug>VCSLock
nmap <Leader>sr <Plug>VCSReview
nmap <Leader>ss <Plug>VCSStatus
nmap <Leader>su <Plug>VCSUpdate
nmap <Leader>sU <Plug>VCSUnlock
nmap <Leader>sv <Plug>VCSVimDiff

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
"map <silent> <C-J> 1<C-d>:set scroll=0<cr>
"map <silent> <C-K> 1<C-u>:set scroll=0<cr>

map <M-,>     :bprevious!<CR>
map <M-.>     :bnext!<CR>
map <M-Left>  :tabprevious<CR>
map <M-Right> :tabnext<CR>

"imap <C-H> <Plug>IMAP_JumpForward
"nmap <C-H> <Plug>IMAP_JumpForward
"if exists('g:Imap_StickyPlaceHolders') && g:Imap_StickyPlaceHolders
"    vmap <C-H> <Plug>IMAP_JumpForward
"else
"    vmap <C-H> <Plug>IMAP_DeleteAndJumpForward
"endif

" Ruby
"map <C-R> :!ruby %<CR>
"map <C-E> :!eruby %<CR>
"map <C-I> :!ri <cword><CR>
"map <C-T> :!ruby % <cword><CR>

" Remove quoted signatures
map ## :/^> -- $/,/^$/d

" ;rcm = remove "control-m"s - for those mails sent from DOS:
cmap ;rcm %s/<C-M>//g

" vim:tw=78 expandtab comments=\:\" foldmethod=marker foldenable
