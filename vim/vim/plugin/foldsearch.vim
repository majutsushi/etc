" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11
" Original code from
" https://github.com/jszakmeister/vimfiles/blob/master/vimrc

if &compatible || exists('loaded_foldsearch')
    finish
endif
let loaded_foldsearch = 1

let w:foldsearch_folded = 0

function s:sid() abort
    return matchstr(expand('<sfile>'), '\zs<SNR>\d\+_\zeSID$')
endfun

function! s:fold_show_expr() abort
    return (getline(v:lnum) =~# @/) ? 0 : 1
endfunction

function! s:fold_hide_expr() abort
    return (getline(v:lnum) =~# @/) ? 1 : 0
endfunction

function! s:fold_regex(func, regex) abort
    if a:regex != ''
        let @/ = a:regex
        call histadd('search', a:regex)
    endif

    " Save current settings
    let w:foldsearch_foldexpr = &foldexpr
    let w:foldsearch_foldmethod = &foldmethod
    let w:foldsearch_foldlevel = &foldlevel
    let w:foldsearch_foldminlines = &foldminlines
    let w:foldsearch_foldenable = &foldenable

    let &foldexpr = s:sid() . a:func . '()'

    setlocal foldmethod=expr
    setlocal foldlevel=0
    setlocal foldminlines=0
    setlocal foldenable

    " Set manual folding to allow more fold tweaking
    setlocal foldmethod=manual

    let w:foldsearch_folded = 1
endfunction

function! s:fold_restore() abort
    if !w:foldsearch_folded
        echo 'No fold command active; nothing to restore'
        return
    endif

    let &foldexpr = w:foldsearch_foldexpr
    let &foldmethod = w:foldsearch_foldmethod
    let &foldlevel = w:foldsearch_foldlevel
    let &foldminlines = w:foldsearch_foldminlines
    let &foldenable = w:foldsearch_foldenable

    let w:foldsearch_folded = 0
endfunction

" Search (and "show") regex; fold everything else.
command! -nargs=? Foldshow call s:fold_regex('fold_show_expr', <q-args>)

" Fold matching lines ("hide" the matches).
command! -nargs=? Foldhide call s:fold_regex('fold_hide_expr', <q-args>)

" Fold away comment lines (including blank lines).
" TODO: Extend for more than just shell comments.
command! -nargs=0 Foldcomments Fold ^\s*#\|^\s*$

command! -nargs=0 Foldrestore call s:fold_restore()
