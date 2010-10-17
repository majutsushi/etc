" Vim Tex / LaTeX ftplugin to automatically close environments.
" Maintainor:	Gautam Iyer <gautam@math.uchicago.edu>
" Created:	Mon 23 Feb 2004 04:47:53 PM CST
" Last Changed:	Wed 25 Mar 2009 10:57:46 AM PDT
" Version:	1.2
"
" Description:
"   Provides mappings to automatically close environments.
"
"   Pressing "\c" in normal mode (or <C-\>c in insert mode) will cause the
"   last open environment to be closed. (If a fold is started on the
"   \begin{env} line, then it will be automatically closed on the \close{env}
"   line.)
"
"   By default pressing "<C-\>}" in insert mode when the cursor is at the end
"   of a "\begin{environment}" will automatically generate a
"   "\close{environment}". It will leave the cursor at the end of the
"   "\begin{environment}" (in insert mode), so that the user can enter
"   arguments [if any].
"
"
" History:
"   Version 1.2:	Disabled "}" auto closing environments by default.
"			This ruined the change history (and didn't account for
"			fold markers). Provided "<C-\>c" to close the last
"			open environment. (Also fix a UTF8 bug, thanks to
"			Molin Pascal)
"
"   Version 1.1:	Pressing "}" now shows the matching "{".
"
"   Version 1.01:	Disabled the mapping "\}". To insert a literal "}" in
"   			latex, you have to use "\}", which conflicts with this
"   			mapping. If you do NOT want "}" to automatically close
"   			an environment, use "^V}"
 
" provide load control
if exists('b:loaded_tex_autoclose')
    finish
endif
let b:loaded_tex_autoclose = 1

if exists('g:tex_autoclose_fregexp')
    if g:tex_autoclose_fregexp != 'none'
	let b:tex_autoclose_fregexp = g:tex_autoclose_fregexp
    endif
else
    let b:tex_autoclose_fregexp =
	    \ '\v^(theorem|lemma|corollary|proposition|remark)\*?$'
endif

" If the user has mapped "TexCloseCurrent" to something, we assume he does not
" want our maps, and we do not provide any mappings.
if !hasmapto("TexCloseCurrent()", "ni")
    " \} is anoying. it shows up often in latex. 
    " inoremap <buffer>		<leader>}  }
    inoremap <buffer> <silent>	<C-\>}	    <esc>:call TexCloseCurrent()<cr>}
endif

if !hasmapto("TexClosePrev()")
    nnoremap <buffer> <silent>	<LocalLeader>c	:call TexClosePrev(0)<cr>
    inoremap <buffer> <silent>	<C-\>c		<esc>:call TexClosePrev(1)<cr>
endif

" Function to automatically close the environment
function! TexCloseCurrent()
    let line = getline('.')
    let linestart = strpart( line, 0, col('.'))

    let env = matchstr( linestart, '\v%(\\begin\{)@<=[a-zA-Z0-9*]+$')
    if env != ''
	exec "normal! a\<cr>\\end{" . env . "}\<esc>k"
	startinsert!
    else
	" Not a begin tag. Resume insert mode as if nothing had happened
	if col('.') < strlen(substitute(line, ".", "x", "g"))
	    normal! l
	    startinsert
	else
	    startinsert!
	endif
    endif
endfunction

function! TexClosePrev( restore_insert )
    let lnum = 0
    let cnum = 0

    " XXX: Back refs are not correctly handled. Thus environment names are not
    " correctly checked when nested.
    let [lnum, cnum] = searchpairpos( '\v\\begin\{[a-zA-Z]+\*?\}', '',
		\ '\v\\end\{[a-zA-Z]+\*?\}', 'bn' )

    if lnum == 0 && cnum == 0
	return
    endif

    let line = getline( lnum )
    let line = strpart( line, cnum - 1)
    let env  = matchstr( line, '\v^\\begin\{\zs[A-Za-z]+\*?')
    if exists( b:tex_autoclose_fregexp ) && env =~ b:tex_autoclose_fregexp
	let fold = matchstr( line, '\v\%\{{3}[1-9]?' )
    else
	let fold = matchstr( line, '\v^\\begin\{[A-Za-z]+\*?\}.*\zs\%\{{3}[1-9]?$')
    endif
    let fold = tr( fold, '{', '}' )

    exec 'normal! a\end{' . env . '}' . fold . "\<esc>"

    if a:restore_insert == 1
	if col('.') < col('$') - 1
	    startinsert
	else
	    startinsert!
	endif
    endif
endfunction
