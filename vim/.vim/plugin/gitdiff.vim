" gitdiff.vim : git helper functions
" http://www.vim.org/scripts/script.php?script_id=1846
"
" Author:   Bart Trojanowski <bart@jukie.net>
" Date:     2007/05/02
" Version:  2
" 
" GetLatestVimScripts: 1846 1 :AutoInstall: gitdiff.vim

"------------------------------------------------------------------------
"
" This script currently installs two new functions:
"
" :GITDiff [rev]
"
"    Vertical split with working buffer, showing vimdiff between current
"    buffer and a commit.
"
" :GITChanges [rev]
"
"    Highlights modified lines in current buffer.
"    Disable with :syntax on
"
"------------------------------------------------------------------------

if exists("loaded_gitdiff") || &compatible
    finish
endif
let loaded_gitdiff = 1

"" ------------------------------------------------------------------------
" based on svndiff from...
" http://www.axisym3.net/jdany/vim-the-editor/
"" ------------------------------------------------------------------------

command! -nargs=? GITDiff :call s:GitDiff(<f-args>)

function! s:GitDiff(...)
    if a:0 == 1
        let rev = a:1
    else
        let rev = 'HEAD'
    endif

    let ftype = &filetype

    let prefix = system("git rev-parse --show-prefix")
    let thisfile = substitute(expand("%"),getcwd(),'','')
    let gitfile = substitute(prefix,'\n$','','') . thisfile

    " Check out the revision to a temp file
    let tmpfile = tempname()
    let cmd = "git show  " . rev . ":" . gitfile . " > " . tmpfile
    let cmd_output = system(cmd)
    if v:shell_error && cmd_output != ""
        echohl WarningMsg | echon cmd_output
        return
    endif

    " Begin diff
    exe "vert diffsplit" . tmpfile
    exe "set filetype=" . ftype
    set foldmethod=diff
    wincmd l

endfunction

"" ------------------------------------------------------------------------
"" this block is taken from svndiff.vim
"" http://www.vim.org/scripts/script.php?script_id=1881#1.0
"" by Zevv Ico
"" ------------------------------------------------------------------------

command! -nargs=? GITChanges :call s:GitChanges(<f-args>)

function! s:GitChanges(...)
  
  if a:0 == 1
    let rev = a:1
  else
    let rev = 'HEAD'
  endif

	" Check if this file is managed by git, exit otherwise

  let prefix = system("git rev-parse --show-prefix")
  let thisfile = substitute(expand("%"),getcwd(),'','')
  let gitfile = substitute(prefix,'\n$','','') . thisfile
	
	" Reset syntax highlighting
	
	syntax off

	" Pipe the current buffer contents to a shell command calculating the diff
	" in a friendly parsable format

	let contents = join(getbufline("%", 1, "$"), "\n")
	let diff = system("diff -u0 <(git show " . rev . ":" . gitfile . ") <(cat;echo)", contents)

	" Parse the output of the diff command and hightlight changed, added and
	" removed lines

	for line in split(diff, '\n')
		
    let part = matchlist(line, '@@ -\([0-9]*\),*\([0-9]*\) +\([0-9]*\),*\([0-9]*\) @@')

		if ! empty(part)
			let old_from  = part[1]
			let old_count = part[2] == '' ? 1 : part[2]
			let new_from  = part[3]
			let new_count = part[4] == '' ? 1 : part[4]

			" Figure out if text was added, removed or changed.
			
			if old_count == 0
				let from  = new_from
				let to    = new_from + new_count - 1
				let group = 'DiffAdd'
			elseif new_count == 0
				let from  = new_from
				let to    = new_from + 1
				let group = 'DiffDelete'
			else
				let from  = new_from
				let to    = new_from + new_count - 1
				let group = 'DiffChange'
			endif

			" Set the actual syntax highlight
			
			exec 'syntax region ' . group . ' start=".*\%' . from . 'l" end=".*\%' . to . 'l"'

		endif

	endfor

endfunction


" vi: ts=2 sw=2

