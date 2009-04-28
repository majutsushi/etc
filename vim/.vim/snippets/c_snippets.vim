" ==========================================================
" File Name:    c_snippets.vim
" Author:       StarWing
" Version:      0.1
" Last Change:  2009-01-30 19:59:17
" ==========================================================
" cca:c:arglist {{{2

function! cca:c:arglist()
    return repeat(', '.cca:make_tag(), cca:count(@z, '%[^%]'))
endfunction

" }}}2
" cca:c:get_file_name {{{2

function! cca:c:get_file_name(upper)
    let fname = expand('%:t')
    if a:upper == 1
        let fname = substitute(fname, '\.', '_', 'g')
        return '__'.toupper(fname).'__'
    else
        return empty(fname) ? cca:make_tag() : fname
    endif
endfunction

" }}}2
" s:set_compiler_info {{{2

function! s:set_compiler_info()
    SetCompilerInfo gcc         title="GNU Compiler Collection" hotkey="c:<m-c>" cc_cmd="gcc $input $flags -o $output" input="" output="" debug_cmd="gdb -q $output" run_cmd="" flags="-Wall" debug_flags="-g"
    SetCompilerInfo gcc\ asm    title="GNU Compiler Collection to ASM" hotkey="c:<m-C>" cc_cmd="gcc -S $input $flags -o $output" input="" output="%:t:r.asm" run_cmd=":sp $output" flags="-Wall"
    SetCompilerInfo vc6         title="Visual C++ 6.0" cc_cmd="cl $input $flags -o $output" debug_cmd="gdb -q $output" input="" output="" run_cmd="" flags="-W4" debug_flags=""
endfunction

" }}}2
" s:define_snippets {{{2

function! s:define_snippets()
    DefineSnippet df            #define <{}>
    DefineSnippet ic            #include "<{}>"
    DefineSnippet ii            #include <<{}>>
    DefineSnippet ud            #undef <{}>
    DefineSnippet fc            #if 0<CR><{}><CR>#endif<CR>
    DefineSnippet ff            #ifndef <C-R>=cca:c:get_file_name(1)<CR><CR>#define <C-R>=cca:c:get_file_name(1)<CR><CR><CR><CR><{}><CR><CR><CR>#endif /* <C-R>=cca:c:get_file_name(1)<CR> */
    DefineSnippet co            /* <{}> */
    DefineSnippet cc            /**< <{}> */
    DefineSnippet cr            <C-R>=repeat(' ', 60-strlen(getline('.')))<cr>/* <{}> */
    DefineSnippet cl            /<C-R>=repeat('*', 58)<CR>/
    DefineSnippet bc            /<C-R>=repeat('*', 59)<CR><CR><CR><BS><C-R>=repeat('*', 57)<CR>/
    DefineSnippet fh            /<C-R>=repeat('*', 59)<CR><CR>File Name:   <C-R>=cca:c:get_file_name(0)<CR><CR>Author:      <{}><CR>Version:     <{0.1:}><CR>Last Change: <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR><CR><BS><C-R>=repeat('*', 57)<CR>/<CR><{}>
    DefineSnippet main          int main(void)<CR>{<CR><{}><CR>return 0;<C-D><CR>}
    DefineSnippet main2         int main(int argc, char *argv[])<CR>{<CR><{}><CR>return 0;<C-D><CR>}
    DefineSnippet WinMain       int CALLBACK WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,<CR><C-R>=repeat(' ',13)<CR>LPSTR lpszCmdLine, int nCmdShow)<CR>{<CR><{MessageBox(NULL, "Hello World!", "My First Win-App", MB_OK);}><CR>return 0;<C-D><CR>}

    DefineSnippet {             {<CR><{}><CR>}<CR><{}>
    DefineSnippet if            if (<{}>)<CR><{}>
    DefineSnippet else          else<CR><{}>
    DefineSnippet while         while (<{}>)<CR><{}>
    DefineSnippet do            do<CR>{<CR><{}><CR>}<CR>while (<{}>);<CR><{}>
    DefineSnippet for           for (<{int }><{i}> = <{0}>; <{i}> <{<}> <{len}>; <{i}><{<:@z=~'<'?'++':'--'}>)<CR><{}>
    DefineSnippet case          case <{}>:<CR><{}><CR>break;<C-D><CR><{}><CR>
    DefineSnippet switch        switch (<{}>)<CR>{<CR><C-D>case <{}>:<CR><{}><CR><BS>break;<CR><{}><CR>default:<C-D><CR><{}><CR>}<CR><{}>
    DefineSnippet struct        struct <{}><CR>{<CR><{}><CR>} <{}>;<CR><{}>
    DefineSnippet ts            typedef struct <{struct_name}>_tag<CR>{<CR><{}><CR>} <{struct_name}><{}>;<CR><{}>

    DefineSnippet printf        printf("<{%s:}><{\n}>"<{%s:cca:c:arglist()}>)<{}>
    DefineSnippet scanf         scanf("<{%s:}>"<{%s:cca:c:arglist()}>)<{}>
    DefineSnippet malloc        (<{int}>*)malloc(<{len}> * sizeof(<{int}>))
    DefineSnippet calloc        (<{int}>*)calloc(<{count}>, sizeof(<{int}>))
endfunction

" }}}2

if exists('loaded_cca')
    filetype indent on
    let b:{cca_filetype_ext_var} = 'c'
    let b:{cca_locale_tag_var} = {
            \ "start": "<{",
            \ "end"  : "}>",
            \ "cmd"  : ":"}
    call s:define_snippets()
    unlet b:{cca_locale_tag_var}
else
    delfunc cca:c:arglist
    delfunc cca:c:get_file_name
endif

if exists('loaded_ctk')
    let b:{ctk_filetype_ext_var} = 'c'
    call s:set_compiler_info()
endif

delfunc s:set_compiler_info
delfunc s:define_snippets
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
