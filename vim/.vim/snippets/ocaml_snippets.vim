" ==========================================================
" File Name:    ocaml_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 19:14:45
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet Queue       Queue.fold <{}> <{base}> <{q}><CR><{}>
    DefineSnippet Nativeint   Nativeint.abs <{ni}><{}>
    DefineSnippet Printexc    Printexc.print <{fn}> <{x}><{}>
    DefineSnippet Sys         Sys.Signal_ignore<{}>
    DefineSnippet Hashtbl     Hashtbl.iter <{}> <{h}><{}>
    DefineSnippet Array       Array.map <{}> <{arr}><{}>
    DefineSnippet Printf      Printf.fprintf <{buf}> "<{format}>" <{args}><{}>
    DefineSnippet Stream      Stream.iter <{}> <{stream}><{}>
    DefineSnippet Buffer      Buffer.add_channel <{buf}> <{ic}> <{len}><{}>
    DefineSnippet Int32       Int32.abs <{i32}><{}>
    DefineSnippet List        List.rev_map <{}> <{lst}><{}>
    DefineSnippet Scanf       Scanf.bscaf <{sbuf}> "<{format}>" <{f}><{}>
    DefineSnippet Int64       Int64.abs <{i64}><{}>
    DefineSnippet Map         Map.Make <{}>
    DefineSnippet String      String.iter <{}> <{str}><{}>
    DefineSnippet Genlex      Genlex.make_lexer <{"tok_lst"}> <{"char_stream"}><{}>
    DefineSnippet for         for <{i}> = <{}> to <{}> do<CR><{}><CR>done<CR><{}>
    DefineSnippet Stack       Stack.iter <{}> <{stk}><{}>
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
