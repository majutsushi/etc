" ==========================================================
" File Name:    django_model_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:18:51
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet mmodel      class <{}>(models.Model):<CR>"""<{}>"""<CR><{}> = <{}><CR><CR>class Admin:<CR>pass<CR><CR>def __str__(self):<CR>return "<{s}>" % <{s:'('.repeat('<{}>, ', cca:count(@z, '%[^%]')).')'}><CR><{}>
    DefineSnippet mauto       models.AutoField(<{}>)<{}>
    DefineSnippet mbool       models.BooleanField()<{}>
    DefineSnippet mchar       models.CharField(maxlength=<{50}><{}>)<{}>
    DefineSnippet mcsi        models.CommaSeparatedIntegerField(maxlength=<{50}><{}>)<{}>
    DefineSnippet mdate       models.DateField(<{}>)<{}>
    DefineSnippet mdatet      models.DateTimeField(<{}>)<{}>
    DefineSnippet memail      models.EmailField(<{}>)<{}>
    DefineSnippet mfile       models.FileField(upload_to="<{}>"<{}>)<{}>
    DefineSnippet mfilep      models.FilePathField(path="<{}>"<{}>)<{}>
    DefineSnippet mfloat      models.FloatField(max_digits=<{}>, decimal_places=<{}>)<{}>
    DefineSnippet mimage      models.ImageField(<{}>)<{}>
    DefineSnippet mint        models.IntegerField(<{}>)<{}>
    DefineSnippet mipadd      models.IPAddressField(<{}>)<{}>
    DefineSnippet mnull       models.NullBooleanField()<{}>
    DefineSnippet mphone      models.PhoneNumberField(<{}>)<{}>
    DefineSnippet mpint       models.PositiveIntegerField(<{}>)<{}>
    DefineSnippet mspint      models.PositiveSmallIntegerField(<{}>)<{}>
    DefineSnippet mslug       models.SlugField(<{}>)<{}>
    DefineSnippet msint       models.SmallIntegerField(<{}>)<{}>
    DefineSnippet mtext       models.TextField(<{}>)<{}>
    DefineSnippet mtime       models.TimeField(<{}>)<{}>
    DefineSnippet murl        models.URLField(verify_exists=<{True}><{}>)<{}>
    DefineSnippet muss        models.USStateField(<{}>)<{}>
    DefineSnippet mxml        models.XMLField(schema_path="<{}>"<{}>)<{}>
    DefineSnippet mfor        models.ForeignKey(<{}>)<{}>
    DefineSnippet mm2o        models.ForeignKey(<{}>)<{}>
    DefineSnippet mm2m        models.ManyToManyField(<{}>)<{}>
    DefineSnippet mo2o        models.OneToOneField(<{}>)<{}>
    DefineSnippet mman        models.Manager()<{}>
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

    " TODO: what's the ext-name of this file ??
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
