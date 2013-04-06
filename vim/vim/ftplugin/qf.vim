" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net

let b:stl = "#[FileName][Quickfix List]#[FunctionName]"

nnoremap <buffer> <silent> p <CR><C-W>p

" Folding of (gnu)make output.
setlocal foldmethod=marker
setlocal foldmarker=Entering\ directory,Leaving\ directory
nnoremap <buffer> <silent> zq zM:g/error:/normal zv<CR>
nnoremap <buffer> <silent> zw zq:g/warning:/normal zv<CR>
nnoremap <buffer> <silent> q :call QuickfixToggle()<CR>

" normal zq
