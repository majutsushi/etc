" ==========================================================
" File Name:    aspvbs_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:09:49
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet rr          Response.Redirect(<{to}>)<{}>
    DefineSnippet app         Application("<{}>")<{}>
    DefineSnippet forin       For <{var}> in <{array}><CR><{}><CR>Next<CR><{}>
    DefineSnippet ifelse      If <{condition}> Then<CR><{}><CR>Else<CR><{}><CR>End if<CR><{}>
    DefineSnippet rw          Response.Write <{}>
    DefineSnippet sess        Session("<{}>")<{}>
    DefineSnippet rf          Request.Form("<{}>")<{}>
    DefineSnippet rq          Request.QueryString("<{}>")<{}>
    DefineSnippet while       While <{NOT}> <{condition}><CR><{}><CR>Wend<CR><{}>
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

    let b:{cca_filetype_ext_var} = 'vbs'
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}\>", "cmd"  : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    let b:{ctk_filetype_ext_var} = 'vbs'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
