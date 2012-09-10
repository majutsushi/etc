" emacsfilevars.vim -- Read emacs file variables and set corresponding vim options
"
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2010-11-27 18:01:38 +1300 NZDT
"
" Emacs manual:
" https://www.gnu.org/software/emacs/manual/html_node/emacs/Specifying-File-Variables.html

if exists("loaded_emacsfilevars")
    finish
endif

let loaded_emacsfilevars = 1

if !exists("g:emacs_no_mode")
    let g:emacs_no_mode = 0
endif

" Option functions {{{1
let s:optiondict = {}

" s:optiondict.mode() {{{2
function! s:optiondict.mode(val) dict
    let value = tolower(a:val)
    if !b:emacs_no_mode && !g:emacs_no_mode
        if has_key(s:modeMappings, value)
            execute 'set filetype=' . s:modeMappings[value]
        else
            execute 'set filetype=' . value
        endif
    endif
endfunction

" s:optiondict.buffer_read_only() {{{2
function! s:optiondict.buffer_read_only(val) dict
    if s:boolMappings[a:val]
        setlocal readonly
    else
        setlocal noreadonly
    endif
endfunction

" s:optiondict.c_basic_offset() {{{2
function! s:optiondict.c_basic_offset(val) dict
    execute 'setlocal shiftwidth=' . a:val
    execute 'setlocal softtabstop=' . a:val
endfunction

" s:optiondict.fill_column() {{{2
function! s:optiondict.fill_column(val) dict
    execute 'setlocal textwidth=' . a:val
endfunction

" s:optiondict.indent_tabs_mode() {{{2
function! s:optiondict.indent_tabs_mode(val) dict
    if s:boolMappings[a:val]
        setlocal noexpandtab
    else
        setlocal expandtab
    endif
endfunction

" s:optiondict.tab_width() {{{2
function! s:optiondict.tab_width(val) dict
    execute 'setlocal tabstop=' . a:val
endfunction
" s:optiondict.coding() {{{2
" file encoding can't be changed in vim after a file has been loaded
function! s:optiondict.coding(val) abort dict
endfunction

" Mappings {{{1
let s:modeMappings = {
    \ 'c++' : 'cpp'
\ }
let s:boolMappings = {
    \ 'nil'   : 0,
    \ 'false' : 0,
    \ 'off'   : 0,
    \ 'true'  : 1,
    \ 'on'    : 1
\ }

" s:ParseEmacsFileVars {{{1
function s:ParseEmacsFileVars(fname)
    if ! &modeline
        return
    endif

    if !exists("b:emacs_no_mode")
        let b:emacs_no_mode = 0
    endif

    call s:ParseFileVarLine()

    call s:ParseLocalVarList(a:fname)
endfunction

" s:ParseFileVarLine() {{{1
function! s:ParseFileVarLine()
    let pattern = '.*-\*-\s*\(.\{-}\)\s*-\*-.*'

    " file variables can be in first two lines
    for linenr in [1, 2]
        let line = getline(linenr)

        if line =~ pattern
            let lineContent = substitute(line, pattern, '\1', '')
            let vars        = split(lineContent, ';')

            for var in vars
                call s:HandleVar(var)
            endfor

            break
        endif
    endfor
endfunction

" s:ParseLocalVarList() {{{1
function! s:ParseLocalVarList(fname)
    " local variables can be in the last 3000 characters (assuming one-byte
    " characters here for simplicity)
    let fsize = getfsize(a:fname)
    if fsize <= 3000
        let startline = 1
    else
        let startline = byte2line(fsize - 3000)
    endif

    let save_cursor = getpos('.')

    call cursor(startline, 1)
    let startline = search('.*Local Variables:.*', 'cW')
    if startline == 0
        call setpos('.', save_cursor)
        return
    endif

    " Extract surrounding comment characters
    let surround = matchlist(getline(startline),
                           \ '\(.*\)\s*Local Variables:\s*\(.*\)')
    let s = escape(surround[1], '\')
    let e = escape(surround[2], '\')

    let endline = search('\V' . s . '\s\*End:\s\*' . e, 'nW')
    call setpos('.', save_cursor)

    for linenr in range(startline + 1, endline - 1)
        let var = substitute(getline(linenr),
                           \ '\V' . s . '\s\*\(\S\+\)\s\*' . e, '\1', '')
        call s:HandleVar(var)
    endfor
endfunction

" s:SplitVar() {{{1
function! s:SplitVar(var)
    let varsplit = split(a:var, ':')

    " 'mode' can be given without explicit name
    if len(varsplit) < 2
        call insert(varsplit, 'mode')
    endif

    let key   = s:strip(varsplit[0])
    let value = s:strip(varsplit[1])

    return [key, value]
endfunction

" s:HandleVar() {{{1
function! s:HandleVar(var)
    let [key, value] = s:SplitVar(a:var)
    let key = substitute(tolower(key), '-', '_', 'g')

    if has_key(s:optiondict, key)
        call call(s:optiondict[key], [value], s:optiondict)
    else
        echomsg "Unknown option: " . key
    endif
endfunction

" s:strip() {{{1
function! s:strip(string)
    return substitute(a:string, '\s*\(.*\)\s*', '\1', '')
endfunction

" Autocommands {{{1
autocmd BufReadPost * call s:ParseEmacsFileVars(fnamemodify(expand('<afile>'), ':p'))

" Modeline {{{1
" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
