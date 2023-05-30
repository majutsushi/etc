" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11
"
" Syntax (Django/Jinja-like):
"   {% ex command %}
"       {%+ ex command %} Dont' remove leading whitespace
"       {% ex command +%} Dont' remove trailing whitespace
"   {{ expression }} At least one space around the expression is mandatory.
"   Variables have to be script-local (s:foo) variables.
"       Variables starting with '__' are reserved.

if &compatible || exists("g:loaded_templates")
    finish
endif
let g:loaded_templates = 1

function! s:load_template() abort
    if &filetype == ''
        return
    endif

    let defaults = split(globpath(&runtimepath, 'templates/' . &filetype . '.template'), '\n')

    if empty(defaults)
        return
    endif

    silent! execute 'keepalt 0read ' . defaults[0]

    let report_save = &report
    set report=99999

    try
        %substitute/\(\s*\){%\(\S*\)\_s\+\(\_.\{-}\)\_s*\(\S*\)%}\(\s*\n\?\)/\=s:exec(submatch(1), submatch(2), submatch(3), submatch(4), submatch(5))/ge
        %substitute/{{\s\+\(.\{-}\)\s\+}}/\=eval(submatch(1))/ge
    finally
        let &report = report_save
    endtry
    set nomodified

    " Remove template variables from the script namespace
    call filter(s:, 'v:key =~# "^__"')

    normal! G
endfunction

function! s:exec(prews, preflags, cmd, postflags, postws) abort
    execute a:cmd

    return (a:preflags !~# '+' ? '' : a:prews) . (a:postflags !~# '+' ? '' : a:postws)
endfunction

augroup templates
    autocmd!
    autocmd FileType * if line('$') == 1 && getline(1) == '' | call s:load_template() | endif
augroup END
