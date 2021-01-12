highlight clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="desert"

hi Normal	guifg=#ffffff guibg=#333333

" highlight groups
hi Cursor	guibg=#f0e68c guifg=#708090
"hi CursorIM
hi Directory    guifg=Cyan

hi DiffAdd    guibg=#307030
hi DiffChange guibg=#2b5b77
hi DiffDelete guibg=#723030 guifg=#723030 gui=bold cterm=bold
hi DiffText   guibg=#6c90a6               gui=bold cterm=bold

"hi ErrorMsg
hi VertSplit	guibg=#c2bfa5 guifg=#7f7f7f gui=none cterm=none
hi Folded	guibg=#333333 guifg=#ffd700
hi FoldColumn	guibg=#333333 guifg=#d2b48c
hi IncSearch	guifg=#708090 guibg=#f0e68c gui=none cterm=none
hi LineNr	guifg=#999999 guibg=#333333
hi CursorLine                 guibg=#4d4d4d gui=none cterm=none
hi CursorLineNr	guifg=#aaaaaa guibg=#4d4d4d gui=none cterm=none
hi ModeMsg	guifg=#daa520               gui=bold cterm=bold
hi MoreMsg	guifg=#2e8b57
hi NonText	guifg=#add8e6 guibg=#4d4d4d gui=bold cterm=bold
hi Question	guifg=#00ff7f               gui=bold cterm=bold
hi Search	guibg=#cd853f guifg=#f5deb3
hi SpecialKey	guifg=#666666
hi QuickFixLine	guibg=#408f07 guifg=#ffffff

hi SpellBad	gui=undercurl guisp=Red     cterm=underline
hi SpellCap	gui=undercurl guisp=#fa8072 cterm=underline
hi SpellRare	gui=undercurl guisp=Magenta cterm=underline
hi SpellLocal	gui=undercurl guisp=Cyan    cterm=underline


let g:desert_statuscolours = {
    \ 'NONE'         : [['#c2bfa5', '#000000', 'none'], ['#1c1c1c', '#7f7f7f', 'none']],
    \ 'ModeNormal'   : [['#4e9a06', '#ffffff', 'bold'], [                            ]],
    \ 'ModeInsert'   : [['#cc0000', '#ffffff', 'bold'], [                            ]],
    \ 'FilePath'     : [['#c2bfa5', '#000000', 'none'], ['#1c1c1c', '#808080', 'none']],
    \ 'FileName'     : [['#c2bfa5', '#000000', 'bold'], ['#1c1c1c', '#808080', 'none']],
    \ 'ModFlag'      : [['#c2bfa5', '#cc0000', 'bold'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'BufFlag'      : [['#c2bfa5', '#000000', 'none'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'FileType'     : [['#585858', '#bcbcbc', 'none'], ['#080808', '#4e4e4e', 'none']],
    \ 'Branch'       : [['#585858', '#bcbcbc', 'none'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'BranchS'      : [['#585858', '#949494', 'none'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'FunctionName' : [['#1c1c1c', '#9e9e9e', 'none'], ['#080808', '#4e4e4e', 'none']],
    \ 'FileFormat'   : [['#1c1c1c', '#bcbcbc', 'bold'], ['#080808', '#4e4e4e', 'none']],
    \ 'FileEncoding' : [['#1c1c1c', '#bcbcbc', 'bold'], ['#080808', '#4e4e4e', 'none']],
    \ 'Separator'    : [['#1c1c1c', '#6c6c6c', 'none'], ['#080808', '#4e4e4e', 'none']],
    \ 'ExpandTab'    : [['#585858', '#eeeeee', 'bold'], ['#1c1c1c', '#808080', 'none']],
    \ 'LineColumn'   : [['#585858', '#bcbcbc', 'none'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'LinePercent'  : [['#c2bfa5', '#303030', 'bold'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'Error'        : [['#cc0000', '#ffffff', 'bold'], ['#1c1c1c', '#808080', 'none']],
    \ 'Warning'      : [['#585858', '#ff5f00', 'bold'], ['#1c1c1c', '#4e4e4e', 'none']],
    \ 'Ale'          : [['#c2bfa5', '#af0000', 'bold'], ['#1c1c1c', '#808080', 'none']],
\ }


hi Title	guifg=#cd5c5c               gui=bold cterm=bold
hi Visual	guifg=#f0e68c guibg=#6b8e23 gui=none cterm=none
"hi VisualNOS
hi WarningMsg	guifg=#fa8072
"hi WildMenu
"hi Menu
"hi Scrollbar
"hi Tooltip

hi SignColumn	guibg=#333333
hi clear ColorColumn
hi CursorLine	guibg=#4d4d4d
hi link ColorColumn CursorLine

" syntax highlighting groups
hi Comment	guifg=#87d7d7
hi Constant	guifg=#ffa0a0
hi Identifier	guifg=#98fb98 gui=none cterm=none
hi Statement	guifg=#f0e68c gui=bold cterm=bold
hi PreProc	guifg=#cd5c5c
hi Type		guifg=#bdb76b gui=bold cterm=bold
hi Special	guifg=#ffdead
"hi Underlined
"hi Ignore	guifg=bg
hi Ignore	guifg=#666666 gui=none cterm=none
hi Error	guifg=#ffffff guibg=#ff0000 gui=none cterm=none
hi Todo		guifg=#ff4500 guibg=#eeee00

hi TabLine	cterm=underline guifg=#333333 guibg=#a9a9a9 gui=none
hi TabLineSel	cterm=bold gui=bold
hi TabLineFill	cterm=none gui=none guifg=#b3b3b3 guibg=#4d4d4d

hi Pmenu	guibg=#1c1c1c guifg=#cccccc gui=none
hi PmenuSel	guifg=#f0e68c guibg=#6b8e23 gui=none
hi PmenuSbar	guibg=#1c1c1c guifg=#ffffff gui=none
hi PmenuThumb	guibg=#ffd700 guifg=#ffffff gui=none

hi User1	cterm=bold,reverse guibg=#c2bfa5 guifg=#000000 gui=bold
hi User2	cterm=bold,reverse guibg=#c2bfa5 guifg=#990f0f gui=bold
hi User3	cterm=bold,reverse guibg=#c2bfa5 guifg=#666666 gui=none

hi User4	cterm=underline guibg=#c2bfa5 guifg=#000000
hi User5	cterm=bold guibg=#c2bfa5 guifg=#990f0f gui=bold
hi User6	cterm=bold guibg=#c2bfa5 guifg=#000000 gui=bold
"hi User6	cterm=bold guibg=#a9a9a9 guifg=#cd5c5c
"hi User7	cterm=bold guifg=#cd5c5c

hi CurWord	guibg=#555555

" GitGutter
highlight GitGutterAdd          gui=bold guifg=#11ee11
highlight GitGutterDelete       gui=bold guifg=#ee1111
highlight GitGutterChange       gui=bold guifg=#eeee11
highlight GitGutterChangeDelete gui=bold guifg=#eeee11

" Tagbar
highlight link TagbarHighlight Cursor
highlight TagbarSignature guifg=yellowgreen
highlight TagbarVisibilityPublic guifg=#11ee11
highlight TagbarVisibilityProtected guifg=SkyBlue
highlight TagbarVisibilityPrivate guifg=#ee1111

"vim: sw=4 noexpandtab
