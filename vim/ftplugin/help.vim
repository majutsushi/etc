if &buftype == 'help'
    " Set custom statusline
    let b:stl  = "#[Branch] HELP "
    let b:stl .= "#[FileName] %<%t "
    let b:stl .= "#[FunctionName] "
    let b:stl .= "%="
    let b:stl .= "%(#[Warning]%{get(g:, 'zoomwin_zoomed', 0) ? 'Z' : ''}%)"
    let b:stl .= "#[LinePercent] %p%%"

    nnoremap <buffer> <Space> <C-]> " Space selects subject
    nnoremap <buffer> <BS>    <C-T> " Backspace to go back
    nnoremap <buffer> q       :q<CR>
endif
