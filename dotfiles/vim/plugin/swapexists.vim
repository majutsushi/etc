" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11
"
" Based on:
" https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/autoswap_mac_linux.vim
" by Damian Conway,
" https://github.com/hoelzro/useful-scripts/blob/master/find-existing-vim-session.pl
" by Rob Hoelz, and
" https://github.com/chrisbra/Recover.vim by Christian Brabandt.

if &compatible || exists('g:loaded_swapexists')
    finish
endif
let g:loaded_swapexists = 1

" Disable default Nvim swapfile handler
if exists('#nvim_swapfile')
    autocmd! nvim_swapfile
endif

augroup handleswap
    autocmd!
    autocmd SwapExists * let v:swapchoice = s:handle_swapfile(expand('<afile>:p'))
augroup END

function! s:handle_swapfile(filename)
    if has('win32') || has('win64')
        " Windows is "for future research"
        return ''
    endif

    let swapinfo = s:get_swapinfo(a:filename)
    if empty(swapinfo)
        return ''
    endif

    if (swapinfo.running)
        call s:delayed_msg("Switched to existing session")
        call s:goto_session(swapinfo.pid)
        return 'q'
    elseif swapinfo.modified
        call s:delayed_msg("Diffing modified swapfile")
        call s:setup_diff(v:swapname)
        return 'e'
    else
        call s:delayed_msg("Deleted old swapfile")
        return 'd'
    endif
endfunction

function! s:delayed_msg(msg)
    augroup handleswap_msg
        autocmd!
        autocmd BufWinEnter * echohl WarningMsg
        execute 'autocmd BufWinEnter * echomsg "' . a:msg . '"'
        autocmd BufWinEnter * echohl NONE

        autocmd BufWinEnter * autocmd! handleswap_msg
    augroup END
endfunction

function! s:get_swapinfo(filename) abort
    let output = system("vim -X -r")

    let infodict = {}
    let curfname = ""

    for line in split(output, '\n')
        let line = substitute(line, '^\s*\(.\{-}\)[ \r]*$', '\1', '')

        if line =~# '^file name:'
            let curfname = fnamemodify(split(line, ': ')[1], ':p')
            let infodict[curfname] = {}
        elseif line =~# '^modified:'
            let infodict[curfname].modified = split(line, ': ')[1] ==# 'YES'
        elseif line =~# '^process ID:'
            let format = '^process ID:\s\+\(\d\+\)\(\s\+(still running)\)\?$'
            let infodict[curfname].pid = substitute(line, format, '\1', '')
            let infodict[curfname].running = substitute(line, format, '\2', '') =~# 'still running'
        endif
    endfor

    return get(infodict, a:filename, {})
endfunction

function! s:get_env(pid) abort
    let envlist = split(join(readfile("/proc/" . a:pid . "/environ", "b"), ''), '[\x0]')

    let env = {}
    for entry in envlist
        let equals = stridx(entry, '=')
        let key = strpart(entry, 0, equals)
        let val = strpart(entry, equals + 1)
        let env[key] = val
    endfor

    return env
endfunction

function! s:goto_window(winid) abort
    call system("wmctrl -i -a " . printf('0x%x', a:winid))
endfunction

function! s:get_tmux_info(paneid) abort
    let tmux_info = system("tmux list-panes -a -F '#{pane_id} #{session_name} #{window_index} #{pane_index}'")

    for line in split(tmux_info, '\n')
        let [pane_id, session_name, window_index, pane_index] = split(line)
        if pane_id == a:paneid
            return [session_name, window_index, pane_index]
        endif
    endfor
endfunction

function! s:goto_tmux_pane(paneid) abort
    let [session_name, window_index, pane_index] = s:get_tmux_info(a:paneid)

    call system('tmux select-window -t ' . session_name . ':' . window_index)
    call system('tmux select-pane -t ' . session_name . ':' . window_index . '.' . pane_index)
endfunction

function! s:goto_session(pid) abort
    let env = s:get_env(a:pid)

    call s:goto_window(env.WINDOWID)
    if has_key(env, "TMUX_PANE")
        call s:goto_tmux_pane(env.TMUX_PANE)
    endif
endfunction

function! s:setup_diff(swapname) abort
    let b:recovered_file = tempname()
    let b:swapname = a:swapname
    call system(printf("vim -u NONE -N -X -r %s -c ':write %s' -c ':q!'",
              \ a:swapname, shellescape(b:recovered_file)))

    augroup swap_diff
        autocmd BufReadPost <buffer> call s:diff_recover()
    augroup END
endfunction

function! s:diff_recover() abort
    let filetype = &filetype
    diffthis
    execute "noautocmd rightbelow vertical new " . b:recovered_file

    let &filetype = filetype
    execute ":file! " . fnameescape(expand('<afile>') . " (recovered)")
    setlocal noswapfile buftype=nowrite bufhidden=delete nobuflisted
    let swapwinnr = winnr()
    diffthis
    noautocmd wincmd p

    let b:swapwinnr = swapwinnr
    setlocal modified

    autocmd swap_diff BufWritePost <buffer> call s:diff_finish()
endfunction

function! s:diff_finish() abort
    execute b:swapwinnr . "wincmd w"
    diffoff
    bdelete!
    diffoff

    call delete(fnameescape(b:recovered_file))
    call delete(b:swapname)

    silent setlocal noswapfile swapfile

    autocmd! swap_diff
    unlet! b:recovered_file b:swapname b:swapwinnr
endfunction
