" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-03-11 17:04:35 +1300 NZDT
" Last changed : 2012-03-11 17:04:35 +1300 NZDT

if &buftype == 'help'
    " Set custom statusline
    let b:stl = "#[Branch] HELP #[FileName] %<%t #[FunctionName] %=#[LinePercentS]#[LinePercent] %p%%"

    nnoremap <buffer> <Space> <C-]> " Space selects subject
    nnoremap <buffer> <BS>    <C-T> " Backspace to go back
    nnoremap <buffer> q       :q<CR>
endif
