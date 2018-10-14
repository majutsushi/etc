" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

scriptencoding utf-8

function! stl#update() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!stl#update_win(' . nr . ')')
    endfor
endfunction

function! stl#update_win(winnr) abort
    let is_current = a:winnr == winnr()

    let local_stl = getbufvar(winbufnr(a:winnr), 'stl')
    if local_stl !=# ''
        let stl = local_stl
    else
        " let stl = s:column(a:winnr) . 'X'
        let stl  = s:mode(is_current)
        let stl .= (is_current && &paste) ? '(paste) ' : ''
        let stl .= s:filepath(a:winnr, is_current)
        let stl .= s:state(a:winnr)
        let stl .= s:ale_status(a:winnr)

        let stl .= s:filetype(is_current)
        let stl .= s:spell(is_current)
        let stl .= s:git(is_current)

        let stl .= '#[FunctionName] '
        let stl .= '%<'   " Truncate here
        let stl .= s:func_name()

        let stl .= '%= '  " Right align rest

        let stl .= s:fileformat(a:winnr, is_current)
        let stl .= s:fileenc(a:winnr, is_current)
        let stl .= s:bom(is_current)

        let stl .= s:zoomwin()

        let stl .= '#[ExpandTab] '
        let stl .= s:trailing()
        let stl .= s:indent(a:winnr)
        let stl .= '%0*'
    endif

    let stl = substitute(
        \ stl,
        \ '#\[\(\w\+\)\]',
        \ '%#StatusLine' . '\1' . (is_current ? '' : 'NC') . '#',
        \ 'g')

    return stl
endfunction

function! s:column(winnr) abort
    " let width=winwidth(0) - ((&number||&relativenumber) ? &numberwidth : 0) - &foldcolumn - (len(signlist) > 2 ? 2 : 0)
    let ruler_width = winwidth(a:winnr) - getwinvar(a:winnr, '&columns')
    let vc = virtcol('.')
    return repeat(' ', ruler_width - strlen(vc)) . vc
endfunction

function! stl#currenttag() abort
    try
        return tagbar#currenttag('%s', '')
    catch /^Vim\%((\a\+)\)\=:E117/
        " Ignore unknown function error
        return ''
    endtry
endfunction

function! stl#recompute_stl_ts() abort
    if search('\s\+$', 'nw') != 0
        let b:stl_ts_warning = '·'
    else
        let b:stl_ts_warning = ''
    endif
endfunction

" Adapted from
" http://got-ravings.blogspot.com/2008/10/vim-pr0n-statusline-whitespace-flags.html
function! stl#recompute_stl_ws() abort
    let tabs = search('^\t', 'nw') != 0
    let spaces = search('^ ', 'nw') != 0

    if tabs && spaces
        let b:stl_ws_warning = 'mixed'
    " elseif (spaces && !&et) || (tabs && &et)
    "     let b:stl_ws_warning = 'wrong'
    else
        let b:stl_ws_warning = ''
    endif
endfunction

function! s:mode(is_current) abort
    if !a:is_current
        return ''
    endif

    let rv = ''

    let mode = substitute(mode(), '', '^V', 'g')
    if index(['i', 'R'], mode) >= 0
        let rv .= '#[ModeInsert]'
    else
        let rv .= '#[ModeNormal]'
    endif
    let rv .= ' ' . mode . ' '

    return rv
endfunction

function! s:filepath(winnr, is_current) abort
    let rv = '#[FilePath] '

    let buftype = getwinvar(a:winnr, '&buftype')
    let bufname = bufname(winbufnr(a:winnr))

    if buftype !=# 'help' && buftype !=# 'quickfix' && bufname !=# ''
        let path = fnamemodify(bufname, ':p:~:.')
        if winwidth(0) - len(path) < 65
            let path = pathshorten(path)
        endif
        let path = fnamemodify(path, ':h')
        if path !=# '.'
            let rv .= path . '/'
        endif
    endif

    let rv .= '#[FileName]'

    if buftype ==# 'help'
        let rv .= fnamemodify(bufname, ':p:t')
    elseif buftype ==# 'quickfix'
        let rv .= '[Quickfix List]'
    elseif bufname ==# ''
        let rv .= '[No Name]'
    else
        let filename = fnamemodify(bufname, ':p:~:.')
        if winwidth(0) - len(filename) < 65
            let filename = pathshorten(filename)
        endif
        let rv .= fnamemodify(filename, ':t')
    endif

    return substitute(rv, '%', '%%', 'g') . ' '
endfunction

function! s:state(winnr) abort
    let rv = '#[ModFlag]'

    let buftype = getwinvar(a:winnr, '&buftype')

    if buftype ==# 'help'
        let rv .= 'H '
    elseif getwinvar(a:winnr, '&readonly')
            \ || buftype ==# 'nowrite'
            \ || getwinvar(a:winnr, '&modifiable') == 0
        let rv .= '- '
    elseif getwinvar(a:winnr, '&modified') != 0
        let rv .= '* '
    endif

    " Preview window flag
    let rv .= '#[BufFlag]%w'

    return rv
endfunction

function! s:ale_status(winnr) abort
    let rv = '#[Ale]'

    let counts = ale#statusline#Count(winbufnr(a:winnr))

    if g:ale_running
        let rv .= 'A '
    else
        let rv .= counts.total == 0 ? '' : join([
            \ counts.error > 0
                \ ? 'E'
                \ : counts.warning > 0
                    \ ? 'W' : '_',
            \ counts.style_error > 0
                \ ? 'E'
                \ : counts.style_warning > 0
                    \ ? 'W' : '_',
            \ counts.info > 0 ? 'I' : '',
        \ ], '') . ' '
    endif

    return rv
endfunction

function! s:filetype(is_current) abort
    if !a:is_current
        return ''
    endif

    return "%(#[FileType] %{!empty(&ft) ? &ft : '--'}#[BranchS]%)"
endfunction

function! s:spell(is_current) abort
    if !a:is_current
        return ''
    endif

    return "%(#[FileType]%{&spell ? ':' . &spelllang : ''}#[BranchS]%)"
endfunction

function! s:git(is_current) abort
    if !a:is_current
        return ''
    endif

    return '#[Branch]%(' .
        \ '%{' .
            \ "exists('g:loaded_fugitive') " .
                \ '? substitute(' .
                    \ 'fugitive#statusline(), ' .
                    \ "'\\[GIT(\\([a-z0-9\\-_\\./:]\\+\\))\\]', " .
                    \ "':\\1', " .
                    \ "'gi') " .
                \ ": ''" .
        \ '}' .
    \ '%) '
endfunction

function! s:func_name() abort
    if get(g:, 'disable_tagbar_stl', 0)
        return ''
    endif

    return '%(%{stl#currenttag()} %)'
endfunction

function! s:fileformat(winnr, is_current) abort
    if !a:is_current
        return ''
    endif

    let fileformat = getwinvar(a:winnr, '&fileformat')

    if fileformat ==# '' || fileformat ==# 'unix'
        return ''
    else
        return '#[FileFormat]' . fileformat . ' '
    endif
endfunction

function! s:fileenc(winnr, is_current) abort
    if !a:is_current
        return ''
    endif

    let fileenc = getwinvar(a:winnr, '&fileencoding')

    if empty(fileenc) || fileenc ==# 'utf-8'
        return ''
    else
        return '#[FileFormat]' . fileenc . ' '
    endif
endfunction

function! s:bom(is_current) abort
    if !a:is_current
        return ''
    endif

    return '%(#[FileFormat]%{&bomb ? "BOM" : ""} %)'
endfunction

function! s:zoomwin() abort
    return g:zoomwin_zoomed ? '#[Error]Z' : ''
endfunction

function! s:trailing() abort
    if !exists('b:stl_ts_warning')
        call stl#recompute_stl_ts()
    endif

    return '%(#[Error]%{b:stl_ts_warning}#[ExpandTab] %)'
endfunction

function! s:indent(winnr) abort
    if !exists('b:stl_ws_warning')
        call stl#recompute_stl_ws()
    endif

    let rv  = b:stl_ws_warning ==# 'mixed' ? '#[Error]' : '#[ExpandTab]'
    let rv .= getwinvar(a:winnr, '&expandtab') ? 'S' : 'T'

    let rv .= '#[LineColumn]:%{&tabstop}:%{&softtabstop}:%{&shiftwidth}'

    let rv .= '#[LineColumn] %03(%c%V%) '

    let rv .= '#[LinePercent] %p%%'

    return rv
endfunction

" vim:tw=80 foldmethod=syntax foldenable foldcolumn=1
