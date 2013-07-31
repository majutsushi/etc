" Adapted from https://github.com/christoomey/vim-tmux-navigator

if exists("g:loaded_tmux_navigator") || &cp
    finish
endif
let g:loaded_tmux_navigator = 1

let s:tmux_is_last_pane = 0
au WinEnter * let s:tmux_is_last_pane = 0

" Like 'wincmd' but also change tmux panes instead of vim windows when needed.
function! s:TmuxWinCmd(direction)
    if $TMUX != ''
        call s:TmuxAwareNavigate(a:direction)
    else
        call s:VimNavigate(a:direction)
    endif
endfunction

function! s:TmuxAwareNavigate(direction)
    let nr = winnr()
    let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
    if !tmux_last_pane
        call s:VimNavigate(a:direction)
    endif
    " Forward the switch panes command to tmux if:
    " a) we're toggling between the last tmux pane;
    " b) we tried switching windows in vim but it didn't have effect.
    if tmux_last_pane || nr == winnr()
        let cmd = 'tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR')
        silent call system(cmd)
        let s:tmux_is_last_pane = 1
    else
        let s:tmux_is_last_pane = 0
    endif
endfunction

function! s:VimNavigate(direction)
    try
        execute 'wincmd ' . a:direction
    catch
        echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
    endtry
endfunction

command! TmuxNavigateLeft call <SID>TmuxWinCmd('h')
command! TmuxNavigateDown call <SID>TmuxWinCmd('j')
command! TmuxNavigateUp call <SID>TmuxWinCmd('k')
command! TmuxNavigateRight call <SID>TmuxWinCmd('l')
command! TmuxNavigatePrevious call <SID>TmuxWinCmd('p')
