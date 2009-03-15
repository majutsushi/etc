" ==========================================================
" File Name:    django_template_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:26:45
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet {{          {% templatetag openvariable %}<{}>
    DefineSnippet }}          {% templatetag closevariable %}<{}>
    DefineSnippet {%          {% templatetag openblock %}<{}>
    DefineSnippet %}          {% templatetag closeblock %}<{}>
    DefineSnippet now         {% now "<{}>" %}<{}>
    DefineSnippet firstof     {% firstof <{}> %}<{}>
    DefineSnippet ifequal     {% ifequal <{}> <{}> %}<CR><{}><CR>{% endifequal %}<CR><{}>
    DefineSnippet ifchanged   {% ifchanged %}<{}>{% endifchanged %}<{}>
    DefineSnippet regroup     {% regroup <{}> by <{}> as <{}> %}<{}>
    DefineSnippet extends     {% extends "<{}>" %}<CR><{}>
    DefineSnippet filter      {% filter <{}> %}<CR><{}><CR>{% endfilter %}<{}>
    DefineSnippet block       {% block <{}> %}<CR><{}><CR>{% endblock %}<CR><{}>
    DefineSnippet cycle       {% cycle <{}> as <{}> %}<{}>
    DefineSnippet if          {% if <{}> %}<CR><{}><CR>{% endif %}<CR><{}>
    DefineSnippet debug       {% debug %}<CR><{}>
    DefineSnippet ifnotequal  {% ifnotequal <{}> <{}> %}<CR><{}><CR>{% endifnotequal %}<CR><{}>
    DefineSnippet include     {% include <{}> %}<CR><{}>
    DefineSnippet comment     {% comment %}<CR><{}><CR>{% endcomment %}<CR><{}>
    DefineSnippet for         {% for <{}> in <{}> %}<CR><{}><CR>{% endfor %}<CR><{}>
    DefineSnippet ssi         {% ssi <{}> <{}> %}<{}>
    DefineSnippet widthratio  {% widthratio <{}> <{}> <{}> %}<{}>
    DefineSnippet load        {% load <{}> %}<CR><{}>
    DefineSnippet field       <p><label for="id_<{fieldname}>"><{fieldlabel}>:</label> {{ form.<{fieldname}> }}<CR>{% if form.<{fieldname}>.errors %}*** {{ form.<{fieldname}>.errors|join:", " }} {% endif %}</p><{}>
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

    " TODO: what is the ext-name of this filetype?
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
