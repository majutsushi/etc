" ==========================================================
" File Name:    html_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:33:43
" ==========================================================
let s:cpo_save = &cpo
set cpo&vim
" cca:html:select_doctype {{{1
function! cca:html:select_doctype()
    call inputsave()
    let dt = inputlist(['Select doctype:',
                \ '1. HTML 4.01',
                \ '2. HTML 4.01 Transitional',
                \ '3. HTML 4.01 Frameset',
                \ '4. XHTML 1.0 Frameset',
                \ '5. XHTML Strict',
                \ '6. XHTML Transitional',
                \ '7. XHTML Frameset'])
    call inputrestore()
    let dts = {1: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"\n\"http://www.w3.org/TR/html4/strict.dtd\">",
             \ 2: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n\"http://www.w3.org/TR/html4/loose.dtd\">",
             \ 3: "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\"\n\"http://www.w3.org/TR/html4/frameset.dtd\">",
             \ 4: "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">",
             \ 5: "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Strict//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">",
             \ 6: "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Transitional//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">",
             \ 7: "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Frameset//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">"}
    
    return dts[dt]
endfunction
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet doct        <C-R>=cca:html:select_doctype()<CR><CR><{}>
    DefineSnippet doctype     <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"<CR><TAB>"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"><CR><{}>
    DefineSnippet doc4s       <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"<CR>"http://www.w3.org/TR/html4/strict.dtd"><CR><{}>
    DefineSnippet doc4t       <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"<CR>"http://www.w3.org/TR/html4/loose.dtd"><CR><{}>
    DefineSnippet doc4f       <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"<CR>"http://www.w3.org/TR/html4/frameset.dtd"><CR><{}>
    DefineSnippet docxs       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Strict//EN"<CR>"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><CR><{}>
    DefineSnippet docxt       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Transitional//EN"<CR>"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><CR><{}>
    DefineSnippet docxf       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Frameset//EN"<CR>"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"><CR><{}>
    DefineSnippet head        <head><CR><meta http-equiv="Content-type" content="text/html; charset=utf-8" /><CR><title><{}></title><CR><{}><CR></head><CR><{}>
    DefineSnippet script      <script type="text/javascript" language="javascript" charset="utf-8"><CR>// <![CDATA[<CR><TAB><{}><CR>// ]]><CR></script><CR><{}>
    DefineSnippet title       <title><{}></title>
    DefineSnippet body        <body id="<{}>" <{}>><CR><{}><CR></body><CR><{}>
    DefineSnippet scriptsrc   <script src="<{}>" type="text/javascript" language="<{}>" charset="<{}>"></script><CR><{}>
    DefineSnippet textarea    <textarea name="<{}>" rows="<{}>" cols="<{}>"><{}></textarea><CR><{}>
    DefineSnippet meta        <meta name="<{}>" content="<{}>" /><CR><{}>
    DefineSnippet movie       <object width="<{}>" height="<{}>"<CR>classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B"<CR>codebase="http://www.apple.com/qtactivex/qtplugin.cab"><CR><param name="src"<CR>value="<{}>" /><CR><param name="controller" value="<{}>" /><CR><param name="autoplay" value="<{}>" /><CR><embed src="<{}>"<CR>width="<{}>" height="<{}>"<CR>controller="<{}>" autoplay="<{}>"<CR>scale="tofit" cache="true"<CR>pluginspage="http://www.apple.com/quicktime/download/"<CR>/><CR></object><CR><{}>
    DefineSnippet div         <div <{}>><CR><{}><CR></div><CR><{}>
    DefineSnippet mailto      <a href="mailto:<{}>?subject=<{}>"><{}></a><{}>
    DefineSnippet table       <table border="<{}>"<{}> cellpadding="<{}>"><CR><tr><th><{}></th></tr><CR><tr><td><{}></td></tr><CR></table>
    DefineSnippet link        <link rel="<{}>" href="<{}>" type="text/css" media="<{}>" title="<{}>" charset="<{}>" />
    DefineSnippet form        <form action="<{}>" method="<{}>"><CR><{}><CR><CR><p><input type="submit" value="Continue &rarr;" /></p><CR></form><CR><{}>
    DefineSnippet ref         <a href="<{}>"><{}></a><{}>
    DefineSnippet h1          <h1 id="<{}>"><{}></h1><{}>
    DefineSnippet input       <input type="<{}>" name="<{}>" value="<{}>" <{}>/><{}>
    DefineSnippet style       <style type="text/css" media="screen"><CR>/* <![CDATA[ */<CR><{}><CR>/* ]]> */<CR></style><CR><{}>
    DefineSnippet base        <base href="<{}>"<{}> /><{}>
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

    let b:{cca_filetype_ext_var} = 'html'
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}\>", "cmd"  : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    " let b:{ctk_filetype_ext_var} = 'html'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
