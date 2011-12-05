"""""""""""""""""""""""""""""""""""""""""""""
" vimplate - Template-Toolkit support for Vim
"""""""""""""""""""""""""""""""""""""""""""""
" please see:
"     :help vimplate
"   or
"     http://www.vim.org/scripts/script.php?script_id=1311
" Version:
"   vimplate 0.2.3
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" allow user to avoid loading this plugin and prevent loading twice
if exists ("loaded_vimplate")
    finish
endif
let loaded_vimplate = 1

let s:vimplate = Vimplate

function s:RunVimplate(template)
  let l:tmpfile = tempname()
  let l:cmd =  s:vimplate. " -out=" . l:tmpfile . " -template=" . a:template
  let l:line = line(".")
  execute "!" . l:cmd
  silent execute "read " . l:tmpfile
  execute delete(l:tmpfile)
  execute "normal " . l:line . "G"
  if getline(".") =~ "^$"
    execute "normal dd"
  endif
endfunction

function ListTemplates(...)
  return system(s:vimplate . " -listtemplates")
endfun

command! -complete=custom,ListTemplates -nargs=1 Vimplate call s:RunVimplate(<f-args>)
