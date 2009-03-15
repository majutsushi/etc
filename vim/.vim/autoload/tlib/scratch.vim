" scratch.vim
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-07-18.
" @Last Change: 2007-11-01.
" @Revision:    0.0.119

if &cp || exists("loaded_tlib_scratch_autoload")
    finish
endif
let loaded_tlib_scratch_autoload = 1


" :def: function! tlib#scratch#UseScratch(?keyargs={})
" Display a scratch buffer (a buffer with no file). See :TScratch for an 
" example.
" Return the scratch's buffer number.
function! tlib#scratch#UseScratch(...) "{{{3
    exec tlib#arg#Let([['keyargs', {}]])
    " TLogDBG string(keys(keyargs))
    let id = get(keyargs, 'scratch', '__Scratch__')
    " TLogVAR id
    " TLogDBG winnr()
    " TLogDBG bufnr(id)
    " TLogDBG bufwinnr(id)
    " TLogDBG bufnr('%')
    if id =~ '^\d\+$' && bufwinnr(id) != -1
        if bufnr('%') != id
            exec 'buffer! '. id
        endif
    else
        let bn = bufnr(id)
        let wpos = g:tlib_scratch_pos
        if get(keyargs, 'scratch_vertical')
            let wpos .= ' vertical'
        endif
        " TLogVAR wpos
        if bn != -1
            " TLogVAR bn
            let wn = bufwinnr(bn)
            if wn != -1
                " TLogVAR wn
                exec wn .'wincmd w'
            else
                let cmd = get(keyargs, 'scratch_split', 1) ? wpos.' sbuffer! ' : 'buffer! '
                " TLogVAR cmd
                silent exec cmd . bn
            endif
        else
            " TLogVAR id
            let cmd = get(keyargs, 'scratch_split', 1) ? wpos.' split ' : 'edit '
            " TLogVAR cmd
            silent exec cmd . escape(id, '%#\ ')
            " silent exec 'split '. id
        endif
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        setlocal nobuflisted
        setlocal modifiable
        setlocal foldmethod=manual
        setlocal foldcolumn=0
        let ft = get(keyargs, 'scratch_filetype', '')
        " TLogVAR ft
        " if !empty(ft)
            let &ft=ft
        " end
    endif
    let keyargs.scratch = bufnr('%')
    return keyargs.scratch
endf


" Close a scratch buffer as defined in keyargs (usually a World).
function! tlib#scratch#CloseScratch(keyargs, ...) "{{{3
    TVarArg ['reset_scratch', 1]
    let scratch = get(a:keyargs, 'scratch', '')
    " TLogVAR scratch, reset_scratch
    if !empty(scratch)
        let wn = bufwinnr(scratch)
        " TLogVAR wn
        if wn != -1
            " TLogDBG winnr()
            let wb = tlib#win#Set(wn)
            wincmd c
            " exec wb 
            " redraw
            " TLogDBG winnr()
        endif
        if reset_scratch
            let a:keyargs.scratch = ''
        endif
    endif
endf

