" desktop.vim -- .desktop file settings
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-07-07 15:36:19 +1200 NZST
" Last changed : 2012-07-07 15:36:19 +1200 NZST

autocmd BufWritePost <buffer> silent !update-desktop-database ~/.local/share/applications
