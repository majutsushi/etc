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

nnoremap <silent> <buffer> <leader>i  :JavaImport<cr>
nnoremap <silent> <buffer> <leader>ds :JavaDocSearch -x declarations<cr>
nnoremap <silent> <buffer> <leader>dd :JavaDocPreview<cr>
nnoremap <silent> <buffer> <cr>       :JavaSearchContext<cr>
