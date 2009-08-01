" texmath.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-15.
" @Last Change: 2009-02-15.
" @Revision:    0.0.16

" Use only as embedded syntax to be included from other syntax files.

" if version < 600
"     syntax clear
" elseif exists("b:current_syntax")
"     finish
" endif
if exists(':HiLink')
    let s:delhilink = 0
else
    let s:delhilink = 1
    if version < 508
        command! -nargs=+ HiLink hi link <args>
    else
        command! -nargs=+ HiLink hi def link <args>
    endif
endif


" syn match texmathArgDelimiters /[{}\[\]]/ contained containedin=texmathMath
syn match texmathCommand /\\[[:alnum:]]\+/ contained containedin=texmath
syn match texmathMathFont /\\\(math[[:alnum:]]\+\|Bbb\|frak\)/ contained containedin=texmath
syn match texmathMathWord /[[:alnum:].]\+/ contained containedin=texmathMath
syn match texmathUnword /\(\\\\\|[^[:alnum:]${}()[\]^_\\]\+\)/ contained containedin=texmath
syn match texmathPairs /\([<>()[\]]\|\\[{}]\|\\[lr]\(brace\|vert\|Vert\|angle\|ceil\|floor\|group\|moustache\)\)/
            \ contained containedin=texmath
syn match texmathSub /_/ contained containedin=texmathMath
syn match texmathSup /\^/ contained containedin=texmathMath
syn region texmathText matchgroup=Statement
            \ start=/\\text{/ end=/}/ skip=/\\[{}]/
            \ contained containedin=texmath
syn region texmathArgDelimiters matchgroup=Delimiter
            \ start=/\\\@<!{/ end=/\\\@<!}/ skip=/\\[{}]/
            \ contained contains=@texmathMath containedin=texmath
syn cluster texmath contains=texmathArgDelimiters,texmathCommand,texmathMathFont,texmathPairs,texmathUnword,texmathText
syn cluster texmathMath contains=@texmath,texmathMathWord,texmathSup,texmathSub

" Statement PreProc
HiLink texmathSup Type
HiLink texmathSub Type
" HiLink texmathArgDelimiters Comment
HiLink texmathCommand Statement
HiLink texmathText Normal
HiLink texmathMathFont Type
HiLink texmathMathWord Identifier
HiLink texmathUnword Constant
HiLink texmathPairs PreProc


if s:delhilink
    delcommand HiLink
endif
" let b:current_syntax = 'texmath'

