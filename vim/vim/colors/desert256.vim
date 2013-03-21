" This scheme was created by CSApproxSnapshot
" on Fri, 22 Mar 2013

hi clear
if exists("syntax_on")
    syntax reset
endif

if v:version < 700
    let g:colors_name = expand("<sfile>:t:r")
    command! -nargs=+ CSAHi exe "hi" substitute(substitute(<q-args>, "undercurl", "underline", "g"), "guisp\\S\\+", "", "g")
else
    let g:colors_name = expand("<sfile>:t:r")
    command! -nargs=+ CSAHi exe "hi" <q-args>
endif

function! s:old_kde()
  " Konsole only used its own palette up til KDE 4.2.0
  if executable('kde4-config') && system('kde4-config --kde-version') =~ '^4.[10].'
    return 1
  elseif executable('kde-config') && system('kde-config --version') =~# 'KDE: 3.'
    return 1
  else
    return 0
  endif
endfunction

if 0
elseif has("gui_running") || (&t_Co == 256 && (&term ==# "xterm" || &term =~# "^screen") && exists("g:CSApprox_konsole") && g:CSApprox_konsole) || (&term =~? "^konsole" && s:old_kde())
    CSAHi Normal term=NONE cterm=NONE ctermbg=59 ctermfg=231 gui=NONE guibg=#333333 guifg=#ffffff
    CSAHi StatusLineLineNumberNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineExpandTabNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineBranchNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileFormat term=NONE cterm=bold ctermbg=234 ctermfg=250 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileFormatNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineBranchS term=NONE cterm=NONE ctermbg=240 ctermfg=246 gui=NONE guibg=#585858 guifg=#949494
    CSAHi StatusLineBranchSNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineLinePercent term=NONE cterm=bold ctermbg=187 ctermfg=236 gui=bold guibg=#c2bfa5 guifg=#303030
    CSAHi StatusLineWarningNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineColumn term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi Statement term=bold cterm=bold ctermbg=bg ctermfg=229 gui=bold guibg=bg guifg=#f0e68c
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=174 gui=NONE guibg=bg guifg=#cd5c5c
    CSAHi Type term=underline cterm=bold ctermbg=bg ctermfg=186 gui=bold guibg=bg guifg=#bdb76b
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=147 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#666666
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=226 ctermfg=202 gui=NONE guibg=#eeee00 guifg=#ff4500
    CSAHi StatusLineFileName term=NONE cterm=bold ctermbg=187 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineLinePercentNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileNameNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineNumber term=NONE cterm=bold ctermbg=240 ctermfg=250 gui=bold guibg=#585858 guifg=#bcbcbc
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=102 gui=NONE guibg=bg guifg=#666666
    CSAHi NonText term=bold cterm=bold ctermbg=239 ctermfg=153 gui=bold guibg=#4d4d4d guifg=#add8e6
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=51 gui=NONE guibg=bg guifg=#00ffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=109 ctermfg=229 gui=reverse guibg=#f0e68c guifg=#708090
    CSAHi Search term=reverse cterm=NONE ctermbg=179 ctermfg=224 gui=NONE guibg=#cd853f guifg=#f5deb3
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=72 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=179 gui=bold guibg=bg guifg=#daa520
    CSAHi LineNr term=underline cterm=NONE ctermbg=bg ctermfg=226 gui=NONE guibg=bg guifg=#ffff00
    CSAHi UtlTag term=NONE cterm=NONE ctermbg=bg ctermfg=fg gui=NONE guibg=bg guifg=fg
    CSAHi StatusLineError term=NONE cterm=bold ctermbg=240 ctermfg=208 gui=bold guibg=#585858 guifg=#ff5f00
    CSAHi User1 term=NONE cterm=bold ctermbg=187 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi User2 term=NONE cterm=bold ctermbg=187 ctermfg=124 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User3 term=NONE cterm=NONE ctermbg=187 ctermfg=102 gui=NONE guibg=#c2bfa5 guifg=#666666
    CSAHi User4 term=NONE cterm=NONE ctermbg=187 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi User5 term=NONE cterm=bold ctermbg=187 ctermfg=124 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User6 term=NONE cterm=bold ctermbg=187 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=51 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=234 ctermfg=188 gui=NONE guibg=#1c1c1c guifg=#cccccc
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=179 ctermfg=231 gui=NONE guibg=#cd853f guifg=#f7f6f5
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=234 ctermfg=231 gui=NONE guibg=#1c1c1c guifg=#ffffff
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=179 ctermfg=231 gui=NONE guibg=#daa520 guifg=#ffffff
    CSAHi TabLine term=underline cterm=NONE ctermbg=248 ctermfg=59 gui=NONE guibg=#a9a9a9 guifg=#333333
    CSAHi TabLineSel term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=102 ctermfg=fg gui=reverse guibg=bg guifg=#666666
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=102 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineBranch term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineLineColumnNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi TagbarSignature term=NONE cterm=NONE ctermbg=bg ctermfg=149 gui=NONE guibg=bg guifg=#9acd32
    CSAHi TagbarVisibilityProtected term=NONE cterm=NONE ctermbg=bg ctermfg=153 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi StatusLineWarning term=NONE cterm=bold ctermbg=160 ctermfg=231 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi CursorLineNr term=bold cterm=bold ctermbg=bg ctermfg=226 gui=bold guibg=bg guifg=#ffff00
    CSAHi Question term=NONE cterm=bold ctermbg=bg ctermfg=48 gui=bold guibg=bg guifg=#00ff7f
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=187 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#7f7f7f
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=187 ctermfg=244 gui=NONE guibg=#c2bfa5 guifg=#7f7f7f
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=174 gui=bold guibg=bg guifg=#cd5c5c
    CSAHi Visual term=reverse cterm=NONE ctermbg=107 ctermfg=229 gui=NONE guibg=#6b8e23 guifg=#f0e68c
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=216 gui=NONE guibg=bg guifg=#fa8072
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi StatusLineErrorNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileType term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineFileTypeNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineExpandTab term=NONE cterm=bold ctermbg=240 ctermfg=255 gui=bold guibg=#585858 guifg=#eeeeee
    CSAHi StatusLineFileEncoding term=NONE cterm=bold ctermbg=234 ctermfg=250 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileEncodingNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeNormal term=NONE cterm=bold ctermbg=106 ctermfg=231 gui=bold guibg=#4e9a06 guifg=#ffffff
    CSAHi StatusLineBufFlag term=NONE cterm=NONE ctermbg=187 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineBufFlagNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineSeparator term=NONE cterm=NONE ctermbg=234 ctermfg=242 gui=NONE guibg=#1c1c1c guifg=#6c6c6c
    CSAHi StatusLineSeparatorNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi CursorLine term=underline cterm=NONE ctermbg=102 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineModFlagNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi Cursor term=NONE cterm=NONE ctermbg=229 ctermfg=109 gui=NONE guibg=#f0e68c guifg=#708090
    CSAHi lCursor term=NONE cterm=NONE ctermbg=231 ctermfg=59 gui=NONE guibg=#ffffff guifg=#333333
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=37 ctermfg=fg gui=NONE guibg=#008b8b guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=153 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=217 gui=NONE guibg=bg guifg=#ffa0a0
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=223 gui=NONE guibg=bg guifg=#ffdead
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=157 gui=NONE guibg=bg guifg=#98fb98
    CSAHi StatusLineModFlag term=NONE cterm=bold ctermbg=187 ctermfg=160 gui=bold guibg=#c2bfa5 guifg=#cc0000
    CSAHi StatusLineFunctionName term=NONE cterm=NONE ctermbg=234 ctermfg=247 gui=NONE guibg=#1c1c1c guifg=#9e9e9e
    CSAHi EasyMotionTargetDefault term=NONE cterm=bold ctermbg=bg ctermfg=196 gui=bold guibg=bg guifg=#ff0000
    CSAHi EasyMotionShadeDefault term=NONE cterm=NONE ctermbg=bg ctermfg=243 gui=NONE guibg=bg guifg=#777777
    CSAHi StatusLineFunctionNameNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeInsert term=NONE cterm=bold ctermbg=160 ctermfg=231 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi Folded term=NONE cterm=NONE ctermbg=59 ctermfg=220 gui=NONE guibg=#333333 guifg=#ffd700
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=59 ctermfg=187 gui=NONE guibg=#333333 guifg=#d2b48c
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=19 ctermfg=fg gui=NONE guibg=#00008b guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=127 ctermfg=fg gui=NONE guibg=#8b008b guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=37 ctermfg=21 gui=bold guibg=#008b8b guifg=#0000ff
    CSAHi DiffText term=reverse cterm=bold ctermbg=196 ctermfg=fg gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=59 ctermfg=51 gui=NONE guibg=#333333 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=248 ctermfg=252 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
elseif has("gui_running") || (&t_Co == 256 && (&term ==# "xterm" || &term =~# "^screen") && exists("g:CSApprox_eterm") && g:CSApprox_eterm) || &term =~? "^eterm"
    CSAHi Normal term=NONE cterm=NONE ctermbg=236 ctermfg=255 gui=NONE guibg=#333333 guifg=#ffffff
    CSAHi StatusLineLineNumberNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineExpandTabNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineBranchNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileFormat term=NONE cterm=bold ctermbg=234 ctermfg=250 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileFormatNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineBranchS term=NONE cterm=NONE ctermbg=240 ctermfg=246 gui=NONE guibg=#585858 guifg=#949494
    CSAHi StatusLineBranchSNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineLinePercent term=NONE cterm=bold ctermbg=224 ctermfg=236 gui=bold guibg=#c2bfa5 guifg=#303030
    CSAHi StatusLineWarningNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineColumn term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi Statement term=bold cterm=bold ctermbg=bg ctermfg=229 gui=bold guibg=bg guifg=#f0e68c
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=210 gui=NONE guibg=bg guifg=#cd5c5c
    CSAHi Type term=underline cterm=bold ctermbg=bg ctermfg=187 gui=bold guibg=bg guifg=#bdb76b
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=153 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=241 gui=NONE guibg=bg guifg=#666666
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=255 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=226 ctermfg=208 gui=NONE guibg=#eeee00 guifg=#ff4500
    CSAHi StatusLineFileName term=NONE cterm=bold ctermbg=224 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineLinePercentNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileNameNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineNumber term=NONE cterm=bold ctermbg=240 ctermfg=250 gui=bold guibg=#585858 guifg=#bcbcbc
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=241 gui=NONE guibg=bg guifg=#666666
    CSAHi NonText term=bold cterm=bold ctermbg=239 ctermfg=195 gui=bold guibg=#4d4d4d guifg=#add8e6
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=51 gui=NONE guibg=bg guifg=#00ffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=196 ctermfg=255 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=145 ctermfg=229 gui=reverse guibg=#f0e68c guifg=#708090
    CSAHi Search term=reverse cterm=NONE ctermbg=215 ctermfg=230 gui=NONE guibg=#cd853f guifg=#f5deb3
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=72 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=221 gui=bold guibg=bg guifg=#daa520
    CSAHi LineNr term=underline cterm=NONE ctermbg=bg ctermfg=226 gui=NONE guibg=bg guifg=#ffff00
    CSAHi UtlTag term=NONE cterm=NONE ctermbg=bg ctermfg=fg gui=NONE guibg=bg guifg=fg
    CSAHi StatusLineError term=NONE cterm=bold ctermbg=240 ctermfg=208 gui=bold guibg=#585858 guifg=#ff5f00
    CSAHi User1 term=NONE cterm=bold ctermbg=224 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi User2 term=NONE cterm=bold ctermbg=224 ctermfg=160 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User3 term=NONE cterm=NONE ctermbg=224 ctermfg=241 gui=NONE guibg=#c2bfa5 guifg=#666666
    CSAHi User4 term=NONE cterm=NONE ctermbg=224 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi User5 term=NONE cterm=bold ctermbg=224 ctermfg=160 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User6 term=NONE cterm=bold ctermbg=224 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=51 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=234 ctermfg=252 gui=NONE guibg=#1c1c1c guifg=#cccccc
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=215 ctermfg=255 gui=NONE guibg=#cd853f guifg=#f7f6f5
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=234 ctermfg=255 gui=NONE guibg=#1c1c1c guifg=#ffffff
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=221 ctermfg=255 gui=NONE guibg=#daa520 guifg=#ffffff
    CSAHi TabLine term=underline cterm=NONE ctermbg=248 ctermfg=236 gui=NONE guibg=#a9a9a9 guifg=#333333
    CSAHi TabLineSel term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=241 ctermfg=fg gui=reverse guibg=bg guifg=#666666
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineBranch term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineLineColumnNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi TagbarSignature term=NONE cterm=NONE ctermbg=bg ctermfg=191 gui=NONE guibg=bg guifg=#9acd32
    CSAHi TagbarVisibilityProtected term=NONE cterm=NONE ctermbg=bg ctermfg=159 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi StatusLineWarning term=NONE cterm=bold ctermbg=196 ctermfg=255 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi CursorLineNr term=bold cterm=bold ctermbg=bg ctermfg=226 gui=bold guibg=bg guifg=#ffff00
    CSAHi Question term=NONE cterm=bold ctermbg=bg ctermfg=49 gui=bold guibg=bg guifg=#00ff7f
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=224 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=234 ctermfg=145 gui=NONE guibg=#1c1c1c guifg=#7f7f7f
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=224 ctermfg=145 gui=NONE guibg=#c2bfa5 guifg=#7f7f7f
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=210 gui=bold guibg=bg guifg=#cd5c5c
    CSAHi Visual term=reverse cterm=NONE ctermbg=143 ctermfg=229 gui=NONE guibg=#6b8e23 guifg=#f0e68c
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=217 gui=NONE guibg=bg guifg=#fa8072
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi StatusLineErrorNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileType term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineFileTypeNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineExpandTab term=NONE cterm=bold ctermbg=240 ctermfg=255 gui=bold guibg=#585858 guifg=#eeeeee
    CSAHi StatusLineFileEncoding term=NONE cterm=bold ctermbg=234 ctermfg=250 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileEncodingNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeNormal term=NONE cterm=bold ctermbg=112 ctermfg=255 gui=bold guibg=#4e9a06 guifg=#ffffff
    CSAHi StatusLineBufFlag term=NONE cterm=NONE ctermbg=224 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineBufFlagNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineSeparator term=NONE cterm=NONE ctermbg=234 ctermfg=242 gui=NONE guibg=#1c1c1c guifg=#6c6c6c
    CSAHi StatusLineSeparatorNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi CursorLine term=underline cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineModFlagNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi Cursor term=NONE cterm=NONE ctermbg=229 ctermfg=145 gui=NONE guibg=#f0e68c guifg=#708090
    CSAHi lCursor term=NONE cterm=NONE ctermbg=255 ctermfg=236 gui=NONE guibg=#ffffff guifg=#333333
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=37 ctermfg=fg gui=NONE guibg=#008b8b guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=159 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=224 gui=NONE guibg=bg guifg=#ffa0a0
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=230 gui=NONE guibg=bg guifg=#ffdead
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=194 gui=NONE guibg=bg guifg=#98fb98
    CSAHi StatusLineModFlag term=NONE cterm=bold ctermbg=224 ctermfg=196 gui=bold guibg=#c2bfa5 guifg=#cc0000
    CSAHi StatusLineFunctionName term=NONE cterm=NONE ctermbg=234 ctermfg=247 gui=NONE guibg=#1c1c1c guifg=#9e9e9e
    CSAHi EasyMotionTargetDefault term=NONE cterm=bold ctermbg=bg ctermfg=196 gui=bold guibg=bg guifg=#ff0000
    CSAHi EasyMotionShadeDefault term=NONE cterm=NONE ctermbg=bg ctermfg=243 gui=NONE guibg=bg guifg=#777777
    CSAHi StatusLineFunctionNameNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeInsert term=NONE cterm=bold ctermbg=196 ctermfg=255 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi Folded term=NONE cterm=NONE ctermbg=236 ctermfg=226 gui=NONE guibg=#333333 guifg=#ffd700
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=236 ctermfg=223 gui=NONE guibg=#333333 guifg=#d2b48c
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=19 ctermfg=fg gui=NONE guibg=#00008b guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=127 ctermfg=fg gui=NONE guibg=#8b008b guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=37 ctermfg=21 gui=bold guibg=#008b8b guifg=#0000ff
    CSAHi DiffText term=reverse cterm=bold ctermbg=196 ctermfg=fg gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=236 ctermfg=51 gui=NONE guibg=#333333 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=248 ctermfg=231 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
elseif has("gui_running") || &t_Co == 256
    CSAHi Normal term=NONE cterm=NONE ctermbg=236 ctermfg=231 gui=NONE guibg=#333333 guifg=#ffffff
    CSAHi StatusLineLineNumberNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineExpandTabNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineBranchNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileFormat term=NONE cterm=bold ctermbg=234 ctermfg=250 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileFormatNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineBranchS term=NONE cterm=NONE ctermbg=240 ctermfg=246 gui=NONE guibg=#585858 guifg=#949494
    CSAHi StatusLineBranchSNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineLinePercent term=NONE cterm=bold ctermbg=145 ctermfg=236 gui=bold guibg=#c2bfa5 guifg=#303030
    CSAHi StatusLineWarningNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineColumn term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi Statement term=bold cterm=bold ctermbg=bg ctermfg=222 gui=bold guibg=bg guifg=#f0e68c
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=167 gui=NONE guibg=bg guifg=#cd5c5c
    CSAHi Type term=underline cterm=bold ctermbg=bg ctermfg=143 gui=bold guibg=bg guifg=#bdb76b
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=111 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=241 gui=NONE guibg=bg guifg=#666666
    CSAHi Error term=reverse cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=226 ctermfg=202 gui=NONE guibg=#eeee00 guifg=#ff4500
    CSAHi StatusLineFileName term=NONE cterm=bold ctermbg=145 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineLinePercentNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileNameNC term=NONE cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineNumber term=NONE cterm=bold ctermbg=240 ctermfg=250 gui=bold guibg=#585858 guifg=#bcbcbc
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=241 gui=NONE guibg=bg guifg=#666666
    CSAHi NonText term=bold cterm=bold ctermbg=239 ctermfg=152 gui=bold guibg=#4d4d4d guifg=#add8e6
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=51 gui=NONE guibg=bg guifg=#00ffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=196 ctermfg=231 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=66 ctermfg=222 gui=reverse guibg=#f0e68c guifg=#708090
    CSAHi Search term=reverse cterm=NONE ctermbg=173 ctermfg=223 gui=NONE guibg=#cd853f guifg=#f5deb3
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=29 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=178 gui=bold guibg=bg guifg=#daa520
    CSAHi LineNr term=underline cterm=NONE ctermbg=bg ctermfg=226 gui=NONE guibg=bg guifg=#ffff00
    CSAHi UtlTag term=NONE cterm=NONE ctermbg=bg ctermfg=fg gui=NONE guibg=bg guifg=fg
    CSAHi StatusLineError term=NONE cterm=bold ctermbg=240 ctermfg=202 gui=bold guibg=#585858 guifg=#ff5f00
    CSAHi User1 term=NONE cterm=bold ctermbg=145 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi User2 term=NONE cterm=bold ctermbg=145 ctermfg=88 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User3 term=NONE cterm=NONE ctermbg=145 ctermfg=241 gui=NONE guibg=#c2bfa5 guifg=#666666
    CSAHi User4 term=NONE cterm=NONE ctermbg=145 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi User5 term=NONE cterm=bold ctermbg=145 ctermfg=88 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User6 term=NONE cterm=bold ctermbg=145 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=201 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=51 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=234 ctermfg=252 gui=NONE guibg=#1c1c1c guifg=#cccccc
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=173 ctermfg=231 gui=NONE guibg=#cd853f guifg=#f7f6f5
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=234 ctermfg=231 gui=NONE guibg=#1c1c1c guifg=#ffffff
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=178 ctermfg=231 gui=NONE guibg=#daa520 guifg=#ffffff
    CSAHi TabLine term=underline cterm=NONE ctermbg=248 ctermfg=236 gui=NONE guibg=#a9a9a9 guifg=#333333
    CSAHi TabLineSel term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=241 ctermfg=fg gui=reverse guibg=bg guifg=#666666
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineBranch term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineLineColumnNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi TagbarSignature term=NONE cterm=NONE ctermbg=bg ctermfg=113 gui=NONE guibg=bg guifg=#9acd32
    CSAHi TagbarVisibilityProtected term=NONE cterm=NONE ctermbg=bg ctermfg=116 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi StatusLineWarning term=NONE cterm=bold ctermbg=160 ctermfg=231 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi CursorLineNr term=bold cterm=bold ctermbg=bg ctermfg=226 gui=bold guibg=bg guifg=#ffff00
    CSAHi Question term=NONE cterm=bold ctermbg=bg ctermfg=48 gui=bold guibg=bg guifg=#00ff7f
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=145 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=234 ctermfg=244 gui=NONE guibg=#1c1c1c guifg=#7f7f7f
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=145 ctermfg=244 gui=NONE guibg=#c2bfa5 guifg=#7f7f7f
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=167 gui=bold guibg=bg guifg=#cd5c5c
    CSAHi Visual term=reverse cterm=NONE ctermbg=64 ctermfg=222 gui=NONE guibg=#6b8e23 guifg=#f0e68c
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=209 gui=NONE guibg=bg guifg=#fa8072
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=226 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi StatusLineErrorNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileType term=NONE cterm=NONE ctermbg=240 ctermfg=250 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineFileTypeNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineExpandTab term=NONE cterm=bold ctermbg=240 ctermfg=255 gui=bold guibg=#585858 guifg=#eeeeee
    CSAHi StatusLineFileEncoding term=NONE cterm=bold ctermbg=234 ctermfg=250 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileEncodingNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeNormal term=NONE cterm=bold ctermbg=64 ctermfg=231 gui=bold guibg=#4e9a06 guifg=#ffffff
    CSAHi StatusLineBufFlag term=NONE cterm=NONE ctermbg=145 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineBufFlagNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineSeparator term=NONE cterm=NONE ctermbg=234 ctermfg=242 gui=NONE guibg=#1c1c1c guifg=#6c6c6c
    CSAHi StatusLineSeparatorNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi CursorLine term=underline cterm=NONE ctermbg=241 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineModFlagNC term=NONE cterm=NONE ctermbg=234 ctermfg=239 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi Cursor term=NONE cterm=NONE ctermbg=222 ctermfg=66 gui=NONE guibg=#f0e68c guifg=#708090
    CSAHi lCursor term=NONE cterm=NONE ctermbg=231 ctermfg=236 gui=NONE guibg=#ffffff guifg=#333333
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=30 ctermfg=fg gui=NONE guibg=#008b8b guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=116 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=217 gui=NONE guibg=bg guifg=#ffa0a0
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=223 gui=NONE guibg=bg guifg=#ffdead
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=120 gui=NONE guibg=bg guifg=#98fb98
    CSAHi StatusLineModFlag term=NONE cterm=bold ctermbg=145 ctermfg=160 gui=bold guibg=#c2bfa5 guifg=#cc0000
    CSAHi StatusLineFunctionName term=NONE cterm=NONE ctermbg=234 ctermfg=247 gui=NONE guibg=#1c1c1c guifg=#9e9e9e
    CSAHi EasyMotionTargetDefault term=NONE cterm=bold ctermbg=bg ctermfg=196 gui=bold guibg=bg guifg=#ff0000
    CSAHi EasyMotionShadeDefault term=NONE cterm=NONE ctermbg=bg ctermfg=243 gui=NONE guibg=bg guifg=#777777
    CSAHi StatusLineFunctionNameNC term=NONE cterm=NONE ctermbg=232 ctermfg=239 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeInsert term=NONE cterm=bold ctermbg=160 ctermfg=231 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi Folded term=NONE cterm=NONE ctermbg=236 ctermfg=220 gui=NONE guibg=#333333 guifg=#ffd700
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=236 ctermfg=180 gui=NONE guibg=#333333 guifg=#d2b48c
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=18 ctermfg=fg gui=NONE guibg=#00008b guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=90 ctermfg=fg gui=NONE guibg=#8b008b guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=30 ctermfg=21 gui=bold guibg=#008b8b guifg=#0000ff
    CSAHi DiffText term=reverse cterm=bold ctermbg=196 ctermfg=fg gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=236 ctermfg=51 gui=NONE guibg=#333333 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=248 ctermfg=252 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=196 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=21 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
elseif has("gui_running") || &t_Co == 88
    CSAHi Normal term=NONE cterm=NONE ctermbg=80 ctermfg=79 gui=NONE guibg=#333333 guifg=#ffffff
    CSAHi StatusLineLineNumberNC term=NONE cterm=NONE ctermbg=80 ctermfg=83 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineExpandTabNC term=NONE cterm=NONE ctermbg=80 ctermfg=83 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineBranchNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileFormat term=NONE cterm=bold ctermbg=80 ctermfg=85 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileFormatNC term=NONE cterm=NONE ctermbg=16 ctermfg=81 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineBranchS term=NONE cterm=NONE ctermbg=81 ctermfg=83 gui=NONE guibg=#585858 guifg=#949494
    CSAHi StatusLineBranchSNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineLinePercent term=NONE cterm=bold ctermbg=57 ctermfg=80 gui=bold guibg=#c2bfa5 guifg=#303030
    CSAHi StatusLineWarningNC term=NONE cterm=NONE ctermbg=80 ctermfg=83 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineColumn term=NONE cterm=NONE ctermbg=81 ctermfg=85 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi Statement term=bold cterm=bold ctermbg=bg ctermfg=73 gui=bold guibg=bg guifg=#f0e68c
    CSAHi PreProc term=underline cterm=NONE ctermbg=bg ctermfg=53 gui=NONE guibg=bg guifg=#cd5c5c
    CSAHi Type term=underline cterm=bold ctermbg=bg ctermfg=57 gui=bold guibg=bg guifg=#bdb76b
    CSAHi Underlined term=underline cterm=underline ctermbg=bg ctermfg=39 gui=underline guibg=bg guifg=#80a0ff
    CSAHi Ignore term=NONE cterm=NONE ctermbg=bg ctermfg=81 gui=NONE guibg=bg guifg=#666666
    CSAHi Error term=reverse cterm=NONE ctermbg=64 ctermfg=79 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi Todo term=NONE cterm=NONE ctermbg=76 ctermfg=64 gui=NONE guibg=#eeee00 guifg=#ff4500
    CSAHi StatusLineFileName term=NONE cterm=bold ctermbg=57 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineLinePercentNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileNameNC term=NONE cterm=NONE ctermbg=80 ctermfg=83 gui=NONE guibg=#1c1c1c guifg=#808080
    CSAHi StatusLineLineNumber term=NONE cterm=bold ctermbg=81 ctermfg=85 gui=bold guibg=#585858 guifg=#bcbcbc
    CSAHi SpecialKey term=bold cterm=NONE ctermbg=bg ctermfg=81 gui=NONE guibg=bg guifg=#666666
    CSAHi NonText term=bold cterm=bold ctermbg=81 ctermfg=58 gui=bold guibg=#4d4d4d guifg=#add8e6
    CSAHi Directory term=bold cterm=NONE ctermbg=bg ctermfg=31 gui=NONE guibg=bg guifg=#00ffff
    CSAHi ErrorMsg term=NONE cterm=NONE ctermbg=64 ctermfg=79 gui=NONE guibg=#ff0000 guifg=#ffffff
    CSAHi IncSearch term=reverse cterm=reverse ctermbg=37 ctermfg=73 gui=reverse guibg=#f0e68c guifg=#708090
    CSAHi Search term=reverse cterm=NONE ctermbg=52 ctermfg=74 gui=NONE guibg=#cd853f guifg=#f5deb3
    CSAHi MoreMsg term=bold cterm=bold ctermbg=bg ctermfg=21 gui=bold guibg=bg guifg=#2e8b57
    CSAHi ModeMsg term=bold cterm=bold ctermbg=bg ctermfg=52 gui=bold guibg=bg guifg=#daa520
    CSAHi LineNr term=underline cterm=NONE ctermbg=bg ctermfg=76 gui=NONE guibg=bg guifg=#ffff00
    CSAHi UtlTag term=NONE cterm=NONE ctermbg=bg ctermfg=fg gui=NONE guibg=bg guifg=fg
    CSAHi StatusLineError term=NONE cterm=bold ctermbg=81 ctermfg=68 gui=bold guibg=#585858 guifg=#ff5f00
    CSAHi User1 term=NONE cterm=bold ctermbg=57 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi User2 term=NONE cterm=bold ctermbg=57 ctermfg=32 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User3 term=NONE cterm=NONE ctermbg=57 ctermfg=81 gui=NONE guibg=#c2bfa5 guifg=#666666
    CSAHi User4 term=NONE cterm=NONE ctermbg=57 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi User5 term=NONE cterm=bold ctermbg=57 ctermfg=32 gui=bold guibg=#c2bfa5 guifg=#990f0f
    CSAHi User6 term=NONE cterm=bold ctermbg=57 ctermfg=16 gui=bold guibg=#c2bfa5 guifg=#000000
    CSAHi SpellRare term=reverse cterm=undercurl ctermbg=bg ctermfg=67 gui=undercurl guibg=bg guifg=fg guisp=#ff00ff
    CSAHi SpellLocal term=underline cterm=undercurl ctermbg=bg ctermfg=31 gui=undercurl guibg=bg guifg=fg guisp=#00ffff
    CSAHi Pmenu term=NONE cterm=NONE ctermbg=80 ctermfg=58 gui=NONE guibg=#1c1c1c guifg=#cccccc
    CSAHi PmenuSel term=NONE cterm=NONE ctermbg=52 ctermfg=79 gui=NONE guibg=#cd853f guifg=#f7f6f5
    CSAHi PmenuSbar term=NONE cterm=NONE ctermbg=80 ctermfg=79 gui=NONE guibg=#1c1c1c guifg=#ffffff
    CSAHi PmenuThumb term=NONE cterm=NONE ctermbg=52 ctermfg=79 gui=NONE guibg=#daa520 guifg=#ffffff
    CSAHi TabLine term=underline cterm=NONE ctermbg=84 ctermfg=80 gui=NONE guibg=#a9a9a9 guifg=#333333
    CSAHi TabLineSel term=bold cterm=bold ctermbg=bg ctermfg=fg gui=bold guibg=bg guifg=fg
    CSAHi TabLineFill term=reverse cterm=reverse ctermbg=81 ctermfg=fg gui=reverse guibg=bg guifg=#666666
    CSAHi CursorColumn term=reverse cterm=NONE ctermbg=81 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineBranch term=NONE cterm=NONE ctermbg=81 ctermfg=85 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineLineColumnNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi TagbarSignature term=NONE cterm=NONE ctermbg=bg ctermfg=40 gui=NONE guibg=bg guifg=#9acd32
    CSAHi TagbarVisibilityProtected term=NONE cterm=NONE ctermbg=bg ctermfg=43 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi StatusLineWarning term=NONE cterm=bold ctermbg=48 ctermfg=79 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi CursorLineNr term=bold cterm=bold ctermbg=bg ctermfg=76 gui=bold guibg=bg guifg=#ffff00
    CSAHi Question term=NONE cterm=bold ctermbg=bg ctermfg=29 gui=bold guibg=bg guifg=#00ff7f
    CSAHi StatusLine term=bold,reverse cterm=NONE ctermbg=57 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineNC term=reverse cterm=NONE ctermbg=80 ctermfg=82 gui=NONE guibg=#1c1c1c guifg=#7f7f7f
    CSAHi VertSplit term=reverse cterm=NONE ctermbg=57 ctermfg=82 gui=NONE guibg=#c2bfa5 guifg=#7f7f7f
    CSAHi Title term=bold cterm=bold ctermbg=bg ctermfg=53 gui=bold guibg=bg guifg=#cd5c5c
    CSAHi Visual term=reverse cterm=NONE ctermbg=36 ctermfg=73 gui=NONE guibg=#6b8e23 guifg=#f0e68c
    CSAHi VisualNOS term=bold,underline cterm=bold,underline ctermbg=bg ctermfg=fg gui=bold,underline guibg=bg guifg=fg
    CSAHi WarningMsg term=NONE cterm=NONE ctermbg=bg ctermfg=69 gui=NONE guibg=bg guifg=#fa8072
    CSAHi WildMenu term=NONE cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=#ffff00 guifg=#000000
    CSAHi StatusLineErrorNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineFileType term=NONE cterm=NONE ctermbg=81 ctermfg=85 gui=NONE guibg=#585858 guifg=#bcbcbc
    CSAHi StatusLineFileTypeNC term=NONE cterm=NONE ctermbg=16 ctermfg=81 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineExpandTab term=NONE cterm=bold ctermbg=81 ctermfg=87 gui=bold guibg=#585858 guifg=#eeeeee
    CSAHi StatusLineFileEncoding term=NONE cterm=bold ctermbg=80 ctermfg=85 gui=bold guibg=#1c1c1c guifg=#bcbcbc
    CSAHi StatusLineFileEncodingNC term=NONE cterm=NONE ctermbg=16 ctermfg=81 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeNormal term=NONE cterm=bold ctermbg=36 ctermfg=79 gui=bold guibg=#4e9a06 guifg=#ffffff
    CSAHi StatusLineBufFlag term=NONE cterm=NONE ctermbg=57 ctermfg=16 gui=NONE guibg=#c2bfa5 guifg=#000000
    CSAHi StatusLineBufFlagNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi StatusLineSeparator term=NONE cterm=NONE ctermbg=80 ctermfg=82 gui=NONE guibg=#1c1c1c guifg=#6c6c6c
    CSAHi StatusLineSeparatorNC term=NONE cterm=NONE ctermbg=16 ctermfg=81 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi CursorLine term=underline cterm=NONE ctermbg=81 ctermfg=fg gui=NONE guibg=#666666 guifg=fg
    CSAHi StatusLineModFlagNC term=NONE cterm=NONE ctermbg=80 ctermfg=81 gui=NONE guibg=#1c1c1c guifg=#4e4e4e
    CSAHi Cursor term=NONE cterm=NONE ctermbg=73 ctermfg=37 gui=NONE guibg=#f0e68c guifg=#708090
    CSAHi lCursor term=NONE cterm=NONE ctermbg=79 ctermfg=80 gui=NONE guibg=#ffffff guifg=#333333
    CSAHi MatchParen term=reverse cterm=NONE ctermbg=21 ctermfg=fg gui=NONE guibg=#008b8b guifg=fg
    CSAHi Comment term=bold cterm=NONE ctermbg=bg ctermfg=43 gui=NONE guibg=bg guifg=#87ceeb
    CSAHi Constant term=underline cterm=NONE ctermbg=bg ctermfg=69 gui=NONE guibg=bg guifg=#ffa0a0
    CSAHi Special term=bold cterm=NONE ctermbg=bg ctermfg=74 gui=NONE guibg=bg guifg=#ffdead
    CSAHi Identifier term=underline cterm=NONE ctermbg=bg ctermfg=45 gui=NONE guibg=bg guifg=#98fb98
    CSAHi StatusLineModFlag term=NONE cterm=bold ctermbg=57 ctermfg=48 gui=bold guibg=#c2bfa5 guifg=#cc0000
    CSAHi StatusLineFunctionName term=NONE cterm=NONE ctermbg=80 ctermfg=84 gui=NONE guibg=#1c1c1c guifg=#9e9e9e
    CSAHi EasyMotionTargetDefault term=NONE cterm=bold ctermbg=bg ctermfg=64 gui=bold guibg=bg guifg=#ff0000
    CSAHi EasyMotionShadeDefault term=NONE cterm=NONE ctermbg=bg ctermfg=82 gui=NONE guibg=bg guifg=#777777
    CSAHi StatusLineFunctionNameNC term=NONE cterm=NONE ctermbg=16 ctermfg=81 gui=NONE guibg=#080808 guifg=#4e4e4e
    CSAHi StatusLineModeInsert term=NONE cterm=bold ctermbg=48 ctermfg=79 gui=bold guibg=#cc0000 guifg=#ffffff
    CSAHi Folded term=NONE cterm=NONE ctermbg=80 ctermfg=72 gui=NONE guibg=#333333 guifg=#ffd700
    CSAHi FoldColumn term=NONE cterm=NONE ctermbg=80 ctermfg=57 gui=NONE guibg=#333333 guifg=#d2b48c
    CSAHi DiffAdd term=bold cterm=NONE ctermbg=17 ctermfg=fg gui=NONE guibg=#00008b guifg=fg
    CSAHi DiffChange term=bold cterm=NONE ctermbg=33 ctermfg=fg gui=NONE guibg=#8b008b guifg=fg
    CSAHi DiffDelete term=bold cterm=bold ctermbg=21 ctermfg=19 gui=bold guibg=#008b8b guifg=#0000ff
    CSAHi DiffText term=reverse cterm=bold ctermbg=64 ctermfg=fg gui=bold guibg=#ff0000 guifg=fg
    CSAHi SignColumn term=NONE cterm=NONE ctermbg=80 ctermfg=31 gui=NONE guibg=#333333 guifg=#00ffff
    CSAHi Conceal term=NONE cterm=NONE ctermbg=84 ctermfg=86 gui=NONE guibg=#a9a9a9 guifg=#d3d3d3
    CSAHi SpellBad term=reverse cterm=undercurl ctermbg=bg ctermfg=64 gui=undercurl guibg=bg guifg=fg guisp=#ff0000
    CSAHi SpellCap term=reverse cterm=undercurl ctermbg=bg ctermfg=19 gui=undercurl guibg=bg guifg=fg guisp=#0000ff
endif

if 1
    delcommand CSAHi
endif
