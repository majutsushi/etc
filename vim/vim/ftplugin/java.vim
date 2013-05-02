" Author:  Jan Larres <jan@majutsushi.net>
" Website: http://majutsushi.net
" License: MIT/X11

setlocal foldmethod=syntax

noremap <buffer> ]] ]m
noremap <buffer> ][ ]M
noremap <buffer> [[ [m
noremap <buffer> [] [M

" Don't interfere with eclim signs
let b:quickfixsigns_ignore = ['qfl', 'loc']

imap <silent> <buffer> <C-Space> <C-x><C-u>
inoremap <expr> <C-x><C-u> pumvisible() ? '<C-x><C-u>' : '<C-x><C-u><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

nnoremap <silent> <buffer> <leader>i  :JavaImport<cr>
nnoremap <silent> <buffer> <leader>ds :JavaDocSearch -x declarations<cr>
nnoremap <silent> <buffer> <leader>dd :JavaDocPreview<cr>
nnoremap <silent> <buffer> <cr>       :JavaSearchContext<cr>
