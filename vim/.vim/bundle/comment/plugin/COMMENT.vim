" COMMENT.vim
"	Author:		Jeff Crawford <j_crawfd@yahoo.ca>
"	Date:		May 10, 2003
"	Updated:    Oct 13, 2005
"	Typical Usage:
"	    Type <M-i> after visually selecting a block of
"	    code will add #if 0 #endif to the beginning and end of the block.

if exists("loaded_COMMENT")
	finish
endif
let loaded_COMMENT= 1

" ---------------------------------------------------------------------
" Public Interface:

if !hasmapto('<Plug>PComment')
	map <unique> <M-i> <Plug>PComment
endif
vmap <silent> <script> <Plug>PComment <Esc>:set lz<CR>:call <SID>PComment()<CR>:set nolz<CR>

" ---------------------------------------------------------------------

" PComment:
function! <SID>PComment()
	let firstline = line("'<")
	let lastline  = line("'>")
	let line      = getline(firstline)
	if (line =~ '^#if')
		" remove if block
		execute firstline . "normal dd"
		let emb=0
		let i = firstline+1
		while i<=line("$")
			let line=getline(i)
			if line =~ '^#if'
				let emb=emb+1
			endif
			if line =~ '^#else'
				if emb == 0
					" not an embedded else so turn else
					" into an #if 0 to match following
					" #endif
					let newline=substitute(line,"^#else","#if 0","")
					call setline(i,newline)
					break
				endif
			endif
			if line =~ '^#endif'
				if emb > 0
					let emb=emb-1
				else
					" found matching endif; remove it
					execute i . "normal dd"
					break
				endif
			endif
			let i=i+1
		endwhile
	else
		" add block
		call append((firstline-1),"#if 0")
		call append(lastline+1,"#endif")
	endif
endfunction

" ---------------------------------------------------------------------
" vim: ts=4 nowrap
