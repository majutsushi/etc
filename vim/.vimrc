" Important stuff at the beginning {{{1
set nocompatible
set encoding=utf-8
let mapleader=","

let g:pathogen_disabled = []
if v:version < 703
    let g:pathogen_disabled += ['gundo']
endif
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
set runtimepath+=$HOME/.vim/xptpersonal

if !isdirectory($HOME . "/.cache/vim") && exists("*mkdir")
    call mkdir($HOME . "/.cache/vim")
endif

" search for exuberant ctags
if executable('exuberant-ctags')
    let g:ctagsbin = 'exuberant-ctags'
elseif executable('exctags')
    let g:ctagsbin = 'exctags'
elseif executable('ctags')
    let g:ctagsbin = 'ctags'
elseif executable('ctags.exe')
    let g:ctagsbin = 'ctags.exe'
elseif executable('tags')
    let g:ctagsbin = 'tags'
endif

" Autocommands {{{1

" remove all autocommands to avoid sourcing them twice
autocmd!

autocmd GUIEnter * call GuiSettings()

"au BufWritePost ~/.vimrc so ~/.vimrc

autocmd InsertLeave * set nocul
autocmd InsertEnter * set cul

" Don't screw up folds when inserting text that might affect them, until
" leaving insert mode. Foldmethod is local to the window. Protect against
" screwing up folding when switching between windows.
autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif

autocmd BufNewFile,BufReadPre * call LoadProjectConfigs()

autocmd BufWritePre,FileWritePre * call AutoMkDir()

" create undo break point
autocmd CursorHoldI * call feedkeys("\<C-G>u", "nt")

"au BufWritePre * let &bex = '-' . strftime("%Y%b%d%X") . '~'

" When switching buffers, preserve window view.
function! IsNotSpecialBuf(buf)
    return ((&buftype != "quickfix") &&
          \ !&previewwindow &&
          \ (bufname(a:buf) !~ "NERD_tree") &&
          \ (bufname(a:buf) !~ "__Tag_List__") &&
          \ (bufname(a:buf) !~ "fugitive*"))
endfunction
if v:version >= 700
    au BufLeave * if(IsNotSpecialBuf("%")) | let b:winview = winsaveview() | endif
    au BufEnter * if(exists('b:winview') && IsNotSpecialBuf("%")) | call winrestview(b:winview) | endif
endif

" filetype-specific settings
au Filetype html,xml,xsl source ~/.vim/bundle/closetag/closetag.vim
au FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
au FileType tex let b:vikiFamily="LaTeX"
au FileType viki compiler deplate
au FileType gtkrc setlocal tabstop=2 shiftwidth=2
au FileType haskell compiler ghc
au FileType mkd setlocal ai formatoptions=tcroqn2 comments=n:>
au FileType ruby setlocal omnifunc=rubycomplete#Complete

augroup cfile
    "au FileType c setlocal path+=/usr/include,/usr/include/sys,/usr/include/linux
    au FileType c,cpp setlocal foldmethod=syntax
    au FileType c,cpp setlocal tags+=~/.vim/tags/systags
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

" FSwitch setup
au BufEnter *.c        let b:fswitchdst  = 'h'
au BufEnter *.c        let b:fswitchlocs = './'
au BufEnter *.cpp,*.cc let b:fswitchdst  = 'h,hpp'
au BufEnter *.cpp,*.cc let b:fswitchlocs = './'
au BufEnter *.h        let b:fswitchdst  = 'cpp,cc,c'
au BufEnter *.h        let b:fswitchlocs = './'

au BufWritePost,FileWritePost *.c,*.cc,*.cpp,*.h TlistUpdate
"au CursorMoved,CursorMovedI * if bufwinnr(g:TagList_title) != -1
"au CursorMoved,CursorMovedI *   TlistHighlightTag
"au CursorMoved,CursorMovedI * endif

au BufWritePost,FileWritePost *.sh silent !chmod u+x %

au BufNewFile,BufReadPost *.mutt/fortunes* setlocal textwidth=76
au BufWritePost           *.mutt/fortunes* silent !strfile <afile> >/dev/null

" Functions {{{1

" AutoMkDir() {{{2
" Automatically create dir to write file to if it doesn't exist
function! AutoMkDir()
    let l:dir = expand("<afile>:p:h")

    if !isdirectory(l:dir)
        call mkdir(l:dir, "p")
    endif
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

" DiffOrig() {{{2
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

" FindAutocmdTouching() {{{2
" Find autocmds that set certain parameters
" From https://groups.google.com/group/vim_use/msg/91d0d2bd87ce59e1
function! FindAutocmdTouching(...)
    " capture the text of existing autocmds
    redir => aucmds
    silent! au
    redir END
    let found = {}
    let evt = 'unknown'
    for line in split(aucmds, '\n')
        " lines starting with non-whitespace are event names
        if line =~ '^\S'
            let evt = line
            continue
        endif
        " add an entry if the line matches any of the passed patterns
        if len(filter(copy(a:000), 'line =~ v:val'))
            let found[evt] = get(found, evt, []) + [line]
        endif
    endfor

    " print a small report of what was found
    if len(found)
        for [k, v] in items(found)
            echo "autocmd" k
            for line in v
                echo line
            endfor
        endfor
    else
        echo "None found"
    endif
endfun

" check for the two variants of 'spellcapcheck'
"call FindAutocmdTouching('spellcapcheck','spc')

" GenerateFoldText() {{{2
" adjusted from http://vim.wikia.com/wiki/Customize_text_for_closed_folds
function! GenerateFoldText()
    let line = getline(v:foldstart)
    if match(line, '^[ \t]*\(\/\*\|\/\/\)[*/\\]*[ \t]*$') == 0
        let initial = substitute(line, '^\([ \t]\)*\(\/\*\|\/\/\)\(.*\)', '\1\2', '')
        let linenum = v:foldstart + 1
        while linenum < v:foldend
            let line = getline(linenum)
            let comment_content = substitute(line, '^\([ \t\/\*]*\)\(.*\)$', '\2', 'g')
            if comment_content != ''
                break
            endif
            let linenum = linenum + 1
        endwhile
        let sub = initial . ' ' . comment_content
    else
"        if &foldmethod == "marker"
"            let sub = v:folddashes . ' ' . line
"        else
            let sub = line
"        endif
        let startbrace = substitute(line, '^.*{[ \t]*$', '{', 'g')
        if startbrace == '{'
            let line = getline(v:foldend)
            let endbrace = substitute(line, '^[ \t]*}\(.*\)$', '}', 'g')
            if endbrace == '}'
                let sub = sub . substitute(line, '^[ \t]*}\(.*\)$', '...}\1', 'g')
            endif
        endif
    endif
    let n = v:foldend - v:foldstart + 1
    let info = " " . n . " lines " . v:folddashes . '|'
    let sub = sub . "                                                                                                                  "
    let num_w = getwinvar(0, '&number') * getwinvar(0, '&numberwidth')
    let fold_w = getwinvar(0, '&foldcolumn')
    let sign_w = empty(quickfixsigns#marks#GetList()) ? 0 : 2
    let len = min([winwidth(0) - num_w - fold_w - sign_w - 1, 100])
    let sub = strpart(sub, 0, len - strlen(info))
    return sub . info
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
    let charinfo = "%3*U+%04B|%*"
    let lineinfo = "%(%3*%05(%l%),%03(%c%V%)%*%)\ %1*%p%%"
"    let lineinfo = "%(%3*%l,%c%V%*%)\ %1*%p%%"

    return filestate .
         \ fileinfo .
         \ curdir .
         \ "%=" .
         \ tabinfo .
         \ charinfo .
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

" GenerateTabLine() {{{2
if exists("+guioptions")
     set go-=e
endif
if exists("+showtabline")
    function! GenerateTabLine()
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

" GenCscopeAndTags() {{{2
function! GenCscopeAndTags()
    " see ~/.ctags
    " add --extra=+q here to avoid double entries in taglist
    if filereadable("cscope.files")
        execute '!cscope -qbc'
        execute '!' . g:ctagsbin . ' --extra=+q -L cscope.files'
    else
        execute '!cscope -Rqbc'
        execute '!' . g:ctagsbin . ' -R --extra=+q'
    endif
    if cscope_connection(2, "cscope.out") == 0
        execute 'cs add cscope.out'
    else
        execute 'cs reset'
    endif
"    execute 'CCTreeLoadDB cscope.out'
endfunction

" GuiSettings() {{{2
function! GuiSettings()
    set guifont=DejaVu\ Sans\ Mono\ 8

    set guioptions+=c " use console dialogs
    set guioptions-=e " don't use gui tabs
    set guioptions-=T " don't show toolbar

    " "no", "yes" or "menu"; how to use the ALT key
"   set winaltkeys=no
endfunction

" InsertGuards() {{{2
function! InsertGuards()
    let guardname = "_" . substitute(toupper(expand("%:t")), "[\\.-]", "_", "g") . "_"
    execute "normal! ggI#ifndef " . guardname
    execute "normal! o#define " . guardname . " "
    execute "normal! Go#endif /* " . guardname . " */"
    normal! kk
endfunction

" LoadProjectConfigs() {{{2
function! LoadProjectConfigs()
    let configs = reverse(findfile('project_config.vim', '.;', -1))
    for config in configs
"        execute 'sandbox source ' . config
        execute 'source ' . config
    endfor
endfunction

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
                exe "ptjump " . w
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
    nmap <buffer> q :close<cr>
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

" SynStack() {{{2
" Show syntax highlighting groups for word under cursor
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nmap <leader>ss :call SynStack()<CR>

" Tab2Space/Space2Tab {{{2
command! -range=% -nargs=0 Tab2Space exec "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', "repeat(' ', ".&ts."), 'g')"
command! -range=% -nargs=0 Space2Tab exec "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" ToggleExpandTab() {{{2
function! ToggleExpandTab()
    if &sts == 4
        setlocal softtabstop=8
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

" Options {{{1

" important {{{2
set cpoptions+=$

" moving around, searching and patterns {{{2

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

" tags {{{2

" when completing tags in Insert mode show more info
set showfulltag
" use cscope for tag commands
set nocscopetag
" give messages when adding a cscope database
set cscopeverbose
" When to open a quickfix window for cscope
set cscopequickfix=s-,c-,d-,i-,t-,e-

" displaying text {{{2

" number of screen lines to show around the cursor
set scrolloff=5

" long lines wrap
set wrap
" wrap long lines at a character in 'breakat' (local to window)
set linebreak
" which characters might cause a line break
"set breakat=\ ^I
" string to put before wrapped screen lines
set showbreak=…

" include "lastline" to show the last line even if it doesn't fit
" include "uhex" to show unprintable characters as a hex number
set display=lastline
" characters to use for the status line, folds and filler lines
set fillchars=
" number of lines used for the command-line
"set cmdheight=2
" don't redraw while executing macros
set lazyredraw

" show <Tab> as ^I and end-of-line as $ (local to window)
set list
" list of strings used for list mode
set listchars=tab:»-,trail:·,nbsp:×,precedes:«,extends:»
"set listchars=tab:»-,trail:␣,nbsp:×,precedes:«,extends:»

" show the line number for each line (local to window)
set number

" syntax, highlighting and spelling {{{2

" "dark" or "light"; the background color brightness
set background=dark
" highlight all matches for the last used search pattern
set hlsearch

" methods used to suggest corrections
set spellsuggest=best,10

let g:tex_comment_nospell = 1

" multiple windows {{{2

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

" multiple tab pages {{{2

if exists("+showtabline")
    " 0, 1 or 2; when to use a tab pages line
    set showtabline=1
    " custom tab pages line
    set tabline=%!GenerateTabLine()
endif

" terminal {{{2

" terminal connection is fast
set ttyfast
" show info in the window title
set title
" string to restore the title to when exiting Vim
let &titleold=fnamemodify(&shell, ":t")

if (&term =~ "xterm" || &term =~ "screen-256color")
    set t_Co=256
endif

" http://ft.bewatermyfriend.org/comp/vim/vimrc.html
if (&term =~ '^screen')
    set t_ts=k
    set t_fs=\
    autocmd BufEnter * let &titlestring = "vim(" . expand("%:t") . ")"
endif

" disable visual bell
set t_vb=

" using the mouse {{{2

" list of flags for using the mouse
set mouse=a
" "extend", "popup" or "popup_setpos"; what the right mouse button is used for
set mousemodel=popup
" "xterm", "xterm2", "dec" or "netterm"; type of mouse
set ttymouse=xterm

" GUI {{{2

if has("gui_running")
    call GuiSettings()
endif

if exists('&macatsui')
    set nomacatsui
endif

" printing {{{2

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

" messages and info {{{2

" list of flags to make messages shorter
set shortmess=aoOtI
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
" use a visual bell instead of beeping
"set visualbell

" selecting text {{{2

" editing text {{{2

" maximum number of changes that can be undone
set undolevels=1000
" line length above which to break a line (local to buffer)
set textwidth=78
" specifies what <BS>, CTRL-W, etc. can do in Insert mode
set backspace=indent,eol,start
" list of flags that tell how automatic formatting works (local to buffer)
set formatoptions+=rl2n

" specifies how Insert mode completion works for CTRL-N and CTRL-P
" (local to buffer)
set complete-=u " scan the unloaded buffers that are in the buffer list
"set complete+=k " scan the files given with the 'dictionary' option
set complete-=i " scan current and included files

" whether to use a popup menu for Insert mode completion
"set completeopt=longest,menu,preview
set completeopt=longest,menu

" list of dictionary files for keyword completion (global or local to buffer)
set dictionary=/usr/share/dict/words

" the "~" command behaves like an operator
set tildeop
" When inserting a bracket, briefly jump to its match
set showmatch
" use two spaces after '.' when joining a line
set nojoinspaces

" tabs and indenting {{{2

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
" more or less deprecated in favor of cindent and indentexpr
"set smartindent

" folding {{{2

" set to display all folds open (local to window)
set nofoldenable
" folds with a level higher than this number will be closed (local to window)
"set foldlevel=100
" width of the column used to indicate folds (local to window)
"set foldcolumn=3
" expression used to display the text of a closed fold
set foldtext=GenerateFoldText()
" specifies for which commands a fold will be opened
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
" maximum fold depth for when 'foldmethod is "indent" or "syntax" (local to window)
set foldnestmax=2

let g:vimsyn_folding = 'afmpPrt'

" diff mode {{{2

" options for using diff mode
set diffopt=filler,vertical

" reading and writing files {{{2

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

" the swap file {{{2

" list of directories for the swap file
"set directory=
" number of characters typed to cause a swap file update
set updatecount=100
" time in msec after which the swap file will be updated
set updatetime=2000

" command line editing {{{2

" how many command lines are remembered
set history=100

" specifies how command line completion works
set wildmode=list:longest,full
" list of file name extensions that have a lower priority
set suffixes=.pdf,.bak,~,.info,.log,.bbl,.blg,.brf,.cb,.ind,.ilg,.inx,.nav,.snm
" list of file name extensions added when searching for a file (local to buffer)
set suffixesadd=.rb
" list of patterns to ignore files for file name completion
set wildignore=tags,*.o,CVS,.svn,.git,*.aux,*.swp,*.idx,*.hi,*.dvi,*.lof,*.lol,*.toc,*.out,*.class
" command-line completion shows a list of matches
"set wildmenu

" running make and jumping to errors {{{2

" program used for the ":grep" command (global or local to buffer)
set grepprg=ack-grep

" language specific {{{2

" Avoid command-line redraw on every entered character by turning off Arabic
" shaping (which is implemented poorly).
if has('arabic')
    set noarabicshape
endif

" multi-byte characters {{{2

" automatically detected character encodings
set fileencodings=ucs-bom,utf-8,default,latin1

" various {{{2

filetype plugin indent on
syntax enable

let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : 'fg' }
" must come after terminal color configuration
colorscheme desert

" when to use virtual editing: "block", "insert" and/or "all"
set virtualedit=all
" list that specifies what to write in the viminfo file
set viminfo=!,'20,<50,h,r/tmp,r/mnt,r/media,s50,n~/.cache/vim/viminfo

" Plugin and script options {{{1

" Blogit {{{2
if !has("python")
    let loaded_blogit = 1
end

" CCTree {{{2
let g:CCTreeRecursiveDepth = 2
let g:CCTreeMinVisibleDepth = 2
let g:CCTreeOrientation = "leftabove"

" changelog {{{2
let g:changelog_username = "Jan Larres <jan@majutsushi.net>"

" CheckAttach {{{2
let g:attach_check_keywords = 'attached,attachment,angehängt,Anhang'

" code_complete {{{2
let g:completekey = "<c-tab>"

" COMMENT {{{2
xmap <unique> <leader>cx <Plug>PComment

" detectindent {{{2
let g:detectindent_preferred_expandtab = 1
let g:detectindent_preferred_indent = 4

" devhelp {{{2
let g:devhelpSearch = 1
let g:devhelpAssistant = 0
let g:devhelpSearchKey = '<F7>'
let g:devhelpWordLength = 5

" EasyGrep {{{2
let g:EasyGrepFileAssociations = globpath(&rtp, 'plugin/EasyGrepFileAssociations', 1)
let g:EasyGrepMode = 2
let g:EasyGrepCommand = 0
let g:EasyGrepRecursive = 1
let g:EasyGrepIgnoreCase = 1
let g:EasyGrepHidden = 0
let g:EasyGrepAllOptionsInExplorer = 1
let g:EasyGrepWindow = 0
let g:EasyGrepReplaceWindowMode = 0
let g:EasyGrepOpenWindowOnMatch = 1
let g:EasyGrepEveryMatch = 0
let g:EasyGrepJumpToMatch = 1
let g:EasyGrepInvertWholeWord = 0
let g:EasyGrepFileAssociationsInExplorer = 0
let g:EasyGrepOptionPrefix = '<leader>vy'
let g:EasyGrepReplaceAllPerFile = 0

" enhanced-commentify {{{2
" let g:EnhCommentifyRespectIndent = 'Yes'
" let g:EnhCommentifyPretty = 'Yes'
let g:EnhCommentifyBindInInsert = 'No'
let g:EnhCommentifyTraditionalMode = 'No'
let g:EnhCommentifyFirstLineMode = 'Yes'


" git {{{2
"let g:git_diff_spawn_mode = 1

" Gundo {{{2
nnoremap <leader>u :GundoToggle<CR>

" haskellmode {{{2
let g:haddock_browser="/usr/bin/gnome-www-browser"
let g:haddock_docdir="/usr/share/doc/ghc6-doc/libraries/"
let g:haddock_indexfiledir="~/.vim/cache/"

"let hs_highlight_delimiters = 1
let hs_highlight_boolean = 1
let hs_highlight_types = 1
let hs_highlight_more_types = 1
let hs_highlight_debug = 1

" LanguageTool {{{2
let g:languagetool_jar = "~/lib/LanguageTool/LanguageTool.jar"
let g:languagetool_disable_rules = "WHITESPACE_RULE,EN_QUOTES"
let g:languagetool_win_height = "15"

" Latex Box {{{2
let g:LatexBox_completion_close_braces = 0
"let g:LatexBox_latexmk_options = "-pvc"
let g:LatexBox_autojump = 1

" NERD_Tree {{{2
"let NERDTreeCaseSensitiveSort = 1
let NERDTreeChDirMode = 2 " change pwd with nerdtree root change
let NERDTreeIgnore = ['\~$', '\.o$', '\.swp$']
let NERDTreeHijackNetrw = 0

nmap <silent> <F10> :NERDTreeToggle<CR>
nmap <silent> <leader>nf :NERDTreeFind<CR>

" omnicppcomplete {{{2
let g:OmniCpp_MayCompleteDot = 1 " autocomplete with .
let g:OmniCpp_MayCompleteArrow = 1 " autocomplete with ->
let g:OmniCpp_MayCompleteScope = 1 " autocomplete with ::
let g:OmniCpp_SelectFirstItem = 2 " select first item (but don't insert)
let g:OmniCpp_NamespaceSearch = 2 " search namespaces in this and included files
let g:OmniCpp_ShowPrototypeInAbbr = 1 " show function prototype (i.e. parameters) in popup window
let g:OmniCpp_LocalSearchDecl = 1 " don't require special style of function opening braces

" po {{{2
let g:po_translator = 'Jan Larres <jan@majutsushi.net>'
let g:po_lang_team = ''
"let g:po_path = '.,..'

" ProtoDef {{{2
let g:protodefprotogetter = globpath(&rtp, 'pullproto.pl', 1)
let g:protodefctagsexe = g:ctagsbin

" Quickfixsigns {{{2
let g:quickfixsigns_classes = ['qfl', 'loc', 'marks', 'vcsdiff']
let g:quickfixsigns_blacklist_buffer = '\v(^__.*__$)|(^NERD_tree.*)|(^$)'
" exclude 'p' and 'l' because of xptemplate
let g:quickfixsigns#marks#marks = split('abcdefghijkmnoqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>''^.', '\zs')

" r-plugin {{{2
if executable('urxvt')
    let vimrplugin_term_cmd = "urxvt -title R -e"
else
    let vimrplugin_term = "uxterm"
endif
let vimrplugin_conqueplugin = 0
let vimrplugin_conquevsplit = 1

" rubycomplete {{{2
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 1

" selectbuf {{{2
let g:selBufAlwaysShowDetails = 1
let g:selBufLauncher = "!see"

" Tagbar {{{2
let g:tagbar_type_tex = {
    \ 'ctagstype' : 'latex',
    \ 'kinds'     : [
        \ 's:sections',
        \ 'g:graphics',
        \ 'l:labels',
        \ 'r:refs',
        \ 'p:pagerefs'
    \ ]
\ }
let g:tagbar_type_idl = {
    \ 'ctagstype' : 'xpidl',
    \ 'kinds'     : [
        \ 'p:prototypes',
        \ 'i:interfaces',
        \ 'a:attributes',
        \ 't:types',
        \ 'o:operations'
    \ ]
\ }

nmap <silent> <F9> :TagbarToggle<CR>

" taglist {{{2
"let Tlist_File_Fold_Auto_Close = 1
"let Tlist_Display_Prototype = 1
let Tlist_Show_One_File = 1
"let Tlist_Auto_Highlight_Tag = 0
let Tlist_Enable_Fold_Column = 0
let Tlist_Use_Right_Window = 1
let Tlist_Inc_Winwidth = 0 " to prevent problems with project.vim
let Tlist_Sort_Type = "name"
let tlist_c_settings = 'c;d:macros;p:prototypes;v:variables;t:typedefs;m:members;g:enums;s:structs;u:unions;f:functions'
let tlist_cpp_settings = 'c++;d:macros;n:namespace;p:prototypes;v:variables;t:typedefs;c:class;m:members;g:enums;s:structs;u:unions;f:functions'
"let g:tlist_tex_settings = 'tex;c:chapters;s:sections;u:subsections;b:subsubsections;p:parts;P:paragraphs;G:subparagraphs;i:includes'
let tlist_tex_settings = 'latex;s:sections;g:graphics;l:labels;r:refs;p:pagerefs'
let tlist_idl_settings = 'xpidl;p:prototypes;i:interfaces;a:attributes;t:types;o:operations'

"nmap <silent> <F9> :Tlist<CR>

" timestamp {{{2
let loaded_timestamp = 1
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

" open main viki
nmap <Leader>vh :VikiHome<CR>

" vimfootnotes {{{2
imap Ǣf         <Plug>AddVimFootnote
imap Ǣr         <Plug>ReturnFromFootnote
nmap <leader>fa <Plug>AddVimFootnote
nmap <leader>fr <Plug>ReturnFromFootnote

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

" vimplate {{{2
let Vimplate = globpath(&rtp, 'vimplate', 1)

" voom {{{2
let g:voom_tab_key = '<C-Tab>'
let g:voom_verify_oop = 1
let g:voom_user_command = "runtime! voom_addons/*.vim"

" xptemplate {{{2
let g:xptemplate_key = '<Tab>'
let g:xptemplate_always_show_pum = 1
"let g:xptemplate_brace_complete = '([{'
let g:xptemplate_brace_complete = ''
let g:xptemplate_minimal_prefix = 1
let g:xptemplate_pum_tab_nav = 1
let g:xptemplate_strict = 0
let g:xptemplate_highlight='following,next'
let g:xptemplate_vars = '$author=Jan Larres&$email=jan@majutsushi.net'

" yankring {{{2
let g:yankring_history_dir = '$HOME/.cache/vim'
nnoremap <silent> <leader>y :YRShow<CR>

" Abbrevs {{{1
func! Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunc

iab _me Jan Larres
iab _mail jan@majutsushi.net
iab _www http://majutsushi.net

" Correcting those typos.
iab alos also
iab aslo also
iab charcter character
iab charcters characters
iab exmaple example
iab shoudl should
iab seperate separate
iab teh the

iab _ae ä
iab _ue ü
iab _oe ö
iab _ss ß

iab _mfg  Mit freundlichen Grüßen
iab _mfgl Mit freundlichen Grüßen,Jan Larres<C-R>=Eatchar('\s')<CR>
iab _vg Viele Grüße

iab _time <C-R>=strftime("%H:%M")<CR>
" Example: 14:28

iab _date <C-R>=strftime("%a %d %b %Y %T %Z")<CR>
" Example: Di 06 Jun 2006 21:27:59 CEST

if filereadable('~/.vim/abbrevs.vim')
    source ~/.vim/abbrevs.vim
endif

" Terminal stuff {{{1

if !has("gui_running")
    set t_ku=OA
    set t_kd=OB
    set t_kr=OC
    set t_kl=OD
    " rxvt-unicode
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
    " xterm
    map [1;2P  <S-F1>
    map [1;2Q  <S-F2>
    map [1;2R  <S-F3>
    map [1;2S  <S-F4>
    map [15;2~ <S-F5>
    map [17;2~ <S-F6>
    map [18;2~ <S-F7>
    map [19;2~ <S-F8>
    map [20;2~ <S-F9>
    map [21;2~ <S-F10>
    map [23;2~ <S-F11>
    map [24;2~ <S-F12>
    " gnome-terminal
    map O1;2P  <S-F2>
    map O1;2Q  <S-F2>
    map O1;2R  <S-F3>
    map O1;2S  <S-F4>
    map [15;2~ <S-F5>
    map [17;2~ <S-F6>
    map [18;2~ <S-F7>
    map [19;2~ <S-F8>
    map [20;2~ <S-F9>
    map [21;2~ <S-F10>
    map [23;2~ <S-F11>
    map [24;2~ <S-F12>
endif

" Change color of cursor in terminal:
" - yellow in normal mode.
" - red in insert mode.
" Tip found there:
"   http://forums.macosxhints.com/archive/index.php/t-49708.html
" It works at least with: xterm gnome-terminal terminator
" xfce4-terminal rxvt eterm
" But does nothing with: konsole, screen
if version >= 700
  if &term =~ "xterm\\|rxvt"
    let &t_SI = "\033]12;red\007"
    let &t_EI = "\033]12;yellow\007"
    au! VimLeave * :sil !echo -ne "\033]12;red\007"
  endif
endif

" Mappings {{{1

" Buffers/Files {{{2

nmap <silent> <leader>b <Plug>SelectBuf
" needed to keep SelectBuf from complaining about existing maps
imap <silent> <S-F1> <ESC><Plug>SelectBuf

" Fast open a buffer by searching for a name
nnoremap <c-q> :b 

nnoremap <M-,>     :bprevious!<CR>
nnoremap <M-.>     :bnext!<CR>
nnoremap <M-Left>  :tabprevious<CR>
nnoremap <M-Right> :tabnext<CR>

" delete buffer and close window
nnoremap   <F8> :bd<cr>
" delete buffer, but keep window
nnoremap <S-F8> :call Bclose()<cr>

" change tabs fast
nnoremap <M-1> 1gt
nnoremap <M-2> 2gt
nnoremap <M-3> 3gt
nnoremap <M-4> 4gt
nnoremap <M-5> 5gt
nnoremap <M-6> 6gt
nnoremap <M-7> 7gt
nnoremap <M-8> 8gt
nnoremap <M-9> 9gt

nnoremap <C-W>e :enew<CR>

" FSwitch mappings
nnoremap <silent> <Leader>of :FSHere<cr>
nnoremap <silent> <Leader>ol :FSRight<cr>
nnoremap <silent> <Leader>oL :FSSplitRight<cr>
nnoremap <silent> <Leader>oh :FSLeft<cr>
nnoremap <silent> <Leader>oH :FSSplitLeft<cr>
nnoremap <silent> <Leader>ok :FSAbove<cr>
nnoremap <silent> <Leader>oK :FSSplitAbove<cr>
nnoremap <silent> <Leader>oj :FSBelow<cr>
nnoremap <silent> <Leader>oJ :FSSplitBelow<cr>

let vimrc='~/.vimrc'
let myabbr='~/.vim/abbrevs.vim'
nnoremap <leader>vs :source <C-R>=vimrc<CR><CR>
nnoremap <leader>ve :edit   <C-R>=vimrc<CR><CR>
nnoremap <leader>vb :edit   <C-R>=myabbr<CR><CR>

" Text manipulation {{{2

" Control-Space for omnicomplete
imap <C-Space> <C-X><C-O>

" for pupop-menu completion
" http://vim.wikia.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
inoremap <expr> <C-n>      pumvisible() ? '<C-n>' : '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
" http://vim.wikia.com/wiki/Improve_completion_popup_menu
inoremap <expr> <Esc>      pumvisible() ? "\<C-E>" : "\<Esc>"
inoremap <expr> <CR>       pumvisible() ? "\<C-Y>" : "\<CR>"
"inoremap <expr> <Down>     pumvisible() ? "\<C-N>" : "\<Down>"
"inoremap <expr> <Up>       pumvisible() ? "\<C-P>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-P>\<C-N>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-P>\<C-N>"   : "\<PageUp>"

" insert mode completion
inoremap  
inoremap  
"inoremap  
"inoremap  

" create undo break points
inoremap <C-U> <C-G>u<C-U>

" create an undo point after each word
" imap <Space> <Space><C-G>u
"inoremap <Tab>   <Tab><C-G>u
"inoremap <CR>    <CR><C-G>u

" Swap two words
nnoremap <silent> gw :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'

" have Y behave analogously to D and C rather than to dd and cc (which is
" already done by yy):
nnoremap Y y$

inoremap <C-D> <Del>

" toggle paste
nnoremap <F3> :set invpaste paste?<CR>
inoremap <F3> <C-O>:set invpaste paste?<CR>
set pastetoggle=<F3>

nnoremap <S-F2> :call ToggleExpandTab()<CR>

" copy to/from the x cut-buffer
nnoremap <S-Insert> "+gP
xnoremap <S-Insert> "-d"+P
inoremap <S-Insert> <C-R>+
cnoremap <S-Insert> <C-R>+
inoremap <C-Insert> <C-O>"+y
xnoremap <C-Insert> "+y
xnoremap <S-Del>    "+d
inoremap <C-Del>    <C-O>daw

nnoremap <silent> <leader>ga :GNOMEAlignArguments<CR>

" Parenthesis/bracket expanding
xnoremap §§ <esc>`>a"<esc>`<i"<esc>
xnoremap §q <esc>`>a'<esc>`<i'<esc>
xnoremap §1 <esc>`>a)<esc>`<i(<esc>
xnoremap §2 <esc>`>a]<esc>`<i[<esc>
xnoremap §3 <esc>`>a}<esc>`<i{<esc>

" remove trailing whitespace
nnoremap <leader>tr :%s/\s\+$//<CR>
xnoremap <leader>tr  :s/\s\+$//<CR>

" indent for C/C++ programs
nnoremap <leader>i :%!astyle<CR>

"align map for assignments in R scripts
xnoremap <leader>ar :Align <-<CR>

" re-select selection after changing indent
xnoremap > >gv
xnoremap < <gv

" Ctrl-K comma colon (in Insert mode): UTF-8 single-codepoint ellipsis "..."
" disregard error if (for instance) not in UTF-8
if has("digraphs")
    silent! dig ,:  8230 " HORIZONTAL ELLIPSIS
    silent! dig qi 64259 " LATIN SMALL LIGATURE FFI
    silent! dig ql 64260 " LATIN SMALL LIGATURE FFL
endif

" Moving around {{{2

" make some jumps more intuitive
nnoremap ][ ]]
nnoremap ]] ][

" move into wrapped lines
nnoremap j gj
nnoremap k gk
"nnoremap $ g$   " conflicts with virtualedit
nnoremap 0 g0
nnoremap ^ g^

" emacs-like c-a/c-e movement
inoremap        <c-a> <esc>0i
inoremap <expr> <c-e> pumvisible() ? "\<c-e>" : "\<esc>$a"

" quickfix
nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>
nnoremap <leader>co :botright copen<cr>
nnoremap <leader>cc :cclose<cr>
nnoremap <leader>cl :clist<cr>

" search for visually selected text
xnoremap <silent> * :<C-U>
              \let old_reg=getreg('"')<bar>
              \let old_regmode=getregtype('"')<cr>
              \gvy/<C-R><C-R>=substitute(
              \escape(@", '\\/.*$^~[]'), '\n', '\\n', 'g')<cr><cr>
              \:call setreg('"', old_reg, old_regmode)<cr>
xnoremap <silent> # :<C-U>
              \let old_reg=getreg('"')<bar>
              \let old_regmode=getregtype('"')<cr>
              \gvy?<C-R><C-R>=substitute(
              \escape(@", '\\/.*$^~[]'), '\n', '\\n', 'g')<cr><cr>
              \:call setreg('"', old_reg, old_regmode)<cr>
xnoremap <silent> g* :<C-U>
              \let old_reg=getreg('"')<bar>
              \let old_regmode=getregtype('"')<cr>
              \gvy/<C-R><C-R>=substitute(
              \escape(@", '\\/.*$^~[]'), '\_s\+', '\\_s\\+', 'g')<cr><cr>
              \:call setreg('"', old_reg, old_regmode)<cr>
xnoremap <silent> g# :<C-U>
              \let old_reg=getreg('"')<bar>
              \let old_regmode=getregtype('"')<cr>
              \gvy?<C-R><C-R>=substitute(
              \escape(@", '\\/.*$^~[]'), '\_s\+', '\\_s\\+', 'g')<cr><cr>
              \:call setreg('"', old_reg, old_regmode)<cr>

" Display {{{2

" toggle folds
nnoremap <space> :call ToggleFold()<CR>

" toggle showing 'listchars'
nnoremap <F2> :set invlist list?<CR>
imap <F2> <C-O><F2>
xmap <F2> <Esc><F2>gv

nnoremap <silent> zi
    \ :if &foldenable <Bar>
    \     setlocal nofoldenable <Bar>
    \     setlocal foldcolumn=0 <Bar>
    \ else <Bar>
    \     setlocal foldenable <Bar>
    \     setlocal foldcolumn=3 <Bar>
    \ endif<CR>

" remove search highlighting
nnoremap <silent> <C-L> :silent nohl<CR><C-L>

" toggle text wrapping
nnoremap <silent> <leader>w :set invwrap wrap?<CR>

" preview tag definitions
nnoremap <silent> <leader>pw :call PreviewWord(0)<CR>
nnoremap <silent> <leader>pl :call PreviewWord(1)<CR>

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

" change font size with c-up/down
nnoremap <silent> <C-Up> * :let &guifont = substitute(&guifont, ' \zs\d\+', '\=eval(submatch(0)+1)', '')<CR>
nnoremap <silent> <C-Down> * :let &guifont = substitute(&guifont, ' \zs\d\+', '\=eval(submatch(0)-1)', '')<CR>

" Command line {{{2

" emacs-like keys in command line
cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <C-D> <Del>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-N> <Down>
cnoremap <C-P> <Up>
"cnoremap <Esc><C-B>     <S-Left>
"cnoremap <Esc><C-F>     <S-Right>

" ;rcm = remove "control-m"s - for those mails sent from DOS:
cnoremap ;rcm %s/<C-M>//g

" expand %% to current directory
cabbrev <expr> %% expand('%:~:h')

" Misc {{{2

" for quick macro playback
nnoremap Q @q

" run current file as a script
nnoremap <leader>e :execute "Shell " . expand("%:p")<CR>

" Switch to current dir
nnoremap <silent> <leader>cd :cd %:p:h<cr>

nnoremap <S-F10> :call GenCscopeAndTags()<CR>

nnoremap <silent> <leader>gk :silent !gitk<cr>

"inoremap  <Esc><Right>

" Modeline {{{1
" vim:tw=78 expandtab comments=\:\" foldmethod=marker foldenable foldcolumn=3
