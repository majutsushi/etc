" Vim color file
" Maintainer:	Hans Fugal <hans@fugal.net>
" Last Change:	$Date: 2004/06/13 19:30:30 $
" Last Change:	$Date: 2004/06/13 19:30:30 $
" URL:		http://hans.fugal.net/vim/colors/desert.vim
" Version:	$Id: desert.vim,v 1.1 2004/06/13 19:30:30 vimboss Exp $

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

set background=dark
highlight clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="desert"

hi Normal	guifg=#ffffff guibg=#333333

" highlight groups
hi Cursor	guibg=#f0e68c guifg=#708090
"hi CursorIM
"hi Directory

hi DiffAdd    guibg=#307030
hi DiffChange guibg=#2b5b77
hi DiffDelete guibg=#723030 guifg=#723030
hi DiffText   guibg=#6c90a6
" hi DiffChange guibg=#939133
" hi DiffDelete guibg=#723030 guifg=#723030
" hi DiffText   guibg=#d0be25

"hi ErrorMsg
hi VertSplit	guibg=#c2bfa5 guifg=#7f7f7f gui=none
"hi VertSplit	guibg=#1c1c1c guifg=#7f7f7f gui=none
"hi Folded	guibg=#4d4d4d guifg=#ffd700
hi Folded	guibg=#333333 guifg=#ffd700
hi FoldColumn	guibg=#333333 guifg=#d2b48c
hi IncSearch	guifg=#708090 guibg=#f0e68c
"hi LineNr
hi ModeMsg	guifg=#daa520
hi MoreMsg	guifg=#2e8b57
hi NonText	guifg=#add8e6 guibg=#4d4d4d
hi Question	guifg=#00ff7f
hi Search	guibg=#cd853f guifg=#f5deb3
" hi SpecialKey	guifg=#9acd32
hi SpecialKey	guifg=#666666

hi StatusLine	guibg=#c2bfa5 guifg=#000000 gui=none
"hi StatusLineNC	guibg=#c2bfa5 guifg=#7f7f7f gui=none
hi StatusLineNC	guibg=#1c1c1c guifg=#7f7f7f gui=none

hi Title	guifg=#cd5c5c
hi Visual	gui=none guifg=#f0e68c guibg=#6b8e23
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
hi Comment	guifg=#87ceeb
hi Constant	guifg=#ffa0a0
hi Identifier	guifg=#98fb98
hi Statement	guifg=#f0e68c
hi PreProc	guifg=#cd5c5c
hi Type		guifg=#bdb76b
hi Special	guifg=#ffdead
"hi Underlined
"hi Ignore	guifg=bg
hi Ignore	guifg=#666666
"hi Error
hi Todo		guifg=#ff4500 guibg=#eeee00

" color terminal definitions
hi SpecialKey	ctermfg=darkgreen
hi NonText	cterm=bold ctermfg=darkblue
hi Directory	ctermfg=darkcyan
hi ErrorMsg	cterm=bold ctermfg=7 ctermbg=1
hi IncSearch	cterm=NONE ctermfg=yellow ctermbg=green
hi Search	cterm=NONE ctermfg=grey ctermbg=blue
hi MoreMsg	ctermfg=darkgreen
hi ModeMsg	cterm=NONE ctermfg=brown
hi LineNr	ctermfg=3
hi Question	ctermfg=green
hi StatusLine	cterm=bold,reverse
hi StatusLineNC	cterm=reverse
hi VertSplit	cterm=reverse
hi Title	ctermfg=5
hi Visual	cterm=reverse
hi VisualNOS	cterm=bold,underline
hi WarningMsg	ctermfg=1
hi WildMenu	ctermfg=0 ctermbg=3
hi Folded	ctermfg=darkgrey ctermbg=NONE
hi FoldColumn	ctermfg=darkgrey ctermbg=NONE
hi DiffAdd	ctermbg=4
hi DiffChange	ctermbg=5
hi DiffDelete	cterm=bold ctermfg=4 ctermbg=6
hi DiffText	cterm=bold ctermbg=1
hi Comment	ctermfg=darkcyan
hi Constant	ctermfg=brown
hi Special	ctermfg=5
hi Identifier	ctermfg=6
hi Statement	ctermfg=3
hi PreProc	ctermfg=5
hi Type		ctermfg=2
hi Underlined	cterm=underline ctermfg=5
hi Ignore	cterm=bold ctermfg=7
hi Ignore	ctermfg=darkgrey
hi Error	cterm=bold ctermfg=7 ctermbg=1

hi TabLine	cterm=underline ctermfg=15 ctermbg=8 guifg=#333333 guibg=#a9a9a9 gui=none
hi TabLineSel	cterm=bold gui=bold
hi TabLineFill	cterm=none gui=none guifg=#b3b3b3 guibg=#4d4d4d

" Ubuntu colours
"hi Pmenu	guibg=#000000 guifg=#aea79f gui=none
"hi PmenuSel	guibg=#5e2750 guifg=#f7f6f5
"hi PmenuSbar	guibg=#000000 guifg=#ffffff gui=none
"hi PmenuThumb	guibg=#dd4814 guifg=#ffffff gui=none

hi Pmenu	guibg=#1c1c1c guifg=#cccccc gui=none
hi PmenuSel	guibg=#cd853f guifg=#f7f6f5 gui=none
hi PmenuSbar	guibg=#1c1c1c guifg=#ffffff gui=none
hi PmenuThumb	guibg=#daa520 guifg=#ffffff gui=none

"hi Pmenu	guibg=#c2bfa5 guifg=#000000 gui=none
"hi PmenuSel	guibg=#4e9a06 guifg=#ffffff gui=none
"hi PmenuSbar	guibg=#c2bfa5 guifg=#ffffff gui=none
"hi PmenuThumb	guibg=#daa520 guifg=#ffffff gui=none

hi User1	cterm=bold,reverse guibg=#c2bfa5 guifg=#000000 gui=bold
hi User2	cterm=bold,reverse guibg=#c2bfa5 guifg=#990f0f gui=bold
hi User3	cterm=bold,reverse guibg=#c2bfa5 guifg=#666666 gui=none

hi User4	cterm=underline ctermfg=15 ctermbg=8 guibg=#c2bfa5 guifg=#000000
hi User5	cterm=bold guibg=#c2bfa5 guifg=#990f0f gui=bold
hi User6	cterm=bold ctermfg=15 ctermbg=8 guibg=#c2bfa5 guifg=#000000 gui=bold
"hi User6	cterm=bold guibg=#a9a9a9 guifg=#cd5c5c
"hi User7	cterm=bold guifg=#cd5c5c

"vim: sw=4 noexpandtab
