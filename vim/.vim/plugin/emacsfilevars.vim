" emacsfilevars.vim -- Read emacs file variables and set corresponding vim options
"
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2010-11-27 18:01:38 +1300 NZDT
"
" based on http://www.vim.org/scripts/script.php?script_id=874

if exists("loaded_emacsfilevars")
    finish
endif

let loaded_emacsfilevars = 1

if !exists("g:emacs_no_mode")
    let g:emacs_no_mode = 0
endif

function ReadEmacsFileVars()
    if !exists("b:emacs_no_mode")
        let b:emacs_no_mode = 0
    endif

    let l:modeMappings = { 'C++': 'cpp',
                         \ 'c++': 'cpp'}
    let l:boolMappings = { 'nil'  : 0,
                         \ 'false': 0,
                         \ 'off'  : 0,
                         \ 'true' : 1,
                         \ 'on'   : 1}

    let l:i = 1
    " file vars can be in the first 600 bytes
    let l:byteLine = byte2line(600)

    while i < l:byteLine + 1
        let l:line = getline(i)

        if l:line =~ '-\*-.\+-\*-'
            let l:lineContent = substitute(l:line, '.*-\*-\s*\(.\{-}\)\s*-\*-.*', '\1', '')
            let l:vars        = split(l:lineContent, ';')

            for l:var in l:vars
                let l:varsplit = split(l:var, ':')
                let l:key      = substitute(l:varsplit[0], '\s*\(.*\)\s*', '\1', '')
                let l:value    = substitute(l:varsplit[1], '\s*\(.*\)\s*', '\1', '')

                if l:key ==? 'mode'
                    if !b:emacs_no_mode && !g:emacs_no_mode
                        if has_key(l:modeMappings, l:value)
                            exec "set ft=" . l:modeMappings[l:value]
                        endif
                    endif
                elseif l:key ==? 'tab-width'
                    exec "setlocal tabstop=" . l:value
                elseif l:key ==? 'c-basic-offset'
                    exec "setlocal shiftwidth=" . l:value
                    exec "setlocal softtabstop=" . l:value
                elseif l:key ==? 'indent-tabs-mode'
                    if l:boolMappings[l:value]
                        setlocal noexpandtab
                    else
                        setlocal expandtab
                    endif
                else
                    echo "Unknown option: " . l:key
                endif
            endfor

            break
        endif

        let l:i = l:i + 1
    endwhile
endfunction

autocmd BufRead * call ReadEmacsFileVars()
