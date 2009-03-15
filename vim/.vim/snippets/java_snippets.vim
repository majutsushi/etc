" ==========================================================
" File Name:    java_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 18:38:44
" ==========================================================
" cca:java:test_filename {{{1

function! cca:java:test_filename(type)
    let filepath = expand('%:p')
    let filepath = substitute(filepath, '/', '.', 'g')
    let filepath = substitute(filepath, '^.\(:\\\)\?', '', '')
    let filepath = substitute(filepath, '\', '.', 'g')
    let filepath = substitute(filepath, ' ', '', 'g')
    let filepath = substitute(filepath, '.*test.', '', '')
    if a:type == 1
        let filepath = substitute(filepath, '.[A-Za-z]*.java', '', 'g')
    elseif a:type == 2
        let filepath = substitute(filepath, 'Tests.java', '', '')
    elseif a:type == 3
        let filepath = substitute(filepath, '.*\.\([A-Za-z]*\).java', '\1', 'g')
    elseif a:type == 4
        let filepath = substitute(filepath, 'Tests.java', '', '')
        let filepath = substitute(filepath, '.*\.\([A-Za-z]*\).java', '\1', 'g')
    elseif a:type == 5
        let filepath = substitute(filepath, 'Tests.java', '', '')
        let filepath = substitute(filepath, '.*\.\([A-Za-z]*\).java', '\1', 'g')
        let filepath = substitute(filepath, '.', '\l&', '')
    endif

    return filepath
endfunction

" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet method      // {{{ <{method}><CR>/**<CR> * <{}><CR> */<CR>public <{return}> <{method}>() {<CR><{}>}<CR>// }}}<CR><{}>
    DefineSnippet jps         private static final <{string}> <{}> = "<{}>";<CR><{}>
    DefineSnippet jtc         try {<CR><{}><CR>} catch (<{}> e) {<CR><{}><CR>} finally {<CR><{}><CR>}<CR><{}>
    DefineSnippet jlog        /** Logger for this class and subclasses. */<CR><CR>protected final Log log = LogFactory.getLog(getClass());<CR><{}>
    DefineSnippet jpv         private <{string}> <{}>;<CR><CR><{}>
    DefineSnippet bean        // {{{ set<{fieldName:toupper(@z)}><CR><ESC>Vc/**<CR>Setter for <{fieldName}>.<CR>@param new<{fieldName:toupper(@z)}> new value for <{fieldName}><CR>*/<CR>public void set<{fieldName:toupper(@z)}>(<{String}> new<{fieldName:toupper(@z)}>) {<CR><{fieldName}> = new<{fieldName:toupper(@z)}>;<CR>}<CR>// }}}<CR><ESC>Vc<CR>// {{{ get<{fieldName:toupper(@z)}><CR><ESC>Vc/**<CR>Getter for <{fieldName}>.<CR>@return <{fieldName}><CR>*/<CR>public <{String}> get<{fieldName:toupper(@z)}>() {<CR>return <{fieldName}>;<CR>}<CR>// }}}<CR><ESC>Vc<{}>
    DefineSnippet jwh         while (<{}>) { // <{}><CR><CR><{}><CR><CR>}<CR><{}>
    DefineSnippet sout        System.out.println("<{}>");<{}>
    DefineSnippet jtest       package <{j:cca:java:test_filename(1)}><CR><CR>import junit.framework.TestCase;<CR>import <{j:cca:java:test_filename(2)}>;<CR><CR>/**<CR><{j:cca:java:test_filename(3)}><CR><CR>@author <{}><CR>@since <{}><CR>/<CR>public class <{j:cca:java:test_filename(3)}> extends TestCase {<CR><CR>private <{j:cca:java:test_filename(4)}> <{j:cca:java:test_filename(5)}>;<CR><CR>public <{j:cca:java:test_filename(4)}> get<{j:cca:java:test_filename(4)}>() { return this.<{j:cca:java:test_filename(5)}>; }<CR>public void set<{j:cca:java:test_filename(4)}>(<{j:cca:java:test_filename(4)}> <{j:cca:java:test_filename(5)}>) { this.<{j:cca:java:test_filename(5)}> = <{j:cca:java:test_filename(5)}>; }<CR><CR>public void test<{}>() {<CR><{}><CR>}<CR>}<CR><{}>
    DefineSnippet jif         if (<{}>) { // <{}><CR><{}><CR>}<CR><{}>
    DefineSnippet jelse       if (<{}>) { // <{}><CR><CR><{}><CR><CR>} else { // <{}><CR><{}><CR>}<CR><{}>
    DefineSnippet jpm         /**<CR> * <{}><CR> *<CR> * @param <{}> <{}><CR> * <{}> <{}><CR> */<CR>private <{void}> <{}>(<{String}> <{}>) {<CR><CR><{}><CR><CR>}<CR><{}>
    DefineSnippet main        public main static void main(String[] ars) {<CR><{"System.exit(0)"}>;<CR>}<CR><{}>
    DefineSnippet jpum        /**<CR> * <{}><CR> *<CR> * @param <{}> <{}><CR> *<{}> <{}><CR> */<CR>public <{void}> <{}>(<{String}> <{}>) {<CR><CR><{}><CR><CR>}<CR><{}>
    DefineSnippet jcout       <c:out value="${<{}>}" /><{}>
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

    let b:{cca_filetype_ext_var} = 'java'
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}\>", "cmd"  : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    let b:{ctk_filetype_ext_var} = 'java'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
