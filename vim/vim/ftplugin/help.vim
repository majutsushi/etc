" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-03-11 17:04:35 +1300 NZDT
" Last changed : 2012-09-16 03:18:14 +1200 NZST

if &buftype == 'help'
    " Set custom statusline
    let b:stl  = "#[Branch] HELP "
    let b:stl .= "#[FileName] %<%t "
    let b:stl .= "#[FunctionName] "
    let b:stl .= "%="
    let b:stl .= "%(#[Warning]%{g:zoomwin_stl}%)"
    let b:stl .= "#[LinePercent] %p%%"

    nnoremap <buffer> <Space> <C-]> " Space selects subject
    nnoremap <buffer> <BS>    <C-T> " Backspace to go back
    nnoremap <buffer> q       :q<CR>
endif
