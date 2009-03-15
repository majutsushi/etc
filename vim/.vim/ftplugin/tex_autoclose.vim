" Vim Tex / LaTeX ftplugin to automatically close environments.
" Maintainor:	Gautam Iyer <gautam@math.uchicago.edu>
" Created:	Mon 23 Feb 2004 04:47:53 PM CST
" Last Changed:	Thu 08 Apr 2004 04:07:24 PM CDT
" Version:	1.1 
"
" Description:
"   By default pressing "}" in insert mode when the cursor is at the end of a
"   "\begin{environment}" will automatically generate a "\close{environment}".
"   It will leave the cursor at the end of the "\begin{environment}" (in
"   insert mode), so that the user can enter arguments [if any].
"
"   Pressing "}" in insert mode will only insert a "}" and not atempt to
"   generate a "\end{environment}" tag.
"
" TODO:
"   1. Don't alter the undo history when "}" is pressed.
"
" History:
"   Version 1.1:	Pressing "}" now shows the matching "{".
"
"   Version 1.01:	Disabled the mapping "\}". To insert a literal "}" in
"   			latex, you have to use "\}", which conflicts with this
"   			mapping. If you do NOT want "}" to automatically close
"   			an environment, use "}"
 
" provide load control
if exists('b:loaded_tex_autoclose')
    finish
endif
let b:loaded_tex_autoclose = 1

" If the user has mapped "TexCloseEnv" to something, we assume he does not
" want our maps, and we do not provide any mappings.
if !hasmapto("TexCloseEnv()", "ni")
    " \} is anoying. it shows up often in latex. 
    " inoremap <buffer>		<leader>}  }
    inoremap <buffer> <silent>	}	   <esc>:call TexCloseEnv()<cr>}
endif

" Only define the function if it has not been defined before.
if !exists('*TexCloseEnv()')
    " Function to automatically close environments
    function TexCloseEnv()
	let line = getline('.')
	let linestart = strpart( line, 0, col('.'))

	let env = matchstr( linestart, '\v%(\\begin\{)@<=[a-zA-Z0-9*]+$')
	if env != ''
	    exec "normal! a\<cr>\\end{" . env . "}\<esc>k"
	    startinsert!
	else
	    " Not a begin tag. Resume insert mode as if nothing had happened
	    if col('.') < strlen(line)
		normal! l
		startinsert
	    else
		startinsert!
	    endif
	endif
    endfunction
endif
