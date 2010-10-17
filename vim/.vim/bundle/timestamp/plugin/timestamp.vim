" TimeStamp 1.21: Vim plugin for automated time stamping.
" Maintainer:	Gautam Iyer <gi1242ATusersDOTsourceforgeDOTnet>
" Created:	Fri 06 Feb 2004 02:46:27 PM CST
" Modified:	Wed 25 Mar 2009 03:28:34 PM PDT
" License:	This file is placed in the public domain.
"
" Credits:	Thanks to Guido Van Hoecke for writing the original vim script
" 		"timstamp.vim".
" Description:
"   When a file is written, and the filename matches "timestamp_automask",
"   this plugin will search the first and last "timestamp_modelines" lines of
"   your file. If it finds the regexp "timestamp_regexp" then it will replace
"   it with a timestamp. The timestamp is computed by first doing a
"   "token_substitution" on "timestamp_rep" and passing the result to
"   "strftime()". See the documentation for details.

" provide load control
if exists("loaded_timestamp")
    finish
endif
let loaded_timestamp = 1

let s:cpo_save = &cpo
set cpo&vim		" line continuation is used

" {{{1 getValue( deflt, globl, alternates...): Get value of a script variable
function s:getValue(deflt, globl, ...)
    " If the global variable globl exists, return that. Otherwise, return the
    " first non-empty arguement. If none exists, return deflt.
    " If globl is "NONE" then don't look for a global variable.
    if a:globl != 'NONE' && exists(a:globl)
	return {a:globl}
    else
	let indx = 1
	while indx <= a:0
	    if a:{indx} != ""
		return a:{indx}
	    endif
	    let indx = indx + 1
	endwhile
    endif

    " No non-empty arguements. Return default.
    return a:deflt 
endfunction

" {{{1 initialise() Function to initialise script variables.
function s:initialise()
    " Initialisations are done the FIRST time any file needs to be
    " timestamped. Speeds up the vim load time.

    " Default timestamp expressions
    let s:timestamp_regexp = s:getValue('\v\C%(<%(Last %([cC]hanged?|modified)|Modified)\s*:\s+)@<=\a+ \d{2} \a+ \d{4} \d{2}:\d{2}:\d{2}%(\s+[AP]M)?%(\s+\a+)?|TIMESTAMP', 'g:timestamp_regexp')

    " %c seems to be different on different systems. Use a full form instead.
    let s:timestamp_rep = s:getValue('%a %d %b %Y %I:%M:%S %p %Z', 'g:timestamp_rep')

    " Plugin Initialisations.
    let s:modelines	= s:getValue( &modelines, 'g:timestamp_modelines')

    if !exists( 'g:timestamp_UseSystemCalls' )
	" Don't use any system calls (faster but less accurate).
	let s:Hostname	= s:getValue( hostname(), 'g:timestamp_Hostname', $HOSTNAME, $HOST)
	let s:username	= s:getValue( 'unknown', 'g:timestamp_username', $USER, $LOGNAME, $USERNAME)
	let s:userid	= s:getValue( 'unknown', 'g:timestamp_userid')
    else
	" Get Hostname
	if exists('g:timestamp_Hostname')
	    let s:Hostname = g:timestamp_Hostname
	else
	    let s:Hostname = system('hostname -f | tr -d "\n"')
	    let s:Hostname = s:getValue( hostname(), 'NONE', v:shell_error ? '' : s:Hostname, $HOSTNAME, $HOST)
	endif

	" Get username
	if exists('g:timestamp_username')
	    let s:username = g:timestamp_username
	else
	    let s:username = system( 'id -un | tr -d "\n"')
	    let s:username = s:getValue( v:shell_error ? 'unknown' : s:username,
			\ 'NONE', $USER, $LOGNAME, $USERNAME)
	endif

	" Get userid
	if exists('g:timestamp_userid')
	    let s:userid = g:timestamp_userid
	else
	    let s:userid = system( 'id -u | tr -d "\n"')
	    if v:shell_error && s:username != 'unknown'
		let s:userid = system( 'grep ' . s:username . ' /etc/passwd | cut -f 3 -d : | tr -d "\n"')
		if v:shell_error
		    let s:userid = 'unknown'
		endif
	    endif
	endif
    endif

    " Get hostname
    let s:hostname = s:getValue( substitute( s:Hostname, '\..*', '', ''), 'g:timestamp_hostname')
endfunction

" {{{1 setup_autocommand(): Function to setup autocommands for timestamping.
function s:setup_autocommand()
    if has('autocmd')
	if ! exists( 's:autocomm' )
	    let l:automask = s:getValue( '*', 'g:timestamp_automask')
	    let s:autocomm = "autocmd BufWritePre " . l:automask
			\ . " :call s:timestamp()"
	endif

	augroup TimeStamp
	    " this autocommand triggers the update of the requested timestamps
	    au!
	    exec s:autocomm
	augroup END
    else
	echoerr 'Autocommands not enabled. Timestamping will not work'
    endif
endfunction

" {{{1 timestamp(): Function that does the timestamping
function s:timestamp()
    if exists('b:timestamp_disabled') && b:timestamp_disabled
	return
    endif

    " If running for the first time, initialise script variables.
    if !exists('s:timestamp_regexp')
	call s:initialise()

	" Free up memory.
	delfunction s:initialise
	delfunction s:getValue
    endif

    " Get buffer local patterns -- overriding global ones.
    let   pat	   = exists("b:timestamp_regexp")	? b:timestamp_regexp	: s:timestamp_regexp
    let   rep	   = exists("b:timestamp_rep")		? b:timestamp_rep	: s:timestamp_rep
    let l:hostname = exists("b:timestamp_hostname")	? b:timestamp_hostname	: s:hostname
    let l:Hostname = exists("b:timestamp_Hostname")	? b:timestamp_Hostname	: s:Hostname
    let l:username = exists("b:timestamp_username")	? b:timestamp_username	: s:username
    let l:userid   = exists("b:timestamp_userid")	? b:timestamp_userid	: s:userid

    " Process the replacement pattern
    let rep = strftime(rep)
    let rep = substitute(rep, '\C#f', expand("%:p:t"), "g")
    let rep = substitute(rep, '\C#h', l:hostname, "g")
    let rep = substitute(rep, '\C#H', l:Hostname, "g")
    let rep = substitute(rep, '\C#u', l:username, "g")
    let rep = substitute(rep, '\C#i', l:userid,   "g")

    " Escape forward slashes
    let pat = escape(pat, '/')
    let rep = escape(rep, '/')

    " Get ranges for timestamp to be located
    let l:modelines = exists("b:timestamp_modelines") ? b:timestamp_modelines : s:modelines
    let l:modelines = (l:modelines == '%') ? line('$') : l:modelines

    if line('$') > 2 * l:modelines
	call s:subst(1, l:modelines, pat, rep)
	call s:subst(line('$') + 1 - l:modelines, line('$'), pat, rep)
    else
	call s:subst(1, line('$'), pat, rep)
    endif
endfunction

" {{{1 subst( start, end, pat, rep): substitute on range start - end.
function s:subst(start, end, pat, rep)
    let lineno = a:start
    while lineno <= a:end
	let curline = getline(lineno)
	if match(curline, a:pat) != -1
	    let newline = substitute( curline, a:pat, a:rep, '' )
	    if( newline != curline )
		" Only substitute if we made a change
		"silent! undojoin
		keepjumps call setline(lineno, newline)
	    endif
	endif
	let lineno = lineno + 1
    endwhile
endfunction
" }}}1

call s:setup_autocommand()
command! DisableTimestamp   au! TimeStamp
command! EnableTimestamp    call s:setup_autocommand()

" Restore compatibility options
let &cpo = s:cpo_save
unlet s:cpo_save
