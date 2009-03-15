" ==========================================================
" File Name:    css_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:15:33
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet visibility  <{}>;<{}>
    DefineSnippet list        list-style-image: url(<{}>);<{}>
    DefineSnippet text        text-shadow: rgb(<{}>, <{}>, <{}>, <{}> <{}> <{}>;<{}>
    DefineSnippet overflow    overflow: <{}>;<{}>
    DefineSnippet white       white-space: <{}>;<{}>
    DefineSnippet clear       cursor: url(<{}>);<{}>
    DefineSnippet margin      padding-top: <{}>;<{}>
    DefineSnippet background  background #<{}> url(<{}>) <{}> <{}> top left/top center/top right/center left/center center/center right/bottom left/bottom center/bottom right/x% y%/x-pos y-pos')}>;<{}>
    DefineSnippet word        word-spaceing: <{}>;<{}>
    DefineSnippet z           z-index: <{}>;<{}>
    DefineSnippet vertical    vertical-align: <{}>;<{}>
    DefineSnippet marker      marker-offset: <{}>;<{}>
    DefineSnippet cursor      cursor: <{}>;<{}>
    DefineSnippet border      border-right: <{}>px <{}> #<{}>;<{}>
    DefineSnippet display     display: block;<{}>
    DefineSnippet padding     padding: <{}> <{}>;<{}>
    DefineSnippet letter      letter-spacing: <{}>em;<{}>
    DefineSnippet color       color: rgb(<{}>, <{}>, <{}>);<{}>
    DefineSnippet font        font-weight: <{}>;<{}>
    DefineSnippet position    position: <{}>;<{}>
    DefineSnippet direction   direction: <{}>;<{}>
    DefineSnippet float       float: <{}>;<{}>
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

    let b:{cca_filetype_ext_var} = 'css'
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}\>", "cmd"  : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    let b:{ctk_filetype_ext_var} = 'css'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
