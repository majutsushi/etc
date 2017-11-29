" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

setlocal textwidth=0

setlocal shiftwidth=4
setlocal expandtab
setlocal autoindent
setlocal breakindent
setlocal breakindentopt=shift:2
setlocal linebreak

setlocal foldmethod=expr
setlocal foldexpr=VfFoldLevel(v:lnum)
setlocal foldtext=VfFoldText()
setlocal foldenable
setlocal foldcolumn=0


" Determine the indent level of a line.
function! s:indent(line) abort
    return indent(a:line) / shiftwidth()
endfunction

function! s:is_note(line) abort
    return getline(a:line) !~# '^\s*[*-]'
endfunction

function! VfFoldLevel(line) abort
    let myindent = s:indent(a:line)
    let nextindent = s:indent(a:line + 1)

    if !s:is_note(a:line - 1) && s:is_note(a:line)
        return '>' . (myindent + 1)
    elseif s:is_note(a:line) && !s:is_note(a:line + 1)
        return '<' . (myindent + 1)
    elseif s:is_note(a:line)
        return '='
    elseif myindent < nextindent
        return '>' . (myindent + 1)
    else
        return myindent
    endif
endfunction

function! VfFoldText() abort
    return getline(v:foldstart)
endfunction


" Return the line number of the current node.
" This is only different from the current line when in a note.
function! s:curnodelinenr() abort
    return search('^\s*[*-]', 'bcnW')
endfunction

" Return the line number of the last line of the current subtree
function! s:subtree_end() abort
    let nodelinenr = s:curnodelinenr()
    let line = search('\%>' . nodelinenr . 'l\%<' . (indent(nodelinenr) + 2) . 'v[*-]', 'nW') - 1
    return line < 0 ? line('$') : line
endfunction


function! s:add_sibling() abort
    if foldclosed('.') > -1
        call cursor(foldclosed('.'), 1)
    endif
    let indent = indent(s:curnodelinenr())
    let endline = s:subtree_end()
    call append(endline, repeat(' ', indent) . '* ')
    call cursor(endline + 1, 1)
    call feedkeys('A', 't')
endfunction

function! s:add_note() abort
    if foldclosed('.') > -1
        call cursor(foldclosed('.'), 1)
    endif

    if s:is_note(line('.') + 1)
        let prev_line = search('^\s*[*-]', 'nW')
        if prev_line == 0
            let prev_line = line('$')
        else
            let prev_line -= 1
        endif
    else
        let prev_line = line('.')
    endif

    let indent = indent(s:curnodelinenr())
    call append(prev_line, repeat(' ', indent + shiftwidth()))
    call cursor(prev_line + 1, 1)
    call feedkeys('A', 't')
endfunction

function! s:indent_subtree(direction) abort
    let endline = s:subtree_end()
    let column = col('.')
    return (endline - line('.') + 1) . (a:direction ? '>>' : '<<')
                \ . (column + (a:direction ? shiftwidth() : -shiftwidth())) . '|'
endfunction

function! s:toggle_done() abort
    let nodelinenr = s:curnodelinenr()
    let line = getline(nodelinenr)
    if line =~# '^\s*\*'
        call setline(nodelinenr, substitute(line, '^\s*\zs\*', '-', ''))
    else
        call setline(nodelinenr, substitute(line, '^\s*\zs-',  '*', ''))
    endif
endfunction


nnoremap <silent> <buffer> <CR>   :call <SID>add_sibling()<CR>
nnoremap <silent> <buffer> <S-CR> :call <SID>add_note()<CR>
nnoremap <silent> <buffer> <C-CR> :call <SID>toggle_done()<CR>

nnoremap <silent> <buffer> <expr> >>      <SID>indent_subtree(1)
nnoremap <silent> <buffer> <expr> <<      <SID>indent_subtree(0)
nnoremap <silent> <buffer> <expr> <Tab>   <SID>indent_subtree(1)
nnoremap <silent> <buffer> <expr> <S-Tab> <SID>indent_subtree(0)

inoremap <silent> <buffer> <expr> <C-t>   "\<Esc>" . <SID>indent_subtree(1) . "i"
inoremap <silent> <buffer> <expr> <C-d>   col('.') > strlen(getline('.'))
            \ ? ("\<Esc>" . <SID>indent_subtree(0) . "i") : "\<Del>"
inoremap <silent> <buffer> <expr> <Tab>   "\<Esc>" . <SID>indent_subtree(1) . "i"
inoremap <silent> <buffer> <expr> <S-Tab> "\<Esc>" . <SID>indent_subtree(0) . "i"
