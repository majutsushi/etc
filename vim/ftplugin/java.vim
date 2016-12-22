" Author:  Jan Larres <jan@majutsushi.net>
" Website: http://majutsushi.net
" License: MIT/X11

setlocal foldmethod=syntax

let g:java_highlight_java_lang_ids = 1
let g:java_comment_strings = 1

noremap <buffer> ]] ]m
noremap <buffer> ][ ]M
noremap <buffer> [[ [m
noremap <buffer> [] [M

" Don't interfere with eclim signs
let b:quickfixsigns_ignore = ['qfl', 'loc']

let g:EclimJavaSearchSingleResult = 'split'

nnoremap <silent> <buffer> <leader>i  :JavaImport<cr>
nnoremap <silent> <buffer> <leader>ds :JavaDocSearch -x declarations<cr>
nnoremap <silent> <buffer> <leader>dd :JavaDocPreview<cr>
nnoremap <silent> <buffer> <CR>       :JavaSearchContext<cr>
nnoremap <silent> <buffer> g<CR>      :call <SID>search_open_action('tabnew')<CR>
nnoremap <silent> <buffer> <C-CR>     :call <SID>search_open_action('edit')<CR>

" Wrap in exists() to avoid replacement while it is being executed
if !exists('*<SID>search_open_action')
    function! s:search_open_action(open_action) abort
        let oldaction = g:EclimJavaSearchSingleResult
        let g:EclimJavaSearchSingleResult = a:open_action
        JavaSearchContext
        let g:EclimJavaSearchSingleResult = oldaction
    endfunction
endif
