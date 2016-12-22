"#########################################################################
"# ftplugin/otl.vim: VimOutliner functions, commands and settings
"# version 0.3.0
"#   Copyright (C) 2001,2003 by Steve Litt (slitt@troubleshooters.com)
"#   Copyright (C) 2004 by Noel Henson (noel@noels-lab.com)
"#
"#   This program is free software; you can redistribute it and/or modify
"#   it under the terms of the GNU General Public License as published by
"#   the Free Software Foundation; either version 2 of the License, or
"#   (at your option) any later version.
"#
"#   This program is distributed in the hope that it will be useful,
"#   but WITHOUT ANY WARRANTY; without even the implied warranty of
"#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"#   GNU General Public License for more details.
"#
"#   You should have received a copy of the GNU General Public License
"#   along with this program; if not, write to the Free Software
"#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
"#
"# Steve Litt, slitt@troubleshooters.com, http://www.troubleshooters.com
"#########################################################################

" User Preferences {{{1

let maplocalleader = ",,"       " this is prepended to OTL key mappings

" End User Preferences

" VimOutliner Standard Settings {{{1
setlocal autoindent
setlocal wrapmargin=5
setlocal wrap!
setlocal textwidth=78
setlocal noexpandtab
setlocal nosmarttab
setlocal softtabstop=0
setlocal foldlevel=20
setlocal foldcolumn=1       " turns on "+" at the begining of close folds
setlocal tabstop=4          " tabstop and shiftwidth must match
setlocal shiftwidth=4
setlocal fillchars=|,
setlocal foldmethod=expr
setlocal foldexpr=OTLFoldLevel(v:lnum)
setlocal foldtext=OTLFoldText()
setlocal foldenable
setlocal indentexpr=
setlocal nocindent
setlocal iskeyword=@,39,45,48-57,_,129-255

setlocal formatoptions-=t formatoptions+=crqno
setlocal comments=sO:\:\ -,mO:\:\ \ ,eO:\:\:,:\:,sO:\>\ -,mO:\>\ \ ,eO:\>\>,:\>


" Vim Outliner Functions {{{1

" Determine the indent level of a line.
function! s:indent(line) abort
    return indent(a:line) / &tabstop
endfunction

function! s:is_parent(line) abort
    return s:indent(a:line) + 1 == s:indent(a:line + 1)
endfunction

function! s:shift_right() abort
    let curline = line(".")
    if (foldclosed(curline) == -1) && s:is_parent(curline)
        normal! zc
        let fold_cursor = getpos(".")
        normal! >>
        let get_cursor = getpos(".")
        call setpos('.', fold_cursor)
        normal! zo
        call setpos('.', get_cursor)
    else
        normal! >>
    endif
endfunction

function! s:shift_left() abort
    let curline = line(".")
    if (foldclosed(curline) == -1) && s:is_parent(curline)
        normal! zc
        let fold_cursor = getpos(".")
        normal! <<
        let get_cursor = getpos(".")
        call setpos('.', fold_cursor)
        normal! zo
        call setpos('.', get_cursor)
    else
        normal! << 
    endif
endfunction


" OTLFoldLevel(Line) {{{2
function! s:is_body_text(line) abort
    return match(getline(a:line),"^\t*:") == 0
endfunction
function! s:is_preformatted_body_text(line) abort
    return match(getline(a:line),"^\t*;") == 0
endfunction
function! s:is_preformatted_user_text(line) abort
    return match(getline(a:line),"^\t*<") == 0
endfunction
function! s:is_preformatted_user_text_labeled(line) abort
    return match(getline(a:line),"^\t*<\S") == 0
endfunction
function! s:is_preformatted_user_text_space(line) abort
    return match(getline(a:line),"^\t*< ") == 0
endfunction
function! s:is_user_text(line) abort
    return match(getline(a:line),"^\t*>") == 0
endfunction
function! s:is_user_text_space(line) abort
    return match(getline(a:line),"^\t*> ") == 0
endfunction
function! s:is_user_text_labeled(line) abort
    return match(getline(a:line),"^\t*>\S") == 0
endfunction
function! s:is_preformatted_table(line) abort
    return match(getline(a:line),"^\t*|") == 0
endfunction

function! OTLFoldLevel(line) abort
    let myindent = s:indent(a:line)
    let nextindent = s:indent(a:line + 1)

    if s:is_body_text(a:line)
        if !s:is_body_text(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_body_text(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    elseif s:is_preformatted_body_text(a:line)
        if !s:is_preformatted_body_text(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_preformatted_body_text(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    elseif s:is_preformatted_table(a:line)
        if !s:is_preformatted_table(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_preformatted_table(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    elseif s:is_preformatted_user_text(a:line)
        if !s:is_preformatted_user_text(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_preformatted_user_text_space(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    elseif s:is_preformatted_user_text_labeled(a:line)
        if !s:is_preformatted_user_text_labeled(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_preformatted_user_text(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    elseif s:is_user_text(a:line)
        if !s:is_user_text(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_user_text_space(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    elseif s:is_user_text_labeled(a:line)
        if !s:is_user_text_labeled(a:line - 1)
            return '>' . (myindent + 1)
        endif
        if !s:is_user_text(a:line + 1)
            return '<' . (myindent + 1)
        endif
        return myindent + 1
    else
        if myindent < nextindent
            return '>' . (myindent + 1)
        endif
        if myindent > nextindent
            return myindent
        endif
        return myindent
    endif
endfunction
"}}}2

" OTLFoldText() {{{2
" Create string used for folded text blocks
function! OTLFoldText() abort
    let pad_left = repeat(' ', &sw)
    let line = getline(v:foldstart)
    let bodyTextFlag = 0
    if line =~ "^\t* \\S" || line =~ "^\t*\:"
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[TEXT]"
    elseif line =~ "^\t*\;"
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[TEXT BLOCK]"
    elseif line =~ "^\t*\> "
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[USER]"
    elseif line =~ "^\t*\>"
        let ls = stridx(line, ">")
        let le = stridx(line, " ")
        if le == -1
            let l = strpart(line, ls + 1)
        else
            let l = strpart(line, ls + 1, le - ls - 1)
        endif
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[USER " . l . "]"
    elseif line =~ "^\t*\< "
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[USER BLOCK]"
    elseif line =~ "^\t*\<"
        let ls = stridx(line, "<")
        let le = stridx(line, " ")
        if le == -1
            let l = strpart(line, ls + 1)
        else
            let l = strpart(line, ls + 1, le - ls - 1)
        endif
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[USER BLOCK " . l . "]"
    elseif line =~ "^\t*\|"
        let bodyTextFlag = 1
        let pad_left = repeat(' ', &sw * (v:foldlevel - 1))
        let line = pad_left . "[TABLE]"
    endif
    let sub = substitute(line, '\t', pad_left, 'g')
    let len = strlen(sub)
    let sub = sub . " " . repeat('-', 58 - len)
    let sub = sub . " (" . ((v:foldend + bodyTextFlag) - v:foldstart)
    if ((v:foldend + bodyTextFlag) - v:foldstart) == 1
        let sub = sub . " line)"
    else
        let sub = sub . " lines)"
    endif
    return sub
endfunction
"}}}2

" Checkboxes {{{2
" Insert a checkbox at the beginning of a header without disturbing the
" current folding only if there is no checkbox already.
function! s:insert_checkbox()
    if match(getline("."), "^\t\t*\[<>:;|\]") != -1
        return
    endif
    if match(getline("."), "[\[X \]]") == -1
        let curline = line('.')
        call setline(curline, substitute(getline(curline), '\v^(\s*)(.*)', '\1[ ] \2', ''))
    endif
endfunction

" Insert a checkbox and % sign at the beginning of a header without disturbing
" the current folding only if there is no checkbox already.
function! s:insert_checkbox_percent()
    if match(getline("."), "^\t\t*\[<>:;|\]") != -1
        return
    endif
    if match(getline("."), "[\[X \]]") == -1
        let curline = line('.')
        call setline(curline, substitute(getline(curline), '\v^(\s*)(.*)', '\1[ ] % \2', ''))
    endif
endfunction

" Switch the state of the checkbox on the current line.
function! s:switch_box()
    let curline = line('.')
    if stridx(getline('.'), '[ ]') != -1
        call setline(curline, substitute(getline(curline), '\[ \]', '[X]', ''))
    elseif stridx(getline('.'), '[X]') != -1
        call setline(curline, substitute(getline(curline), '\[X\]', '[ ]', ''))
    endif
endfunction

" Delete a checkbox if one exists
function! s:delete_checkbox()
    let curline = line('.')
    call setline(curline, substitute(getline(curline), '\[[ X]\] ', '', ''))
endfunction

" returns the line number of the root parent for any child
function! s:find_root_parent(line)
    for curline in range(a:line, 1, -1)
        if s:indent(curline) == 0
            return curline
        endif
    endfor

    return 1
endf

" (How Many Done)
" Calculates proportion of already done work in the subtree
function! s:new_hmd(line)
    let done = 0
    let counted_lines = 0

    let i = 1
    while s:indent(a:line) < s:indent(a:line + i)
        if (s:indent(a:line) + 1) == (s:indent(a:line + i))
            let childdoneness = s:new_hmd(a:line + i)
            if childdoneness >= 0
                let done += childdoneness
                let counted_lines += 1
            endif
        endif
        let i += 1
    endwhile

    let proportion = 0
    if counted_lines > 0
        let proportion = ((done * 100) /counted_lines) / 100
    else
        if match(getline(a:line), "\\[X\\]") != -1
            let proportion = 100
        else
            let proportion = 0
        endif
    endif

    call setline(a:line, substitute(getline(a:line), " [0-9]*%", " " . proportion . "%", ""))

    if proportion == 100
        call setline(a:line, substitute(getline(a:line), "\\[.\\]", "[X]", ""))
        return 100
    elseif proportion == 0 && counted_lines == 0
        if match(getline(a:line), "\\[X\\]") != -1
            return 100
        elseif match(getline(a:line), "\\[ \\]") != -1
            return 0
        else
            return -1
        endif
    else
        call setline(a:line, substitute(getline(a:line), "\\[.\\]", "[ ]", ""))
        return proportion
    endif
endf
"}}}2


"   First, convert document to the marker style
nnoremap <script> <silent> <buffer> <localleader>b :%s/\(^\t*\):/\1/e<cr>:%s/\(^\t*\) /\1: /e<cr>:let @/=""<cr>
"   Now, convert document to the space style
nnoremap <script> <silent> <buffer> <localleader>B :%s/\(^\t*\):/\1/e<cr>:let @/=""<cr>

nnoremap <script> <silent> <buffer> >> :call <SID>shift_right()<CR>
nnoremap <script> <silent> <buffer> << :call <SID>shift_left()<CR>

" insert a chechbox
nnoremap <script> <silent> <buffer> <localleader>cb :call <SID>insert_checkbox()<cr>
nnoremap <script> <silent> <buffer> <localleader>cp :call <SID>insert_checkbox_percent()<cr>

" delete a chechbox
nnoremap <script> <silent> <buffer> <localleader>cd :call <SID>delete_checkbox()<cr>

" switch the status of the box
nnoremap <script> <silent> <buffer> <localleader>cx :call <SID>switch_box()<cr>:call <SID>new_hmd(<SID>find_root_parent(line(".")))<cr>

" calculate the proportion of work done on the subtree
nnoremap <script> <silent> <buffer> <localleader>cz :call <SID>new_hmd(<SID>find_root_parent(line(".")))<cr>

" vim: set foldmethod=marker foldlevel=0:
