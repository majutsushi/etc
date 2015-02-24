" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

scriptencoding utf-8

" terminal connection is fast
set ttyfast
" show info in the window title
set title
" string to restore the title to when exiting Vim
let &titleold = fnamemodify(&shell, ":t")
" disable visual bell
set t_vb=


" s:get_new_special_key() {{{
let s:mapc = 0
function! s:get_new_special_key() abort
    if s:mapc == 50
        return ''
    else
        let rv = (s:mapc < 25 ? '' : 'S-') . 'F' . (13 + s:mapc % 25)
        let s:mapc += 1
        return rv
    endif
endfunction "}}}

" s:MapMetaChars() {{{
" This breaks macros that contain an <Esc>: https://github.com/tpope/vim-rsi/issues/13
function! s:MapMetaChars() abort
    let metachars  = '0123456789'
    let metachars .= 'abcdefghijklmnopqrstuvwxyz'
    let metachars .= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    let metachars .= '+-='

    for char in split(metachars, '\zs')
        execute "set <M-" . char . ">=\e" . char
    endfor
endfunction "}}}

" s:MapExtraKeys() {{{
function! s:MapExtraKeys() abort
    " Some key combinations aren't recognized keycodes, therefore we have to
    " do this: http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim
    let extramaps = {
        \ 'S-CR'    : 'Q13;2~',
        \ 'C-CR'    : 'Q13;5~',
        \ 'C-S-CR'  : 'Q13;6~',
        \ 'C-Space' : 'Q32;5~',
        \ 'M->'     : '>',
        \ 'M-<'     : '<'
    \ }
    if &term =~ '^xterm\|screen'
        let extramaps['C-Insert'] = '[2;5~'
    elseif &term =~ '^rxvt-unicode'
        let extramaps['C-Insert'] = '[2^'
    endif

    for [key, val] in items(extramaps)
        let vkey = s:get_new_special_key()
        if vkey == ''
            echohl WarningMsg
            echomsg "Unable to map " . key . ": out of spare keycodes"
            echohl None
            break
        endif
        execute "set  <" . vkey . ">=\e" . val
        execute "map  <" . vkey . "> <" . key . ">"
        execute "map! <" . vkey . "> <" . key . ">"
    endfor
endfunction "}}}

if &term =~ '^rxvt-unicode\|xterm\|screen'
    " see ~/.Xresources and ':h xterm-modifier-keys'
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"

    execute "set <PageUp>=\e[5;*~"
    execute "set <PageDown>=\e[6;*~"

    if &term =~ '^rxvt-unicode\|screen'
        execute "set <xF1>=\e[1;*P"
        execute "set <xF2>=\e[1;*Q"
        execute "set <xF3>=\e[1;*R"
        execute "set <xF4>=\e[1;*S"
    elseif $COLORTERM == 'gnome-terminal'
        execute "set <F1>=\eO1;*P"
        execute "set <F2>=\eO1;*Q"
        execute "set <F3>=\eO1;*R"
        execute "set <F4>=\eO1;*S"
    else " xterm; for some reason t_kf1 etc. get assigned to <xF1> etc.
        execute "set <F1>=\e[1;*P"
        execute "set <F2>=\e[1;*Q"
        execute "set <F3>=\e[1;*R"
        execute "set <F4>=\e[1;*S"
    endif

    execute "set <F5>=\e[15;*~"
    execute "set <F6>=\e[17;*~"
    execute "set <F7>=\e[18;*~"
    execute "set <F8>=\e[19;*~"
    execute "set <F9>=\e[20;*~"
    execute "set <F10>=\e[21;*~"
    execute "set <F11>=\e[23;*~"
    execute "set <F12>=\e[24;*~"

    call s:MapMetaChars()

    call s:MapExtraKeys()
endif


if &term =~ '^rxvt-unicode' || $ORIGTERM =~ '^rxvt-unicode'
    set termbidi
endif


" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux'
    set t_Co=16
endif


" Show current file in xterm title
" idea from http://ft.bewatermyfriend.org/comp/vim/vimrc.html
function! s:get_screen_title() abort
    let title = 'vim'
    let file  = expand('%:t')
    if file != ''
        if len(file) > 15
            let file = file[:13] . '…'
        endif
        let title .= '(' . file . ')'
    endif
    if !empty($SSH_CLIENT)
        let title .= '@' . substitute(system('hostname'), '\..*', '', '')
    endif
    return title
endfunction

if &term =~ '^xterm\|rxvt\|screen'
    let &t_ts = "\<Esc>]0;"
    let &t_fs = "\<Esc>\\"
    autocmd vimrc BufEnter * let &titlestring = s:get_screen_title()
endif


" Change cursor colour or shape in insert mode
" Some ideas from https://github.com/jszakmeister/vim-togglecursor
" and https://github.com/sjl/vitality.vim
" tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
" http://sourceforge.net/mailarchive/forum.php?thread_name=AANLkTinkbdoZ8eNR1X2UobLTeww1jFrvfJxTMfKSq-L%2B%40mail.gmail.com&forum_name=tmux-users
let s:xterm_normal = "\e[2 q"
let s:xterm_insert = "\e[6 q"
let s:urxvt_normal = s:xterm_normal
let s:urxvt_insert = s:xterm_insert
let s:iterm_normal = "\e]50;CursorShape=0\x7"
let s:iterm_insert = "\e]50;CursorShape=1\x7"

function! s:tmux_escape(code) abort
    if exists('$TMUX')
        let code = substitute(a:code, "\e", "\e\e", 'g')
        return "\ePtmux;" . code . "\e\\"
    else
        return a:code
    endif
endfunction

function! s:get_cursor_escape(mode) abort
    if exists('$ITERM_PROFILE')
        let terminal = 'iterm'
    elseif $XTERM_VERSION != ''
        let terminal = 'xterm'
    elseif $ORIGTERM =~ '^rxvt-unicode'
        let terminal = 'urxvt'
    else
        return ''
    endif

    let code = s:tmux_escape(s:{terminal}_{a:mode})

    return code
endfunction

function! s:setup_terminfo() abort
    let enable_focus_reporting  = "\e[?1004h"
    let disable_focus_reporting = "\e[?1004l"

    " Support the focus-osc urxvt extension
    let enable_focus_reporting  .= s:tmux_escape("\e]777;focus;on\e\\")
    let disable_focus_reporting .= s:tmux_escape("\e]777;focus;off\e\\")

    let alt_screen    = "\e[?1049h"
    let normal_screen = "\e[?1049l"

    let cursor_insert = s:get_cursor_escape('insert')
    let cursor_normal = s:get_cursor_escape('normal')

    " Order seems to be important here.
    let &t_ti = cursor_normal . enable_focus_reporting  . alt_screen
    let &t_te = cursor_normal . disable_focus_reporting . normal_screen

    let &t_SI = s:get_cursor_escape('insert')
    let &t_EI = s:get_cursor_escape('normal')

    let map_focus_out = s:get_new_special_key()
    let map_focus_in  = s:get_new_special_key()

    execute "set <" . map_focus_out . ">=\e[O"
    execute "set <" . map_focus_in  . ">=\e[I"

    execute "nnoremap <silent> <" . map_focus_out . "> :silent doautocmd FocusLost %<cr>"
    execute "nnoremap <silent> <" . map_focus_in  . "> :silent doautocmd FocusGained %<cr>"

    execute "onoremap <silent> <" . map_focus_out . "> <esc>:silent doautocmd FocusLost %<cr>"
    execute "onoremap <silent> <" . map_focus_in  . "> <esc>:silent doautocmd FocusGained %<cr>"

    execute "vnoremap <silent> <" . map_focus_out . "> <esc>:silent doautocmd FocusLost %<cr>gv"
    execute "vnoremap <silent> <" . map_focus_in  . "> <esc>:silent doautocmd FocusGained %<cr>gv"

    execute "inoremap <silent> <" . map_focus_out . "> <c-o>:silent doautocmd FocusLost %<cr>"
    execute "inoremap <silent> <" . map_focus_in  . "> <c-o>:silent doautocmd FocusGained %<cr>"

    execute "cnoremap <silent> <" . map_focus_out . "> <c-\\>e<SID>do_cmd_focuslost()<cr>"
    execute "cnoremap <silent> <" . map_focus_in  . "> <c-\\>e<SID>do_cmd_focusgained()<cr>"
endfunction

function! s:do_cmd_focuslost()
    let cmd = getcmdline()
    let pos = getcmdpos()

    silent doautocmd FocusLost %

    call setcmdpos(pos)
    return cmd
endfunction

function! s:do_cmd_focusgained()
    let cmd = getcmdline()
    let pos = getcmdpos()

    silent doautocmd FocusGained %

    call setcmdpos(pos)
    return cmd
endfunction

augroup TermFocus
    autocmd!
    " execute "autocmd FocusLost * normal \<C-L>"
augroup END

call s:setup_terminfo()
