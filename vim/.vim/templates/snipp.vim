" ==========================================================
" File Name:    <C-R>=expand("%:t")<CR>
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    <{}>
endfunction

" }}}1
" s:set_compiler_info {{{1

function! s:set_compiler_info()
    <{}>
endfunction

" }}}1

if exists('loaded_cca')
    filetype indent on
    <{a:@z!='' ? '" for {{{ and }}} support:' : cca:normal('2dd', '!')}>
    set fdm=marker

    <{todo:@z!='' ? '" TODO: what is the ext-name of this filetype ?' : cca:normal('dd', '!')}>
    <{todo:@z!='' ? '" ':''}>let b:{cca_filetype_ext_var} = '<{ext}>'
    let b:{cca_locale_tag_var} = { "start": "<{", "end" : "}\>", "cmd" : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    <{todo}>let b:{ctk_filetype_ext_var} = '<{ext}>'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
