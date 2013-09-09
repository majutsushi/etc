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

hi Normal	guifg=White guibg=grey20

" highlight groups
hi Cursor	guibg=khaki guifg=slategrey
"hi CursorIM
"hi Directory

hi DiffAdd    guibg=#307030
hi DiffChange guibg=#723030
hi DiffDelete guibg=#555555 guifg=#555555
hi DiffText   guibg=#c44545
" hi DiffChange guibg=#939133
" hi DiffDelete guibg=#723030 guifg=#723030
" hi DiffText   guibg=#d0be25

"hi ErrorMsg
hi VertSplit	guibg=#c2bfa5 guifg=grey50 gui=none
"hi VertSplit	guibg=#1c1c1c guifg=grey50 gui=none
"hi Folded	guibg=grey30 guifg=gold
hi Folded	guibg=grey20 guifg=gold
hi FoldColumn	guibg=grey20 guifg=tan
hi IncSearch	guifg=slategrey guibg=khaki
"hi LineNr
hi ModeMsg	guifg=goldenrod
hi MoreMsg	guifg=SeaGreen
hi NonText	guifg=LightBlue guibg=grey30
hi Question	guifg=springgreen
hi Search	guibg=peru guifg=wheat
" hi SpecialKey	guifg=yellowgreen
hi SpecialKey	guifg=grey40

hi StatusLine	guibg=#c2bfa5 guifg=black gui=none
"hi StatusLineNC	guibg=#c2bfa5 guifg=grey50 gui=none
hi StatusLineNC	guibg=#1c1c1c guifg=grey50 gui=none

hi Title	guifg=indianred
hi Visual	gui=none guifg=khaki guibg=olivedrab
"hi VisualNOS
hi WarningMsg	guifg=salmon
"hi WildMenu
"hi Menu
"hi Scrollbar
"hi Tooltip

hi SignColumn	guibg=grey20
hi clear ColorColumn
hi CursorLine	guibg=Grey30
hi link ColorColumn CursorLine

" syntax highlighting groups
hi Comment	guifg=SkyBlue
hi Constant	guifg=#ffa0a0
hi Identifier	guifg=palegreen
hi Statement	guifg=khaki
hi PreProc	guifg=indianred
hi Type		guifg=darkkhaki
hi Special	guifg=navajowhite
"hi Underlined
"hi Ignore	guifg=bg
hi Ignore	guifg=grey40
"hi Error
hi Todo		guifg=orangered guibg=yellow2

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
hi StatusLineNC cterm=reverse
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

hi TabLine	cterm=underline ctermfg=15 ctermbg=8 guifg=grey20 guibg=DarkGrey gui=none
hi TabLineSel	cterm=bold gui=bold
hi TabLineFill	cterm=none gui=none guifg=grey70 guibg=grey30

" Ubuntu colours
"hi Pmenu	guibg=black guifg=#aea79f gui=none
"hi PmenuSel	guibg=#5e2750 guifg=#f7f6f5
"hi PmenuSbar	guibg=black guifg=white gui=none
"hi PmenuThumb	guibg=#dd4814 guifg=white gui=none

hi Pmenu	guibg=#1c1c1c guifg=grey80 gui=none
hi PmenuSel	guibg=peru guifg=#f7f6f5 gui=none
hi PmenuSbar	guibg=#1c1c1c guifg=white gui=none
hi PmenuThumb	guibg=goldenrod guifg=white gui=none

"hi Pmenu	guibg=#c2bfa5 guifg=black gui=none
"hi PmenuSel	guibg=#4e9a06 guifg=white gui=none
"hi PmenuSbar	guibg=#c2bfa5 guifg=white gui=none
"hi PmenuThumb	guibg=goldenrod guifg=white gui=none

hi User1	cterm=bold,reverse guibg=#c2bfa5 guifg=black   gui=bold
hi User2	cterm=bold,reverse guibg=#c2bfa5 guifg=#990f0f gui=bold
hi User3	cterm=bold,reverse guibg=#c2bfa5 guifg=grey40  gui=none

hi User4	cterm=underline ctermfg=15 ctermbg=8 guibg=#c2bfa5 guifg=black
hi User5	cterm=bold guibg=#c2bfa5 guifg=#990f0f gui=bold
hi User6	cterm=bold ctermfg=15 ctermbg=8 guibg=#c2bfa5 guifg=black gui=bold
"hi User6	cterm=bold guibg=DarkGrey guifg=indianred
"hi User7	cterm=bold guifg=indianred

"vim: sw=4 noexpandtab
