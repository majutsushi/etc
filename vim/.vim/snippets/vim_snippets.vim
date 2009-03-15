" ==========================================================
" File Name:    vim_snippets.vim
" Author:       StarWing
" Version:      0.1
" Last Change:  2009-01-30 10:14:25
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet ds        DefineSnippet <{}><TAB><TAB><TAB><{}>
    DefineSnippet blk: {{{<C-R>=foldlevel(line('.'))+1<CR><CR><{}><CR>}}}<C-R>=foldlevel(line('.'))+1<CR>
    DefineSnippet lc        <ESC>0d$a" <C-R>=repeat('=', 58)<CR><CR>
    DefineSnippet le        <C-R>=repeat('=', 58)<CR><CR><bs><bs>
    DefineSnippet fh        " <C-R>=repeat('=', 58)<CR><CR>File Name:    <C-R>=expand('%:t')<CR><CR>Author:       <{}><CR>Version:      <{0.1}><CR>Last Change:  <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR><CR><C-R>=repeat('=', 58)<CR>
    DefineSnippet cpo       let s:cpo_save = &cpo<CR>set cpo&vim<CR><CR><{}><CR><CR>let &cpo = s:cpo_save<CR>unlet s:cpo_save
    DefineSnippet func      <esc>0d$a" <{function_name:}> {{{<C-R>=foldlevel(line('.'))<CR><CR><bs><bs><CR>function! <{function_name:}>(<{}>)<CR><{}><CR>endfunction<CR><CR>" }}}<C-R>=foldlevel(line('.'))<CR>
    DefineSnippet if        if <{}><CR><{}><CR>endif<CR><{}>
    DefineSnippet while     while <{}><CR><{}><CR>endwhile<CR><{}>
    DefineSnippet for       for <{}> in <{}><CR><CR>endfor<CR><{}>
    DefineSnippet try       try<CR><{}><CR>catch <{}><CR><{}><CR>endtry<CR><{}>
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

    let b:{cca_filetype_ext_var} = 'vim'
    let b:{cca_locale_tag_var} = { "start": "<{", "end"  : "}>", "cmd"  : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    let b:{ctk_filetype_ext_var} = 'vim'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
