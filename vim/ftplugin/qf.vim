" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net

let b:stl = "#[FileName]%t #[FileType]%{exists('w:quickfix_title') ? ' ' . w:quickfix_title : ''} #[FunctionName]%=#[LineNumber] %04(%l%)#[LineColumn]:%03(%c%V%) #[LinePercent] %p%%"

nnoremap <buffer> <silent> p <CR><C-W>p

setlocal nocursorline

" Folding of (gnu)make output.
setlocal foldmethod=marker
setlocal foldmarker=Entering\ directory,Leaving\ directory
nnoremap <buffer> <silent> zq zM:g/error:/normal zv<CR>
nnoremap <buffer> <silent> zw zq:g/warning:/normal zv<CR>
nnoremap <buffer> <silent> q :call qftoggle#toggle()<CR>

" normal zq
