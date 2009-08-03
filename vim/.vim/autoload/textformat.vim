" Text formatter plugin for Vim text editor
"
" Version:              2.1
" Last Change:          2008-09-13
" Maintainer:           Teemu Likonen <tlikonen@iki.fi>
" License:              This file is placed in the public domain.
" GetLatestVimScripts:  2324 1 :AutoInstall: TextFormat

"{{{1 The beginning stuff
if &compatible
	finish
endif
let s:save_cpo = &cpo
set cpo&vim

" Constant variables(s) {{{1
let s:default_width = 80

function! s:Align_Range_Left(...) range "{{{1
	" The optional parameter is the left indent. If it is not given we
	" detect the indent used in the buffer.
	if a:0 && a:1 >= 0
		" The parameter was given so we just use that as the left
		" indent.
		let l:leading_ws = s:Retab_Indent(a:1)
		for l:line in range(a:firstline,a:lastline)
			let l:line_string = getline(l:line)
			let l:line_replace = s:Align_String_Left(l:line_string)
			if &formatoptions =~ 'w' && l:line_string =~ '\m\s$'
				" Preserve trailing whitespace because fo=~w
				let l:line_replace .= ' '
			endif
			if l:line_replace =~ '\m^\s*$'
				call setline(l:line,'')
			else
				call setline(l:line,l:leading_ws.l:line_replace)
			endif
		endfor
	else
		" The parameter was not given so we detect each paragraph's
		" indent.
		let l:line = a:firstline
		while l:line <= a:lastline
			let l:line_string = getline(l:line)
			if l:line_string =~ '\m^\s*$'
				" The line is empty or contains only
				" whitespaces so print empty line and
				" continue.
				call setline(l:line,'')
				let l:line += 1
				continue
			endif

			" Paragraph (or the whole line range) begins here so
			" get the indent of the first line and print the line.
			let l:leading_ws = s:Retab_Indent(indent(l:line))
			let l:line_replace = s:Align_String_Left(l:line_string)
			if &formatoptions =~ 'w' && l:line_string =~ '\m\s$'
				let l:line_replace .= ' '
			endif
			call setline(l:line,l:leading_ws.l:line_replace)
			let l:line += 1

			" If fo=~w, does the paragraph end here? If yes,
			" continue to next round and find a new first line.
			if &formatoptions =~ 'w' && l:line_string =~ '\m\S$'
				continue
			endif

			" If fo=~2 get the indent of the second line
			if &formatoptions =~ '2'
				let l:leading_ws = s:Retab_Indent(indent(l:line))
			endif

			" This loop will go through all the lines in the
			" paragraph (or till the a:lastline) - starting from
			" the second line.
			while l:line <= a:lastline && getline(l:line) !~ '\m^\s*$'
				let l:line_string = getline(l:line)
				let l:line_replace = s:Align_String_Left(l:line_string)
				if &formatoptions =~ 'w'
					if l:line_string =~ '\m\s$'
						call setline(l:line,l:leading_ws.l:line_replace.' ')
						let l:line += 1
						continue
					else
						call setline(l:line,l:leading_ws.l:line_replace)
						let l:line += 1
						" fo=~w and paragraph ends
						" here so we break the loop.
						" The next line is new first
						" line.
						break
					endif
				else
					call setline(l:line,l:leading_ws.l:line_replace)
					let l:line += 1
				endif
			endwhile
		endwhile
	endif
endfunction

function! s:Align_Range_Right(width) "{{{1
	let l:line_replace = s:Align_String_Right(getline('.'),a:width)
	if &formatoptions =~ 'w' && getline('.') =~ '\m\s$'
		let l:line_replace .= ' '
	endif
	if l:line_replace =~ '\m^\s*$'
		" If line would be full of spaces just print empty line.
		call setline(line('.'),'')
	else
		" Retab leading whitespaces
		let l:leading_ws = s:Retab_Indent(strlen(substitute(l:line_replace,'\v^( *).*$','\1','')))
		" Get the rest of the line
		let l:line_replace = substitute(l:line_replace,'^ *','','')
		call setline(line('.'),l:leading_ws.l:line_replace)
	endif
endfunction

function! s:Align_Range_Justify(width, ...) range "{{{1
	" If the optional second argument is given (and is non-zero) each
	" paragraph's last line and range's last line is left-aligned.
	if a:0 && a:1
		let l:paragraph = 1
	else
		let l:paragraph = 0
	endif
	let l:line = a:firstline
	while l:line <= a:lastline
		let l:line_string = getline(l:line)
		if l:line_string =~ '\m^\s*$'
			" The line is empty or contains only
			" whitespaces so print empty line and
			" continue.
			call setline(l:line,'')
			let l:line += 1
			continue
		endif

		" Paragraph (or the whole line range) begins here so
		" get the indent of the first line and print the line.
		let l:indent = indent(l:line)
		let l:width = a:width - l:indent
		let l:leading_ws = s:Retab_Indent(l:indent)

		if l:paragraph && (l:line == a:lastline || getline(l:line+1) =~ '\m^\s*$' || (&formatoptions =~ 'w' && l:line_string =~ '\m\S$'))
			let l:line_replace = s:Align_String_Left(l:line_string)
		else
			let l:line_replace = s:Align_String_Justify(l:line_string,l:width)
		endif
		if &formatoptions =~ 'w' && l:line_string =~ '\m\s$'
			let l:line_replace .= ' '
		endif
		call setline(l:line,l:leading_ws.l:line_replace)
		let l:line += 1

		" If fo=~w, does the paragraph end here? If yes,
		" continue to next round and find a new first line.
		if &formatoptions =~ 'w' && l:line_string =~ '\m\S$'
			continue
		endif

		" If fo=~2 get the indent of the second line
		if &formatoptions =~ '2'
			let l:indent = indent(l:line)
			let l:width = a:width - l:indent
			let l:leading_ws = s:Retab_Indent(l:indent)
		endif

		" This loop will go through all the lines in the
		" paragraph (or till the a:lastline) - starting from
		" paragraph's second line.
		while l:line <= a:lastline && getline(l:line) !~ '\m^\s*$'
			let l:line_string = getline(l:line)
			if l:paragraph && (l:line == a:lastline || getline(l:line+1) =~ '\m^\s*$' || (&formatoptions =~ 'w' && l:line_string =~ '\m\S$'))
				let l:line_replace = s:Align_String_Left(l:line_string)
			else
				let l:line_replace = s:Align_String_Justify(l:line_string,l:width)
			endif
			if &formatoptions =~ 'w'
				if l:line_string =~ '\m\s$'
					call setline(l:line,l:leading_ws.l:line_replace.' ')
					let l:line += 1
					continue
				else
					call setline(l:line,l:leading_ws.l:line_replace)
					let l:line += 1
					" fo=~w and paragraph ends
					" here so we break the loop.
					" The next line is new first
					" line.
					break
				endif
			else
				call setline(l:line,l:leading_ws.l:line_replace)
				let l:line += 1
			endif
		endwhile
	endwhile
endfunction

function! s:Align_Range_Center(width) "{{{1
	let l:line_replace = s:Truncate_Spaces(getline('.'))
	let l:line_replace = s:Add_Double_Spacing(l:line_replace)
	if &formatoptions =~ 'w' && getline('.') =~ '\m\s$'
		let l:line_replace .= ' '
	endif
	call setline(line('.'),l:line_replace)
	execute '.center '.a:width
endfunction

function! s:Align_String_Left(string) "{{{1
	let l:string_replace = s:Truncate_Spaces(a:string)
	let l:string_replace = s:Add_Double_Spacing(l:string_replace)
	return l:string_replace
endfunction

function! s:Align_String_Right(string, width) "{{{1
	let l:string_replace = s:Truncate_Spaces(a:string)
	let l:string_replace = s:Add_Double_Spacing(l:string_replace)
	let l:string_width = s:String_Width(l:string_replace)
	let l:more_spaces = a:width-l:string_width
	return repeat(' ',l:more_spaces).l:string_replace
endfunction

function! s:Align_String_Justify(string, width) "{{{1
	let l:string = s:Truncate_Spaces(a:string)
	" If the parameter string is empty we can just return a line full of
	" spaces. No need to go further.
	if l:string =~ '\m^ *$'
		return repeat(' ',a:width)
	endif
	if s:String_Width(s:Add_Double_Spacing(l:string)) >= a:width
		" The original string is longer than width so we can just
		" return the string. No need to go further.
		return s:Add_Double_Spacing(l:string)
	endif
	let l:string_width = s:String_Width(l:string)

	" This many extra spaces we need.
	let l:more_spaces = a:width-l:string_width
	" Convert the string to a list of words.
	let l:word_list = split(l:string)
	" This is the amount of spaces available in the original string (word
	" count minus one).
	let l:string_spaces = len(l:word_list)-1
	" If there are no spaces there is only one word. We can just return
	" the string with padded spaces. No need to go further.
	if l:string_spaces == 0
		return l:string.repeat(' ',l:more_spaces)
	endif
	" Ok, there are more than one word in the string so we get to do some
	" real work...

	" Make a list of which each item represent a space available in the
	" string. The value means how many spaces there are. At the moment set
	" every list item to one: [1, 1, 1, 1, ...]
	let l:space_list = []
	for l:item in range(l:string_spaces)
		let l:space_list += [1]
	endfor

	" Repeat while there are no more need to add any spaces.
	while l:more_spaces > 0
		if l:more_spaces >= l:string_spaces
			" More extra spaces are needed than there are spaces
			" available in the string so we add one more space 
			" after every word (add 1 to items of space list).
			for l:i in range(l:string_spaces)
				let l:space_list[l:i] += 1
			endfor
			let l:more_spaces -= l:string_spaces
			" And then another round... and a check if more spaces
			" are needed.
		else " l:more_spaces < l:string_spaces
			" This list tells where .?! characters are.
			let l:space_sentence_full = []
			" This list tells where ,:; characters are.
			let l:space_sentence_semi = []
			" And this is for the rest of spaces.
			let l:space_other = []
			" Now, find those things:
			for l:i in range(l:string_spaces)
				if l:word_list[l:i] =~ '\m\S[.?!]$'
					let l:space_sentence_full += [l:i]
				elseif l:word_list[l:i] =~ '\m\S[,:;]$'
					let l:space_sentence_semi += [l:i]
				else
					let l:space_other += [l:i]
				endif
			endfor

			" First distribute spaces after .?!
			if l:more_spaces >= len(l:space_sentence_full)
				" If we need more extra spaces than there are
				" .?! spaces, just add one after every item.
				for l:i in l:space_sentence_full
					let l:space_list[l:i] += 1
				endfor
				let l:more_spaces -= len(l:space_sentence_full)
				if l:more_spaces == 0 | break | endif
			else
				" Distribute the rest of spaces evenly and
				" break the loop. All the spaces have been
				" added.
				for l:i in s:Distributed_Selection(l:space_sentence_full,l:more_spaces)
					let l:space_list[l:i] +=1
				endfor
				break
			endif

			" Then distribute spaces after ,:;
			if l:more_spaces >= len(l:space_sentence_semi)
				" If we need more extra spaces than there are
				" ,:; spaces available, just add one after
				" every item.
				for l:i in l:space_sentence_semi
					let l:space_list[l:i] += 1
				endfor
				let l:more_spaces -= len(l:space_sentence_semi)
				if l:more_spaces == 0 | break | endif
			else
				" Distribute the rest of spaces evenly and
				" break the loop. All the spaces have been
				" added.
				for l:i in s:Distributed_Selection(l:space_sentence_semi,l:more_spaces)
					let l:space_list[l:i] +=1
				endfor
				break
			endif

			" Finally distribute spaces to other available
			" positions and exit the loop.
			for l:i in s:Distributed_Selection(l:space_other,l:more_spaces)
				let l:space_list[l:i] +=1
			endfor
			break
		endif
	endwhile

	" Now we now where all the extra spaces will go. We have to construct
	" the string again.
	let l:string = ''
	for l:item in range(l:string_spaces)
		let l:string .= l:word_list[l:item].repeat(' ',l:space_list[l:item])
	endfor
	" Add the last word to the end and return the string.
	return l:string.l:word_list[-1]
endfunction

function! s:Truncate_Spaces(string) "{{{1
	let l:string = substitute(a:string,'\v\s+',' ','g')
	let l:string = substitute(l:string,'\m^\s*','','')
	let l:string = substitute(l:string,'\m\s*$','','')
	return l:string
endfunction

function! s:String_Width(string) "{{{1
	" This counts the string width in characters. Combining diacritical
	" marks do not count so the base character with all the combined
	" diacritics is just one character (which is good for our purposes).
	" Double-wide characters will not get double width so unfortunately
	" they don't work in our algorithm.
	return strlen(substitute(a:string,'\m.','x','g'))
endfunction

function! s:Add_Double_Spacing(string) "{{{1
	if &joinspaces
		return substitute(a:string,'\m\S[.?!] ','& ','g')
	else
		return a:string
	endif
endfunction

function! s:Distributed_Selection(list, pick) "{{{1
	" 'list' is a list-type variable [ item1, item2, ... ]
	" 'pick' is a number how many of the list's items we want to choose
	"
	" This function returns a list which has 'pick' number of items from
	" the original list. Items are chosen in distributed manner. For
	" example, if 'pick' is 1 then the algorithm chooses an item near the
	" center of the 'list'. If 'pick' is 2 then the first one is about 1/3
	" from the beginning and the another one about 2/3 from the beginning.

	" l:pick_list is a list of 0's and 1's and its length will be the
	" same as original list's. Number 1 means that this list item will be
	" picked and 0 means that the item will be dropped. Finally
	" l:pick_list could look like this: [0, 1, 0, 1, 0]
	" (i.e., two items evenly picked from a list of five items)
	let l:pick_list = []

	" First pick items evenly from the beginning of the list. This also
	" actually constructs the list.
	let l:div1 = len(a:list) / a:pick
	let l:mod1 = len(a:list) % a:pick
	for l:i in range(len(a:list)-l:mod1)
		if !eval(l:i%l:div1)
			let l:pick_list += [1]
		else
			let l:pick_list += [0]
		endif
	endfor

	if l:mod1 > 0
		" The division wasn't even so we get the remaining items and
		" distribute them evenly again to the list.
		let l:div2 = len(l:pick_list) / l:mod1
		let l:mod2 = len(l:pick_list) % l:mod1
		for l:i in range(len(l:pick_list)-l:mod2)
			if !eval(l:i%l:div2)
				call insert(l:pick_list,0,l:i)
			endif
		endfor
	endif

	" There may be very different number of zeros in the beginning and the
	" end of the list. We count them.
	let l:zeros_begin = 0
	for l:i in l:pick_list
		if l:i == 0
			let l:zeros_begin += 1
		else
			break
		endif
	endfor
	let l:zeros_end = 0
	for l:i in reverse(copy(l:pick_list))
		if l:i == 0
			let l:zeros_end += 1
		else
			break
		endif
	endfor

	" Then we remove them.
	if l:zeros_end
		" Remove "0" items from the end. We need to remove them first
		" from the end because list items' index number will change
		" when items are removed from the beginning. Then it would be
		" more difficult to remove trailing zeros.
		call remove(l:pick_list,len(l:pick_list)-l:zeros_end,-1)
	endif
	if l:zeros_begin
		" Remove zero items from the beginning.
		call remove(l:pick_list,0,l:zeros_begin-1)
	endif
	let l:zeros_both = l:zeros_begin + l:zeros_end

	" Put even amount of zeros to beginning and end
	for l:i in range(l:zeros_both/2)
		call insert(l:pick_list,0,0)
	endfor
	for l:i in range((l:zeros_both/2)+(l:zeros_both%2))
		call add(l:pick_list,0)
	endfor

	" Finally construct and return a new list which has only the items we
	" have chosen.
	let l:new_list = []
	for l:i in range(len(l:pick_list))
		if l:pick_list[l:i] == 1
			let l:new_list += [a:list[l:i]]
		endif
	endfor
	return l:new_list
endfunction

function! s:Retab_Indent(column) "{{{1
	" column = the left indent column starting from 0 Function returns
	" a string of whitespaces, a mixture of tabs and spaces depending on
	" the 'expandtab' and 'tabstop' options.
	if &expandtab
		" Only spaces
		return repeat(' ',a:column)
	else
		" Tabs and spaces
		let l:tabs = a:column / &tabstop
		let l:spaces = a:column % &tabstop
		return repeat("\<Tab>",l:tabs).repeat(' ',l:spaces)
	endif
endfunction

function! s:Reformat_Range(...) range "{{{1
	if a:0 == 2
		let l:first = a:1
		let l:last = a:2
	else
		let l:first = a:firstline
		let l:last = a:lastline
	endif
	let l:autoindent = &autoindent
	setlocal autoindent
	execute l:first
	normal! 0
	execute 'normal! V'.l:last.'G$gw'
	let &l:autoindent = l:autoindent
	" The formatting may change the last line of the range so we return
	" it.
	return line("'>")
endfunction

function! textformat#Visual_Align_Left() range "{{{1
	execute a:firstline.','.a:lastline.'call s:Align_Range_Left()'
	call s:Reformat_Range(a:firstline,a:lastline)
endfunction

function! textformat#Visual_Align_Right() range "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width | endif

	execute a:firstline.','.a:lastline.'call s:Align_Range_Right('.l:width.')'
	normal! '>$
endfunction

function! textformat#Visual_Align_Justify() range "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width | endif

	execute a:firstline.','.a:lastline.'call s:Align_Range_Left()'

	let l:last = s:Reformat_Range(a:firstline,a:lastline)
	let l:pos = getpos('.')
	execute a:firstline.','.l:last.'call s:Align_Range_Justify('.l:width.',1)'
	call setpos('.',l:pos)
endfunction

function! textformat#Visual_Align_Center() range "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width | endif

	execute a:firstline.','.a:lastline.'call s:Align_Range_Center('.l:width.')'
	normal! '>$
endfunction

function! textformat#Quick_Align_Left() "{{{1
	let l:autoindent = &autoindent
	setlocal autoindent
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Left()
	call setpos('.',l:pos)
	silent normal! gwip
	let &l:autoindent = l:autoindent
endfunction

function! textformat#Quick_Align_Right() "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width | endif
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Right(l:width)
	call setpos('.',l:pos)
endfunction

function! textformat#Quick_Align_Justify() "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width  | endif
	let l:autoindent = &autoindent
	setlocal autoindent
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Left()
	call setpos('.',l:pos)
	silent normal! gwip
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Justify(l:width,1)
	call setpos('.',l:pos)
	let &l:autoindent = l:autoindent
endfunction

function! textformat#Quick_Align_Center() "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width  | endif
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Center(l:width)
	call setpos('.',l:pos)
endfunction

function! textformat#Align_Command(align, ...) range "{{{1
	" For left align the optional parameter a:1 is [indent]. For others
	" it's [width].
	let l:pos = getpos('.')
	if a:align ==? 'left'
		if a:0 && a:1 >= 0
			execute a:firstline.','.a:lastline.'call s:Align_Range_Left('.a:1.')'
		else
			execute a:firstline.','.a:lastline.'call s:Align_Range_Left()'
		endif
	else
		if a:0 && a:1 > 0
			let l:width = a:1
		elseif &textwidth
			let l:width = &textwidth
		else
			let l:width = s:default_width
		endif

		if a:align ==? 'right'
			execute a:firstline.','.a:lastline.'call s:Align_Range_Right('.l:width.')'
		elseif a:align ==? 'justify'
			execute a:firstline.','.a:lastline.'call s:Align_Range_Justify('.l:width.')'
		elseif a:align ==? 'center'
			execute a:firstline.','.a:lastline.'call s:Align_Range_Center('.l:width.')'
		endif
	endif
	call setpos('.',l:pos)
endfunction

"{{{1 The ending stuff
let &cpo = s:save_cpo

" vim600: fdm=marker
