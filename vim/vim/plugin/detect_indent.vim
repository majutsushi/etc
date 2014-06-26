" Try to automatically detect indent settings
" Based on https://github.com/tpope/vim-sleuth by Tim Pope
" License: Vim license

if exists("g:loaded_detect_indent") || v:version < 700 || &cp
    finish
endif
let g:loaded_detect_indent = 1

function! s:guess(lines) abort
    let options = {}
    let heuristics = {'spaces': 0, 'tabs': 0}
    let ccomment = 0
    let podcomment = 0
    let triplequote = 0

    for line in a:lines

        if line =~# '^\s*$'
            continue
        endif

        " Lines with mixed indent are unreliable
        if line =~# ' ' && line =~# '\t'
            continue
        endif

        if line =~# '^\s*/\*'
            let ccomment = 1
        endif
        if ccomment
            if line =~# '\*/'
                let ccomment = 0
            endif
            continue
        endif

        if line =~# '^=\w'
            let podcomment = 1
        endif
        if podcomment
            if line =~# '^=\%(end\|cut\)\>'
                let podcomment = 0
            endif
            continue
        endif

        if triplequote
            if line =~# '^[^"]*"""[^"]*$'
                let triplequote = 0
            endif
            continue
        elseif line =~# '^[^"]*"""[^"]*$'
            let triplequote = 1
        endif

        if line =~# '^\t'
            let heuristics.tabs += 1
        endif
        if line =~# '^  '
            let heuristics.spaces += 1
        endif
        let indent = len(matchstr(line, '^ *'))
        if indent >= 1 && get(options, 'shiftwidth', 99) > indent
            let options.shiftwidth = indent
        endif

    endfor

    if heuristics.tabs && heuristics.spaces
        let options.expandtab = heuristics.spaces > heuristics.tabs
        let options.tabstop = options.shiftwidth
    elseif heuristics.spaces
        let options.expandtab = 1
    elseif heuristics.tabs
        return {'expandtab': 0, 'shiftwidth': &tabstop}
    endif

    return options
endfunction

function! s:patterns_for(type) abort
    if a:type ==# ''
        return []
    endif
    if !exists('s:patterns')
        redir => capture
        silent autocmd BufRead
        redir END
        let patterns = {
                    \ 'c': ['*.c'],
                    \ 'html': ['*.html'],
                    \ 'sh': ['*.sh'],
                    \ }
        let setfpattern = '\s\+\%(setf\%[iletype]\s\+\|set\%[local]\s\+\%(ft\|filetype\)=\|call SetFileTypeSH(["'']\%(ba\|k\)\=\%(sh\)\@=\)'
        for line in split(capture, "\n")
            let match = matchlist(line, '^\s*\(\S\+\)\='.setfpattern.'\(\w\+\)')
            if !empty(match)
                call extend(patterns, {match[2]: []}, 'keep')
                call extend(patterns[match[2]], [match[1] ==# '' ? last : match[1]])
            endif
            let last = matchstr(line, '\S.*')
        endfor
        let s:patterns = patterns
    endif
    return copy(get(s:patterns, a:type, []))
endfunction

function! s:apply_if_ready(options) abort
    if !has_key(a:options, 'expandtab') || !has_key(a:options, 'shiftwidth')
        return 0
    else
        for [option, value] in items(a:options)
            call setbufvar('', '&' . option, value)
        endfor
        return 1
    endif
endfunction

function! s:detect() abort
    " The help functionality seems to call FileType/modeline in a strange order
    if &buftype == 'help'
        return
    endif
    let options = s:guess(getline(1, 1024))
    if s:apply_if_ready(options)
        return
    endif
    let patterns = s:patterns_for(&filetype)
    call filter(patterns, 'v:val !~# "/"')
    let dir = expand('%:p:h')
    while isdirectory(dir) && dir !=# fnamemodify(dir, ':h')
        for pattern in patterns
            for neighbour in split(glob(dir . '/' . pattern), "\n")[0:7]
                if neighbour !=# expand('%:p') && filereadable(neighbour)
                    call extend(options, s:guess(readfile(neighbour, '', 256)), 'keep')
                endif
                if s:apply_if_ready(options)
                    let b:detect_indent_culprit = neighbour
                    return
                endif
            endfor
        endfor
        let dir = fnamemodify(dir, ':h')
    endwhile
    if has_key(options, 'shiftwidth')
        return s:apply_if_ready(extend({'expandtab': 1}, options))
    endif
endfunction

setglobal smarttab

if !exists('g:did_indent_on')
    filetype indent on
endif

command -nargs=0 DetectIndent call s:detect()

augroup detect_indent
    autocmd!
    autocmd FileType * call s:detect()
augroup END
