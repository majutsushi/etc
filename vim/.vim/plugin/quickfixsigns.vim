" Mark quickfix & location list items with signs
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-03-14.
" @Last Change: 2009-08-02.
" @Revision:    276
" GetLatestVimScripts: 2584 1 :AutoInstall: quickfixsigns.vim

if &cp || exists("loaded_quickfixsigns") || !has('signs')
    finish
endif
let loaded_quickfixsigns = 4

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:quickfixsigns_lists')
    " A list of list definitions whose items should be marked with signs.
    " By default, the following lists are included: |quickfix|, 
    " |location-list|, marks |'a|-zA-Z (see also 
    " |g:quickfixsigns_marks|).
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
                \ {'sign': 'QFS_QFL', 'get': 'getqflist()', 'event': ['BufEnter']},
                \ {'sign': 'QFS_LOC', 'get': 'getloclist(winnr())', 'event': ['BufEnter']},
                \ ]
endif

if !exists('g:quickfixsigns_marks')
    " A list of marks that should be displayed as signs.
    let g:quickfixsigns_marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>', '\zs') "{{{2
    " let g:quickfixsigns_marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>''`^.(){}[]', '\zs') "{{{2
    " let g:quickfixsigns_marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>.''`^', '\zs') "{{{2
endif

if !exists('g:quickfixsigns_marks_def')
    " The definition of the |g:quickfixsigns_lists| item for marks. Must 
    " have a field "type" with value "marks".
    " :read: let g:quickfixsigns_marks_def = {...} "{{{2
    let g:quickfixsigns_marks_def = {
                \ 'type': 'marks',
                \ 'sign': '*s:MarkSign',
                \ 'get': 's:Marks()',
                \ 'id': 's:MarkId',
                \ 'event': ['BufEnter', 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI'],
                \ 'timeout': 2
                \ }
    " \ 'event': ['BufEnter', 'CursorHold', 'CursorHoldI'],
endif
if !&lazyredraw
    let s:cmn = index(g:quickfixsigns_marks_def.event, 'CursorMoved')
    let s:cmi = index(g:quickfixsigns_marks_def.event, 'CursorMovedI')
    if s:cmn >= 0 || s:cmi >= 0
        echohl Error
        echom "quickfixsigns: Support for CursorMoved(I) events requires 'lazyredraw' to be set"
        echohl NONE
        if s:cmn >= 0
            call remove(g:quickfixsigns_marks_def.event, s:cmn)
        endif
        if s:cmi >= 0
            call remove(g:quickfixsigns_marks_def.event, s:cmi)
        endif
    endif
    unlet s:cmn s:cmi
endif

if !exists('g:quickfixsigns_balloon')
    " If non-null, display a balloon when hovering with the mouse over 
    " the sign.
    " buffer-local or global
    let g:quickfixsigns_balloon = 1   "{{{2
endif

if !exists('g:quickfixsigns_max')
    " Don't display signs if the list is longer than n items.
    let g:quickfixsigns_max = 100   "{{{2
endif



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
sign define QFS_DUMMY text=. texthl=SignColumn

let s:last_run = {}


" (Re-)Set the signs that should be updated at a certain event. If event 
" is empty, update all signs.
"
" Normally, the end-user doesn't need to call this function.
function! QuickfixsignsSet(event) "{{{3
    " let lz = &lazyredraw
    " set lz
    " try
        let bn = bufnr('%')
        let anyway = empty(a:event)
        for def in g:quickfixsigns_lists
            if anyway || index(get(def, 'event', ['BufEnter']), a:event) != -1
                let t_d = get(def, 'timeout', 0)
                let t_l = localtime()
                let t_s = string(def)
                " TLogVAR t_s, t_d, t_l
                if anyway || (t_d == 0) || (t_l - get(s:last_run, t_s, 0) >= t_d)
                    let s:last_run[t_s] = t_l
                    let list = eval(def.get)
                    " TLogVAR list
                    call filter(list, 'v:val.bufnr == bn')
                    " TLogVAR list
                    if !empty(list) && len(list) < g:quickfixsigns_max
                        let get_id = get(def, 'id', 's:SignId')
                        call s:ClearBuffer(def.sign, bn, s:PlaceSign(def.sign, list, get_id))
                        if has('balloon_eval') && g:quickfixsigns_balloon && !exists('b:quickfixsigns_balloon') && empty(&balloonexpr)
                            let b:quickfixsigns_ballooneval = &ballooneval
                            let b:quickfixsigns_balloonexpr = &balloonexpr
                            setlocal ballooneval balloonexpr=QuickfixsignsBalloon()
                            let b:quickfixsigns_balloon = 1
                        endif
                    else
                        call s:ClearBuffer(def.sign, bn, [])
                    endif
                endif
            endif
        endfor
    " finally
    "     if &lz != lz
    "         let &lz = lz
    "     endif
    " endtry
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
    for mark in g:quickfixsigns_marks
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


" Clear all signs with name SIGN.
function! QuickfixsignsClear(sign) "{{{3
    " TLogVAR a:sign_rx
    let idxs = filter(keys(s:register), 's:register[v:val].sign ==# a:sign')
    " TLogVAR idxs
    for idx in idxs
        exec 'sign unplace '. idx .' buffer='. s:register[idx].bn
        call remove(s:register, idx)
    endfor
endf


" Clear all signs with name SIGN in buffer BUFNR.
function! s:ClearBuffer(sign, bufnr, new_idxs) "{{{3
    " TLogVAR a:sign, a:bufnr, a:new_idxs
    let old_idxs = filter(keys(s:register), 's:register[v:val].sign ==# a:sign && s:register[v:val].bn == a:bufnr && index(a:new_idxs, v:val) == -1')
    " TLogVAR old_idxs
    for idx in old_idxs
        exec 'sign unplace '. idx .' buffer='. s:register[idx].bn
        call remove(s:register, idx)
    endfor
endf


function! s:ClearDummy(idx, bufnr) "{{{3
    exec 'sign unplace '. a:idx .' buffer='. a:bufnr
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
function! s:PlaceSign(sign, list, ...) "{{{3
    " TAssertType a:sign, 'string'
    " TAssertType a:list, 'list'
    " TLogVAR a:sign, a:list
    let get_id = a:0 >= 1 ? a:1 : "<SID>SignId"
    " TLogVAR get_id
    let new_idxs = []
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
            let bn   = get(item, 'bufnr')
            let sdef = {'sign': a:sign, 'bn': bn, 'item': item, 'idx': idx}
            call add(new_idxs, string(idx))
            if has_key(s:register, idx)
                if s:register[idx] == sdef
                    continue
                else
                    " TLogVAR item
                    " TLogDBG ':sign unplace '. idx .' buffer='. bn
                    exec ':sign unplace '. idx .' buffer='. bn
                    unlet s:register[idx]
                endif
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
    return new_idxs
endf


" Enable (state=1) or disable (state=0) the display of marks.
function! QuickfixsignsMarks(state) "{{{3
    " TLogVAR a:state
    call filter(g:quickfixsigns_lists, 'get(v:val, "type", "") != "marks"')
    if a:state
        call add(g:quickfixsigns_lists, g:quickfixsigns_marks_def)
    else
        call QuickfixsignsClear(g:quickfixsigns_marks_def.sign)
    endif
endf


if !empty(g:quickfixsigns_marks)
    call QuickfixsignsMarks(1)
    
    for s:i in g:quickfixsigns_marks
        if index(s:signs, 'QFS_Mark_'. s:i) == -1
            exec 'sign define QFS_Mark_'. s:i .' text='. s:i .' texthl=Identifier'
        endif
    endfor
    unlet s:i
endif

unlet s:signs s:signss


augroup QuickFixSigns
    autocmd!
    let s:ev_set = []
    for s:def in g:quickfixsigns_lists
        for s:ev in get(s:def, 'event', ['BufEnter'])
            if index(s:ev_set, s:ev) == -1
                exec 'autocmd '. s:ev .' * call QuickfixsignsSet("'. s:ev .'")'
                call add(s:ev_set, s:ev)
            endif
        endfor
    endfor
    unlet s:ev_set s:ev s:def
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
finish

CHANGES:
0.1
- Initial release

0.2
- exists('b:quickfixsigns_balloonexpr')

0.3
- Old signs weren't always removed
- Avoid "flicker" etc.
- g:quickfixsigns_max: Don't display signs if the list is longer than n items.
Incompatible changes:
- Removed g:quickfixsigns_show_marks variable
- g:quickfixsigns_marks: Marks that should be used for signs
- g:quickfixsigns_lists: event field is a list
- g:quickfixsigns_lists: timeout field: don't re-display this list more often than n seconds

0.4
- FIX: Error when g:quickfixsigns_marks = [] (thanks Ingo Karkat)
- s:ClearBuffer: removed old code
- QuickfixsignsMarks(state): Switch the display of marks on/off.

0.5
- Set balloonexpr only if empty (don't try to be smart)
- Disable CursorMoved(I) events, when &lazyredraw isn't set.

