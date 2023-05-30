" Author : Jan Larres <jan@majutsushi.net>

"setlocal foldmethod=indent
setlocal omnifunc=pythoncomplete#Complete

"setlocal makeprg=python2.6\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
setlocal makeprg=python3\ %
setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

"map <buffer> <leader>e :!python2.6 %<CR>

nnoremap <silent> <buffer> <Enter> :YcmCompleter GoTo<CR>

if has("python3")
python3 << EOF
import os
import sys
import vim
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"setlocal path+=%s" % (p.replace(" ", r"\ ")))
EOF
endif
