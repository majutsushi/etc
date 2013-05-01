" Author:  Jan Larres <jan@majutsushi.net>
" Website: http://majutsushi.net
" License: MIT/X11

setlocal foldmethod=syntax

function! s:method_motion(direction, type) abort
    " This doesn't find methods with 'package' visibility, but making the
    " visibility optional creates too many false positives.
    let methodpat = '\v^\s*((public|protected|private|static|synchronized)\s+)+([[:alnum:]<>\[\]]+\s+)?(\w+) *\('

    if a:type ==# '{'
        let pos = getpos('.')

        if a:direction ==# 'b'
            normal! k
        else
            normal! j
        endif

        if search(methodpat, a:direction . 'W') > 0
            return search('{', 'W')
        else
            call setpos('.', pos)
            return 0
        endif
    else
        let pos = getpos('.')
        let line1 = search(methodpat, 'bW')
        if line1 == 0 && a:direction ==# 'b'
            " No method above; nothing to do
            return
        elseif line1 == 0
            let line2 = pos[1]
        else
            call search('{', 'W')
            let line2 = searchpair('{', '', '}', 'W')
        endif

        if a:direction ==# 'b' && line2 >= pos[1]
            execute line1
            if s:method_motion(a:direction, '{') > 0
                call searchpair('{', '', '}', 'W')
            else
                call setpos('.', pos)
            endif
        elseif a:direction ==# '' && line2 <= pos[1]
            execute line1
            if s:method_motion(a:direction, '{') > 0
                call searchpair('{', '', '}', 'W')
            else
                call setpos('.', pos)
            endif
        endif
    endif
endfunction

nnoremap <silent> <buffer> ]] :call <SID>method_motion('', '{')<CR>
nnoremap <silent> <buffer> ][ :call <SID>method_motion('', '}')<CR>
nnoremap <silent> <buffer> [[ :call <SID>method_motion('b', '{')<CR>
nnoremap <silent> <buffer> [] :call <SID>method_motion('b', '}')<CR>

" Don't interfere with eclim signs
let b:quickfixsigns_ignore = ['qfl', 'loc']

imap <silent> <buffer> <C-Space> <C-x><C-u>
inoremap <expr> <C-x><C-u> pumvisible() ? '<C-x><C-u>' : '<C-x><C-u><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

nnoremap <silent> <buffer> <leader>i  :JavaImport<cr>
nnoremap <silent> <buffer> <leader>ds :JavaDocSearch -x declarations<cr>
nnoremap <silent> <buffer> <leader>dd :JavaDocPreview<cr>
nnoremap <silent> <buffer> <cr>       :JavaSearchContext<cr>
