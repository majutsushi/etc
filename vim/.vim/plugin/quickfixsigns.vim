" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-03-14.
" @Last Change: 2009-03-17.
" @Revision:    70
" GetLatestVimScripts: 2584 1 :AutoInstall: quickfixsigns.vim
" Mark quickfix & location list items with signs

if &cp || exists("loaded_quickfixsigns") || !has('signs')
    finish
endif
let loaded_quickfixsigns = 2

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:quickfixsigns_lists')
    " A list of list definitions whose items should be marked with signs.
    " By default, the following lists are included: |quickfix|, 
    " |location-list|, marks |'a|-zA-Z (see also 
    " |g:quickfixsigns_show_marks|).
    "
    " A list definition is a |Dictionary| with the following fields:
    "
    "   sign:  The name of the sign, which has to be defined. If the 
    "          value begins with "*", the value is interpreted as 
    "          function name that is called with a qfl item as its 
    "          single argument.
    "   get:   A vim script expression as string that returns a list 
    "          compatible with |getqflist()|.
    "   event: The event on which signs of this type should be set. 
    "          Possible values: BufEnter, any
    " :read: let g:quickfixsigns_lists = [...] "{{{2
    let g:quickfixsigns_lists = [
                \ {'sign': 'QFS_QFL', 'get': 'getqflist()', 'event': 'BufEnter'},
                \ {'sign': 'QFS_LOC', 'get': 'getloclist(winnr())', 'event': 'BufEnter'},
                \ ]
endif

if !exists('g:quickfixsigns_show_marks') || g:quickfixsigns_show_marks
    " If non-null, also display signs for the marks a-zA-Z.
    let g:quickfixsigns_show_marks = 1 "{{{2
    call add(g:quickfixsigns_lists, {'sign': '*s:MarkSign', 'get': 's:Marks()', 'event': 'any', 'id': 's:MarkId'})
endif


if !exists('g:quickfixsigns_balloon')
    " If non-null, display a balloon when hovering with the mouse over 
    " the sign.
    " buffer-local or global
    let g:quickfixsigns_balloon = 1   "{{{2
endif

augroup QuickFixSigns
    autocmd!
    autocmd BufEnter * call QuickfixsignsSet('BufEnter')
    " autocmd CursorMoved,CursorMovedI * call QuickfixsignsSet('')
    if g:quickfixsigns_show_marks
        " autocmd BufEnter,CursorHold,CursorHoldI,InsertEnter,InsertChange,WinEnter * call QuickfixsignsSet('')
        autocmd BufEnter,CursorHold,CursorHoldI,InsertEnter,InsertChange * call QuickfixsignsSet('any')
    endif
    unlet g:quickfixsigns_show_marks
augroup END



" ----------------------------------------------------------------------


redir => s:signss
silent sign list
redir END
let s:signs = split(s:signss, '\n')
call filter(s:signs, 'v:val =~ ''^sign QFS_''')
call map(s:signs, 'matchstr(v:val, ''^sign \zsQFS_\w\+'')')

if index(s:signs, 'QFS_QFL') == -1
    sign define QFS_QFL text=* texthl=WarningMsg
endif
if index(s:signs, 'QFS_LOC') == -1
    sign define QFS_LOC text=> texthl=Special
endif


" let s:marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>''`^.(){}[]', '\zs')
let s:marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs')

for s:i in s:marks
    if index(s:signs, 'QFS_Mark_'. s:i) == -1
        exec 'sign define QFS_Mark_'. s:i .' text='. s:i .' texthl=Identifier'
    endif
endfor
unlet s:i s:signs s:signss


function! QuickfixsignsSet(event) "{{{3
    let lz = &lazyredraw
    set lz
    try
        let bn = bufnr('%')
        for def in g:quickfixsigns_lists
            if def.event ==# a:event
                let get_id = get(def, 'id', 's:SignId')
                if empty(get_id)
                    call s:ClearBuffer(def.sign, bn)
                endif
                let list = eval(def.get)
                " TLogVAR list
                call filter(list, 'v:val.bufnr == bn')
                " TLogVAR list
                if !empty(list)
                    call s:Mark(def.sign, list, get_id)
                    if has('balloon_eval') && g:quickfixsigns_balloon && !exists('b:quickfixsigns_balloon') && &balloonexpr != 'QuickfixsignsBalloon()'
                        let b:quickfixsigns_ballooneval = &ballooneval
                        let b:quickfixsigns_balloonexpr = &balloonexpr
                        setlocal ballooneval balloonexpr=QuickfixsignsBalloon()
                        let b:quickfixsigns_balloon = 1
                    endif
                    " elseif exists('b:quickfixsigns_balloonexpr')
                    "     let &l:balloonexpr = b:quickfixsigns_balloonexpr
                    "     let &l:ballooneval = b:quickfixsigns_ballooneval
                    "     unlet! b:quickfixsigns_balloonexpr b:quickfixsigns_ballooneval
                endif
            endif
        endfor
    finally
        if &lz != lz
            let &lz = lz
        endif
    endtry
endf


function! QuickfixsignsBalloon() "{{{3
    " TLogVAR v:beval_lnum, v:beval_col
    if v:beval_col <= 1
        let lnum = v:beval_lnum
        let bn = bufnr('%')
        let acc = []
        for def in g:quickfixsigns_lists
            let list = eval(def.get)
            call filter(list, 'v:val.bufnr == bn && v:val.lnum == lnum')
            if !empty(list)
                let acc += list
            endif
        endfor
        " TLogVAR acc
        return join(map(acc, 'v:val.text'), "\n")
    endif
    if exists('b:quickfixsigns_balloonexpr') && !empty(b:quickfixsigns_balloonexpr)
        return eval(b:quickfixsigns_balloonexpr)
    else
        return ''
    endif
endf


function! s:Marks() "{{{3
    let acc = []
    let bn  = bufnr('%')
    for mark in s:marks
        let pos = getpos("'". mark)
        if pos[0] == 0 || pos[0] == bn
            call add(acc, {'bufnr': bn, 'lnum': pos[1], 'col': pos[2], 'text': 'Mark_'. mark})
        endif
    endfor
    return acc
endf


function! s:MarkSign(item) "{{{3
    return 'QFS_'. a:item.text
endf


function! s:MarkId(item) "{{{3
    let bn = bufnr('%')
    let item = filter(values(s:register), 'v:val.bn == bn && v:val.item.text ==# a:item.text')
    if empty(item)
        return s:base + a:item.bufnr * 67 + char2nr(a:item.text[-1 : -1]) - 65
    else
        " TLogVAR item
        return item[0].idx
    endif
endf


let s:base = 5272
let s:register = {}


" Clear all signs with name SIGN in buffer BUFNR.
function! s:ClearBuffer(sign, bufnr) "{{{3
    for bn in keys(s:register)
        let idxs = keys(s:register)
        call filter(idxs, 's:register[v:val].sign ==# a:sign && s:register[v:val].bn == a:bufnr')
        " TLogVAR bns
        for idx in idxs
            exec 'sign unplace '. idx .' buffer='. s:register[idx].bn
            call remove(s:register, idx)
        endfor
    endfor
endf


function! s:SignId(item) "{{{3
    " TLogVAR a:item
    " let bn  = bufnr('%')
    let bn = get(a:item, 'bufnr', -1)
    if bn == -1
        return -1
    else
        let idx = s:base + bn * 427 + 1
        while has_key(s:register, idx)
            let idx += 1
        endwh
        return idx
    endif
endf


" Add signs for all locations in LIST. LIST must confirm with the 
" quickfix list format (see |getqflist()|; only the fields lnum and 
" bufnr are required).
"
" list:: a quickfix or location list
" sign:: a sign defined with |:sign-define|
function! s:Mark(sign, list, ...) "{{{3
    " TAssertType a:sign, 'string'
    " TAssertType a:list, 'list'
    " TLogVAR a:sign, a:list
    let get_id = a:0 >= 1 ? a:1 : "<SID>SignId"
    " TLogVAR get_id
    for item in a:list
        " TLogVAR item
        if a:sign[0] == '*'
            let sign = call(a:sign[1 : -1], [item])
            " TLogVAR sign
        else
            let sign = a:sign
        endif
        let idx = call(get_id, [item])
        " TLogVAR idx, sign
        if idx > 0
            let bn = get(item, 'bufnr')
            if has_key(s:register, idx)
                " TLogVAR item
                " TLogDBG ':sign unplace '. idx .' buffer='. bn
                exec ':sign unplace '. idx .' buffer='. bn
                unlet s:register[idx]
            endif
            let lnum = get(item, 'lnum', 0)
            if lnum > 0
                " TLogVAR item
                " TLogDBG ':sign place '. idx .' line='. lnum .' name='. sign .' buffer='. bn
                exec ':sign place '. idx .' line='. lnum .' name='. sign .' buffer='. bn
                let s:register[idx] = {'sign': a:sign, 'bn': bn, 'item': item, 'idx': idx}
            endif
        endif
    endfor
endf



let &cpo = s:save_cpo
unlet s:save_cpo
finish

CHANGES:
0.1
- Initial release

0.2
- exists('b:quickfixsigns_balloonexpr')

