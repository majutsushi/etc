" Vim plugin to align C function arguments, GNOME style.
"
" This software is available under the MIT license.
"
" Copyright © 2009 Damien Lespiau <damien.lespiau@gmail.com>
"
" Permission is hereby granted, free of charge, to any person
" obtaining a copy of this software and associated documentation
" files (the "Software"), to deal in the Software without
" restriction, including without limitation the rights to use,
" copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the
" Software is furnished to do so, subject to the following
" conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
" OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
" HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
" WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
" OTHER DEALINGS IN THE SOFTWARE.
"
"        Author:  Damien Lespiau <damien.lespiau@gmail.com>
" Last Modified:  20091207

" Save value of cpoptions, and then set it to vim default
let s:save_cpo = &cpo
set cpo&vim

" Ensure that the plugin is loaded only once
if exists("is_c_align_args_plugin_loaded")
	finish
endif
let is_c_align_args_plugin_loaded = 1

function s:sanitize(string)
	let l:sane = substitute(a:string, '[\n,]', '', 'g')
	" did not find a strip function
	let l:sane = substitute(l:sane, '^\s\+', '', 'g')
	let l:sane = substitute(l:sane, '\s\+$', '', '')
	return l:sane
endfunction

function s:getpos()
	let l:pos = getpos('.')
	return [l:pos[1], l:pos[2]]
endfunction

function s:setpos(newpos)
	call setpos('.', [0, a:newpos[0], a:newpos[1], 0])
endfunction

function s:find_param_end()
	return searchpos(',\|)', '')
endfunction

function s:position_is_before(a, b)
	return (a:a[0] < a:b[0] || (a:a[0] == a:b[0] && a:a[1] <= (a:b[1] )))
endfunction

function s:save_intial_state()
	" save position/marks/registers we are going to use in the script to
	" restore them later
	let s:old_position = getpos('.')
	let s:old_mark_a = getpos("'a")
	let s:old_paste_reg = getreg('"', 1)
	let s:old_paste_reg_mode = getregtype('"')

	" we use the (0 cinoption to align the args to the first '('
	let s:old_cinoptions = &cinoptions
	set cinoptions=(0
endfunction

function s:restore_initial_state()
	" restore cinoptions
	let &cinoptions=s:old_cinoptions

	" restore position/marks/registers
	call setreg('"', s:old_paste_reg, s:old_paste_reg_mode)
	if s:old_mark_a[2] != 0
		call setpos("'a", s:old_mark_a)
	else
		delmark a
	endif
	call setpos('.', s:old_position)
endfunction

" find the start and end of the parameters list
function s:find_arg_list_start_end()
	let s:stmt_end = searchpos('{\|;', 'cW')
	" WIP function/declaration: fallback to finding the next ')'
	if s:stmt_end[0] == 0
		call search(')', 'cW')
	endif
	let s:param_list_end = searchpos(')', 'cb')
	normal %
	let s:param_list_start = s:getpos()
endfunction

function s:align_args()
	call s:save_intial_state()

	call s:find_arg_list_start_end()

	" canonicalize the arguments list:
	"   * put all the arguments on a single line (where param_list_start is)
	"   * cleanup tabs and extra white space
	let l:i = s:param_list_end[0] - s:param_list_start[0]
	while l:i > 0
		normal J
		let l:i -= 1
	endwhile
	s/\s\+/ /ge

	" find the start and end of the parameters list, again
	call s:find_arg_list_start_end()

	" initalize a few variables for the scan of the parameters.
	let l:param_start = deepcopy(s:param_list_start)
	let l:param_end = s:find_param_end()
	let l:params = []
	let l:max_type_len = 0
	let l:max_stars_nr = 0

	while s:position_is_before(l:param_end, s:param_list_end) &&
	     \s:position_is_before(l:param_start, l:param_end)
		" Invariants:
		"   * the cursor is at the end of the current arg ie either on
		"     the comma, or on the closing bracket. param_end holds
		"     that position.
		"   * param_start is the previous param_end (or the opening '('
		"     for the first iteration)

		" [ argument (eg 'gint i'),
		"   position (in the buffer) of the argument last space,
		"   length of the qualifiers + type + ' ' string,
		"   nb of stars before the arg name ]
		let l:new_param = []

		" get the argument
		normal ma
		call s:setpos([l:param_start[0], l:param_start[1] + 1])
		normal y`a
		let l:param_string = s:sanitize(@")
		call add(l:new_param, l:param_string)
		normal `a

		" get the position (in the buffer) of the space before the
		" argument name,
		normal F 
		call add(l:new_param, s:getpos())
		normal `a

		" type_len is the length of the qualifiers + type string,
		" including the final space separator
		let l:type_len = strridx (l:new_param[0], ' ')
		if l:type_len == -1
			call s:restore_initial_state()
			return
		endif
		call add(l:new_param, l:type_len)

		" stars_nr is the number of stars before the argument name
		normal b
		let l:stars_nr = s:getpos()[1] - l:new_param[1][1] - 1
		normal `a
		call add(l:new_param, l:stars_nr)

		" save the biggest type_len and stars_nr so far
		if l:type_len > l:max_type_len
			let l:max_type_len = l:type_len
		endif
		if l:stars_nr > l:max_stars_nr
			let l:max_stars_nr = l:stars_nr
		endif

		call add(l:params, l:new_param)

		let l:param_start = deepcopy(l:param_end)
		let l:param_end = s:find_param_end()
	endwhile

	" uncomment this line to paste l:params to "a and debug that thing
	" call setreg('a', string(l:params))

	" add spaces where needed
	let l:offset = 0
	for l:param in l:params
		let l:spaces_nr = l:max_type_len - l:param[2] +
		   \l:max_stars_nr - l:param[3]
		call s:setpos([l:param[1][0], l:param[1][1] + l:offset])
		let l:offset += l:spaces_nr
		" hum think of something smarter?
		while l:spaces_nr > 0
			normal a 
			let l:spaces_nr -= 1
		endwhile
	endfor

	" insert <CR> after each ','
	call s:setpos(s:param_list_start)
	while search(',', '', line('.'))
		exe "normal a\<CR>"
	endwhile

	call s:restore_initial_state()
endfunction

noremap <unique> <script> <Plug>c_align_args_add  <SID>align_args
noremap <SID>align_args :call <SID>align_args()<CR>

" define a command the user can map
if !exists("GNOMEAlignArguments")
	command -nargs=0 GNOMEAlignArguments :call s:align_args()
endif

" restore cpoptions
let &cpo=s:save_cpo
