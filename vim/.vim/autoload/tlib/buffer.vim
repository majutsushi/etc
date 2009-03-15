" buffer.vim
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2007-11-16.
" @Revision:    0.0.238

if &cp || exists("loaded_tlib_buffer_autoload")
    finish
endif
let loaded_tlib_buffer_autoload = 1


" Set the buffer to buffer and return a command as string that can be 
" evaluated by |:execute| in order to restore the original view.
function! tlib#buffer#Set(buffer) "{{{3
    let lazyredraw = &lazyredraw
    set lazyredraw
    try
        let cb = bufnr('%')
        let sn = bufnr(a:buffer)
        if sn != cb
            let ws = bufwinnr(sn)
            if ws != -1
                let wb = bufwinnr('%')
                exec ws.'wincmd w'
                return wb.'wincmd w'
            else
                silent exec 'sbuffer! '. sn
                return 'wincmd c'
            endif
        else
            return ''
        endif
    finally
        let &lazyredraw = lazyredraw
    endtry
endf


" :def: function! tlib#buffer#Eval(buffer, code)
" Evaluate CODE in BUFFER.
"
" EXAMPLES: >
"   call tlib#buffer#Eval('foo.txt', 'echo b:bar')
function! tlib#buffer#Eval(buffer, code) "{{{3
    " let cb = bufnr('%')
    " let wb = bufwinnr('%')
    " " TLogVAR cb
    " let sn = bufnr(a:buffer)
    " let sb = sn != cb
    let lazyredraw = &lazyredraw
    set lazyredraw
    let restore = tlib#buffer#Set(a:buffer)
    try
        exec a:code
        " if sb
        "     let ws = bufwinnr(sn)
        "     if ws != -1
        "         try
        "             exec ws.'wincmd w'
        "             exec a:code
        "         finally
        "             exec wb.'wincmd w'
        "         endtry
        "     else
        "         try
        "             silent exec 'sbuffer! '. sn
        "             exec a:code
        "         finally
        "             wincmd c
        "         endtry
        "     endif
        " else
        "     exec a:code
        " endif
    finally
        exec restore
        let &lazyredraw = lazyredraw
    endtry
endf


" :def: function! tlib#buffer#GetList(?show_hidden=0, ?show_number=0)
function! tlib#buffer#GetList(...)
    TVarArg ['show_hidden', 0], ['show_number', 0]
    let ls_bang = show_hidden ? '!' : ''
    redir => bfs
    exec 'silent ls'. ls_bang
    redir END
    let buffer_list = split(bfs, '\n')
    let buffer_nr = map(copy(buffer_list), 'matchstr(v:val, ''\s*\zs\d\+\ze'')')
    " TLogVAR buffer_list
    if show_number
        call map(buffer_list, 'matchstr(v:val, ''\s*\d\+.\{-}\ze\s\+line \d\+\s*$'')')
    else
        call map(buffer_list, 'matchstr(v:val, ''\s*\d\+\zs.\{-}\ze\s\+line \d\+\s*$'')')
    endif
    " TLogVAR buffer_list
    " call map(buffer_list, 'matchstr(v:val, ''^.\{-}\ze\s\+line \d\+\s*$'')')
    " TLogVAR buffer_list
    call map(buffer_list, 'matchstr(v:val, ''^[^"]\+''). printf("%-20s   %s", fnamemodify(matchstr(v:val, ''"\zs.\{-}\ze"$''), ":t"), fnamemodify(matchstr(v:val, ''"\zs.\{-}\ze"$''), ":h"))')
    " TLogVAR buffer_list
    return [buffer_nr, buffer_list]
endf


" :def: function! tlib#buffer#ViewLine(line, ?position='z')
" line is either a number or a string that begins with a number.
" For possible values for position see |scroll-cursor|.
" See also |g:tlib_viewline_position|.
function! tlib#buffer#ViewLine(line, ...) "{{{3
    if a:line
        TVarArg 'pos'
        let ln = matchstr(a:line, '^\d\+')
        let lt = matchstr(a:line, '^\d\+: \zs.*')
        " TLogVAR pos, ln, lt
        exec ln
        if empty(pos)
            let pos = tlib#var#Get('tlib_viewline_position', 'wbg')
        endif
        " TLogVAR pos
        if !empty(pos)
            exec 'norm! '. pos
        endif
        let @/ = '\%'. ln .'l.*'
    endif
endf


function! tlib#buffer#HighlightLine(line) "{{{3
    exec 'match MatchParen /\V\%'. a:line .'l.*/'
endf


" Delete the lines in the current buffer. Wrapper for |:delete|.
function! tlib#buffer#DeleteRange(line1, line2) "{{{3
    exec a:line1.','.a:line2.'delete'
endf


" Replace a range of lines.
function! tlib#buffer#ReplaceRange(line1, line2, lines)
    call tlib#buffer#DeleteRange(a:line1, a:line2)
    call append(a:line1 - 1, a:lines)
endf


" Initialize some scratch area at the bottom of the current buffer.
function! tlib#buffer#ScratchStart() "{{{3
    norm! Go
    let b:tlib_inbuffer_scratch = line('$')
    return b:tlib_inbuffer_scratch
endf


" Remove the in-buffer scratch area.
function! tlib#buffer#ScratchEnd() "{{{3
    if !exists('b:tlib_inbuffer_scratch')
        echoerr 'tlib: In-buffer scratch not initalized'
    endif
    call tlib#buffer#DeleteRange(b:tlib_inbuffer_scratch, line('$'))
    unlet b:tlib_inbuffer_scratch
endf


" Run exec on all buffers via bufdo and return to the original buffer.
function! tlib#buffer#BufDo(exec) "{{{3
    let bn = bufnr('%')
    exec 'bufdo '. a:exec
    exec 'buffer! '. bn
endf


" :def: function! tlib#buffer#InsertText(text, keyargs)
" Keyargs:
"   'shift': 0|N
"   'col': col('.')|N
"   'lineno': line('.')|N
"   'indent': 0|1
"   'pos': 'e'|'s' ... Where to locate the cursor (somewhat like s and e in {offset})
" Insert text (a string) in the buffer.
function! tlib#buffer#InsertText(text, ...) "{{{3
    TVarArg ['keyargs', {}]
    TKeyArg keyargs, ['shift', 0], ['col', col('.')], ['lineno', line('.')], ['pos', 'e'],
                \ ['indent', 0]
    " TLogVAR shift, col, lineno, pos, indent
    let line = getline(lineno)
    if col + shift > 0
        let pre  = line[0 : (col - 1 + shift)]
        let post = line[(col + shift): -1]
    else
        let pre  = ''
        let post = line
    endif
    " TLogVAR lineno, line, pre, post
    let text0 = pre . a:text . post
    let text  = split(text0, '\n', 1)
    " TLogVAR text
    let icol = len(pre)
    " exec 'norm! '. lineno .'G'
    call cursor(lineno, col)
    if indent && col > 1
		if &fo =~# '[or]'
			" This doesn't work because it's not guaranteed that the 
			" cursor is set.
			let cline = getline('.')
			norm! a
			"norm! o
			" TAssertExec redraw | sleep 3
			let idt = strpart(getline('.'), 0, col('.') + shift)
			" TLogVAR idt
			let idtl = len(idt)
			-1,.delete
			" TAssertExec redraw | sleep 3
			call append(lineno - 1, cline)
			call cursor(lineno, col)
			" TAssertExec redraw | sleep 3
			if idtl == 0 && icol != 0
				let idt = matchstr(pre, '^\s\+')
				let idtl = len(idt)
			endif
		else
			let [m_0, idt, iline; rest] = matchlist(pre, '^\(\s*\)\(.*\)$')
			let idtl = len(idt)
		endif
		if idtl < icol
			let idt .= repeat(' ', icol - idtl)
		endif
        " TLogVAR idt
        for i in range(1, len(text) - 1)
            let text[i] = idt . text[i]
        endfor
        " TLogVAR text
    endif
    " exec 'norm! '. lineno .'Gdd'
    norm! dd
    call append(lineno - 1, text)
    let tlen = len(text)
    let posshift = matchstr(pos, '\d\+')
    if pos =~ '^e'
        exec lineno + tlen - 1
        exec 'norm! 0'. (len(text[-1]) - len(post) + posshift - 1) .'l'
    elseif pos =~ '^s'
        exec lineno
        exec 'norm! '. len(pre) .'|'
        if !empty(posshift)
            exec 'norm! '. posshift .'h'
        endif
    endif
    " TLogDBG string(getline(1, '$'))
endf


function! tlib#buffer#InsertText0(text, ...) "{{{3
    TVarArg ['keyargs', {}]
    let mode = get(keyargs, 'mode', 'i')
    " TLogVAR mode
    if !has_key(keyargs, 'shift')
        let col = col('.')
        " if mode =~ 'i'
        "     let col += 1
        " endif
        let keyargs.shift = col >= col('$') ? 0 : -1
        " let keyargs.shift = col('.') >= col('$') ? 0 : -1
        " TLogVAR col
        " TLogDBG col('.') .'-'. col('$') .': '. string(getline('.'))
    endif
    " TLogVAR keyargs.shift
    return tlib#buffer#InsertText(a:text, keyargs)
endf


function! tlib#buffer#CurrentByte() "{{{3
    return line2byte(line('.')) + col('.')
endf

