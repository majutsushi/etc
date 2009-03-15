" ==========================================================
" File Name:    actionscript_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 17:59:10
" ==========================================================
if exists('loaded_cca')
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}>", "cmd"  : ":"}
    DefineSnippet dm duplicateMovieClip(<{target}>, <{newName}>, <{depth}>);
endif
