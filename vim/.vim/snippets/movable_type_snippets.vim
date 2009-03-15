" ==========================================================
" File Name:    movable_type_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 19:04:28
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet cat         <$MTCategoryDescription$><{}>
    DefineSnippet blog        <$MTBlogName$><{}>
    DefineSnippet archive     <$MTArchiveFile$><{}>
    DefineSnippet cal         <MTCalendarIfEntries><CR><Tab><{}><CR></MTCalendarIfEntries><CR><{}>
    DefineSnippet entry       <$MTEntryMore$><{}>
    DefineSnippet entries     <MTEntriesHeader><CR><Tab><{}><CR></MTEntriesHeader><CR><{}>
endfunction

" }}}1
" s:set_compiler_info {{{1

function! s:set_compiler_info()
    
endfunction

" }}}1

if exists('loaded_cca')
    filetype indent on

    " TODO: what is the ext-name of this filetype ?
    " let b:{cca_filetype_ext_var} = '<{ext}>'
    let b:{cca_locale_tag_var} = { "start": "<{", "end" : "}\>", "cmd" : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    " let b:{ctk_filetype_ext_var} = '<{ext}>'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
