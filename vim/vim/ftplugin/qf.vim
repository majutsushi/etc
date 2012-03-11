" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-03-11 17:01:26 +1300 NZDT
" Last changed : 2012-03-11 17:01:26 +1300 NZDT

let b:stl = "#[FileName][Quickfix List]#[FunctionName]"

" Folding of (gnu)make output.
setlocal foldmethod=marker
setlocal foldmarker=Entering\ directory,Leaving\ directory
nnoremap <buffer> <silent> zq zM:g/error:/normal zv<CR>
nnoremap <buffer> <silent> zw zq:g/warning:/normal zv<CR>
nnoremap <buffer> <silent> q :close<CR>

" normal zq
