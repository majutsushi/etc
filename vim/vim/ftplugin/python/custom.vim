" /home/jan/.vim/ftplugin/python.vim -- python
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2010-04-08 20:28:40 +1200 NZST
" Last changed : 2012-03-23 23:03:57 +1300 NZDT

"setlocal foldmethod=indent
setlocal omnifunc=pythoncomplete#Complete

setlocal tags+=$HOME/.vim/tags/python3tags

"setlocal makeprg=python2.6\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
setlocal makeprg=python2.6\ %
setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

"map <buffer> <leader>e :!python2.6 %<CR>

if has("+python")
python << EOF
import os
import sys
import vim
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"setlocal path+=%s" % (p.replace(" ", r"\ ")))
EOF
endif

function s:IPython()
    let g:ScreenShellSendPrefixOld = g:ScreenShellSendPrefix
    let g:ScreenShellSendSuffixOld = g:ScreenShellSendSuffix
    let g:ScreenShellSendPrefix = '%cpaste'
    let g:ScreenShellSendSuffix = '--'
    let g:ScreenShellSendVarsRestore = 1

    ScreenShellVertical ipython
endfunction

function! s:ScreenShellListener()
    if g:ScreenShellActive
        if g:ScreenShellCmd == 'ipython'
            nnoremap <silent> <buffer> <leader>ss :ScreenSend<cr>
            xnoremap <silent> <buffer> <leader>ss :ScreenSend<cr>
        else
            nnoremap <silent> <buffer> <leader>ss <Nop>
        endif
    else
        nnoremap <silent> <buffer> <leader>ss :call <SID>IPython()<cr>
    endif
endfunction

call s:ScreenShellListener()
augroup ScreenShellEnter
    autocmd User <buffer> call <SID>ScreenShellListener()
augroup END
augroup ScreenShellExit
    autocmd User <buffer> call <SID>ScreenShellListener()
augroup END
