" string.vim
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2007-10-02.
" @Revision:    0.0.48

if &cp || exists("loaded_tlib_string_autoload")
    finish
endif
let loaded_tlib_string_autoload = 1


" :def: function! tlib#string#RemoveBackslashes(text, ?chars=' ')
" Remove backslashes from text (but only in front of the characters in 
" chars).
function! tlib#string#RemoveBackslashes(text, ...) "{{{3
    exec tlib#arg#Get(1, 'chars', ' ')
    " TLogVAR chars
    let rv = substitute(a:text, '\\\(['. chars .']\)', '\1', 'g')
    return rv
endf


function! tlib#string#Chomp(string) "{{{3
    return substitute(a:string, '[[:cntrl:][:space:]]*$', '', '')
endf


" This function deviates from |printf()| in certain ways.
" Additional items:
"     %{rx}      ... insert escaped regexp
"     %{fuzzyrx} ... insert typo-tolerant regexp
function! tlib#string#Printf1(format, string) "{{{3
    let n = len(split(a:format, '%\@<!%s', 1)) - 1
    let f = a:format
    if f =~ '%\@<!%{fuzzyrx}'
        let frx = []
        for i in range(len(a:string))
            if i > 0
                let pb = i - 1
            else
                let pb = 0
            endif
            let slice = tlib#rx#Escape(a:string[pb : i + 1])
            call add(frx, '['. slice .']')
            call add(frx, '.\?')
        endfor
        let f = s:RewriteFormatString(f, '%{fuzzyrx}', join(frx, ''))
    endif
    if f =~ '%\@<!%{rx}'
        let f = s:RewriteFormatString(f, '%{rx}', tlib#rx#Escape(a:string))
    endif
    if n == 0
        return substitute(f, '%%', '%', 'g')
    else
        let a = repeat([a:string], n)
        return call('printf', insert(a, f))
    endif
endf


function! s:RewriteFormatString(format, pattern, string) "{{{3
    let string = substitute(a:string, '%', '%%', 'g')
    return substitute(a:format, tlib#rx#Escape(a:pattern), escape(string, '\'), 'g')
endf


function! tlib#string#TrimLeft(string) "{{{3
    return substitute(a:string, '^\s\+', '', '')
endf


function! tlib#string#TrimRight(string) "{{{3
    return substitute(a:string, '\s\+$', '', '')
endf


function! tlib#string#Strip(string) "{{{3
    return tlib#string#TrimRight(tlib#string#TrimLeft(a:string))
endf

