" LaTeX Box mappings

if exists("g:LatexBox_no_mappings")
	finish
endif

" latexmk {{{
map <buffer> <LocalLeader>ll :Latexmk<CR>
map <buffer> <LocalLeader>lL :LatexmkForce<CR>
map <buffer> <LocalLeader>lc :LatexmkClean<CR>
map <buffer> <LocalLeader>lC :LatexmkCleanAll<CR>
map <buffer> <LocalLeader>lg :LatexmkStatus<CR>
map <buffer> <LocalLeader>lG :LatexmkStatusDetailed<CR>
map <buffer> <LocalLeader>lk :LatexmkStop<CR>
map <buffer> <LocalLeader>le :LatexErrors<CR>
" }}}

" View {{{
map <buffer> <LocalLeader>lv :LatexView<CR>
" }}}

" Error Format {{{
" This assumes we're using the -file-line-error with [pdf]latex.
setlocal efm=%E%f:%l:%m,%-Cl.%l\ %m,%-G
" }}}

" TOC {{{
command! LatexTOC call LatexBox_TOC()
map <silent> <buffer> <LocalLeader>lt :LatexTOC<CR>
" }}}

" begin/end pairs {{{
nmap <buffer> % <Plug>LatexBox_JumpToMatch
xmap <buffer> % <Plug>LatexBox_JumpToMatch
vmap <buffer> ie <Plug>LatexBox_SelectCurrentEnvInner
vmap <buffer> ae <Plug>LatexBox_SelectCurrentEnvOuter
omap <buffer> ie :normal vie<CR>
omap <buffer> ae :normal vae<CR>
vmap <buffer> i$ <Plug>LatexBox_SelectInlineMathInner
vmap <buffer> a$ <Plug>LatexBox_SelectInlineMathOuter
omap <buffer> i$ :normal vi$<CR>
omap <buffer> a$ :normal va$<CR>
" }}}

setlocal omnifunc=LatexBox_Complete

finish

" Suggested mappings:

" Motion {{{
map <silent> <buffer> ¶ :call LatexBox_JumpToNextBraces(0)<CR>
map <silent> <buffer> § :call LatexBox_JumpToNextBraces(1)<CR>
imap <silent> <buffer> ¶ <C-R>=LatexBox_JumpToNextBraces(0)<CR>
imap <silent> <buffer> § <C-R>=LatexBox_JumpToNextBraces(1)<CR>
" }}}

" begin/end {{{
imap <buffer> <silent> <F5> <C-R>=LatexBox_TemplatePrompt(1)<CR>
imap <buffer> <silent> [[ \begin{
imap <buffer> <silent> ]] <C-R>=LatexBox_CloseLastEnv()<CR>
vmap <buffer> <silent> <F7> <Esc>:<c-u>call LatexBox_WrapSelection('')<CR>i
" }}}

" Other commands {{{
imap <buffer> <F11> <C-R>=LatexBox_FindLabelByNumberPrompt()<CR>
" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
