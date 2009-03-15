" ==========================================================
" File Name:    common.vim
" Author:       StarWing
" Version:      0.1
" Last Change:  2009-01-30 14:59:37
" ==========================================================
if exists('loaded_cca')
    let b:{cca_locale_tag_var} = {'tagstart': '<{', 'tagend': '}>', 'command': ':'}

    DefineSnippet dt <{:strftime("%Y-%m-%d")}>
    DefineSnippet xt <{:strftime("%Y-%m-%d %H:%M:%S")}>
endif

" vim: ft=vim:fdm=marker:ts=4:sw=4:et:sta
