" tregisters.vim -- List, edit, and run/execute registers/clipboards
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-08-22.
" @Last Change: 2007-09-11.
" @Revision:    0.2.113
" GetLatestVimScripts: 2017 1 tregisters.vim

if &cp || exists("loaded_tregisters")
    finish
endif
if !exists('loaded_tlib') || loaded_tlib < 13
    echoerr 'tlib >= 0.13 is required'
    finish
endif
let loaded_tregisters = 2

let s:save_cpo = &cpo
set cpo&vim
function! s:SNR() "{{{3
    return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSNR$')
endf

" Editing numbered registers doesn't make much sense as they change when 
" calling |:TRegister|.
TLet g:tregisters_ro = '~:.%#0123456789'

if !exists('g:tregisters_handlers') "{{{2
    let g:tregisters_handlers = [
            \ {'key':  5, 'agent': s:SNR() .'AgentEditRegister', 'key_name': '<c-e>', 'help': 'Edit register'},
            \ {'key': 17, 'agent': s:SNR() .'AgentRunRegister', 'key_name': '<c-q>', 'help': 'Run register'},
            \ {'pick_last_item': 0},
            \ {'return_agent': s:SNR() .'ReturnAgent'},
            \ ]
endif


function! s:GetRegisters() "{{{3
    let registers = tlib#cmd#OutputAsList('registers')
    call filter(registers, 'v:val =~ ''^"''')
    call map(registers, 'substitute(v:val, ''\s\+'', " ", "g")')
    return registers
endf


function! s:AgentEditRegister(world, selected) "{{{3
    let reg = a:selected[0][1]
    if stridx(g:tregisters_ro, reg) == -1
        let world  = tlib#agent#Suspend(a:world, a:selected)
        let regval = getreg(reg)
        keepalt call tlib#input#Edit('Registers', regval, s:SNR() .'EditCallback', [reg])
        return world
    else
        echom 'Read-only register'
        let a:world.state = 'redisplay'
        return a:world
    endif
endf


function! s:AgentRunRegister(world, selected) "{{{3
    let sb = a:world.SwitchWindow('win')
    try
        for r in a:selected
            let rr = r[1]
            if stridx('%#=', rr) == -1
                exec 'norm! @'. rr
            endif
        endfor
    finally
        exec sb
    endtry
    let a:world.state = 'redisplay'
    return a:world
endf


function! s:EditCallback(register, ok, text) "{{{3
    " TLogVAR a:register, a:ok, a:text
    if a:ok
        if stridx(g:tregisters_ro, a:register) == -1
            call setreg(a:register, a:text)
            let b:tlib_world.base = s:GetRegisters()
        else
            echom 'Read-only register'
        endif
    endif
    call tlib#input#Resume("world")
endf


function! s:ReturnAgent(world, selected) "{{{3
    " TLogVAR a:selected
    if !empty(a:selected)
        let reg = a:selected[0][1]
        " TLogVAR reg
        exec 'put '. reg
    endif
endf


function! TRegisters() "{{{3
    let s:registers = s:GetRegisters()
    call tlib#input#List('s', 'Registers', s:registers, g:tregisters_handlers)
endf


" List the registers as returned by |:reg|. You will be able to edit 
" certain registers (see |g:tregisters_ro|).
command! TRegisters call TRegisters()


let &cpo = s:save_cpo

finish
------------------------------------------------------------------------

Command~
:TRegister
    List the registers as returned by |:reg|.

Keys~
    <c-e> ... Edit register/clipboard
    <c-q> ... Execute register (see |@|)
    <cr>  ... Put selected register(s) (see |:put|)
    <esc> ... Cancel


CHANGES
0.1 (0.2)
Initial release

