" ==========================================================
" File Name:    f-script_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:30:25
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet tbd         to:<{}> by:<{}> do:[ <{}> |<CR><{}><CR>].<{}>
    DefineSnippet it          ifTrue:[<CR><{}><CR>].<{}>
    DefineSnippet ift         ifFalse:[<CR><{}><CR>] ifTrue:[<CR><{}><CR>].<{}>
    DefineSnippet itf         ifTrue:[<CR><{}><CR>] ifFalse:[<CR><{}><CR>].<{}>
    DefineSnippet td          to:<{}> do:[<{}> <{}> |<CR><{}><CR>].<{}>
    DefineSnippet if          ifFalse:[<CR><{}><CR>].<{}>
endfunction

" }}}1
" s:set_compiler_info {{{1

function! s:set_compiler_info()
    
endfunction

" }}}1

if exists('loaded_cca')
    filetype indent on
    " for {{{ and }}} support
    set fdm=marker

    " TODO: what is the ext-name of this filetype ?
    " let b:{cca_filetype_ext_var} = '<{ext}>'
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}\>", "cmd"  : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    " let b:{ctk_filetype_ext_var} = '<{ext}>'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
