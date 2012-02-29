setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=80
setlocal smarttab
setlocal expandtab
setlocal smartindent

let g:tagbar_type_grace = {
    \ 'ctagstype' : 'grace',
    \ 'deffile'   : expand('<sfile>:p:h:h') . '/ctags/grace.cnf',
    \ 'kinds'     : [
        \ 'i:imports:1',
        \ 'd:defs',
        \ 'v:vars',
        \ 't:types',
        \ 'c:classes',
        \ 'm:methods'
    \ ]
\ }
