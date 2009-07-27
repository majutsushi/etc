"""""""""""""""""""""""""""""""""""""""""""""
" vimplate - Template-Toolkit support for Vim
"""""""""""""""""""""""""""""""""""""""""""""
" please see:
"     :help vimplate
"   or
"     http://www.vim.org/scripts/script.php?script_id=1311
" Version:
"   vimplate 0.2.4
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" allow user to avoid loading this plugin and prevent loading twice
if exists ("loaded_vimplate")
    finish
endif
let loaded_vimplate = 1

if !exists("Vimplate")
  " Debian specific path unless overridden by the user
  let Vimplate = "/usr/bin/vimplate"
endif
let s:vimplate = Vimplate

function s:RunVimplate(template)
  let l:tmpfile = tempname()
  if strlen(bufname("%"))
    let l:cmd =  s:vimplate. " -filename=%" . " -out=" . l:tmpfile . " -template=" . a:template
  else
    let l:cmd =  s:vimplate. " -out=" . l:tmpfile . " -template=" . a:template
  endif
  let l:line = line(".")
  execute "!" . l:cmd
  if (!v:shell_error)
    silent execute "read " . l:tmpfile
    execute delete(l:tmpfile)
    execute "normal " . l:line . "G"
    if getline(".") =~ "^$"
      execute "normal dd"
    endif
  else
    echohl ErrorMsg
    echomsg "Error while execute " . l:cmd
    echohl None
  endif
endfunction

function ListTemplates(...)
  return system(s:vimplate . " -listtemplates")
endfunction

command! -complete=custom,ListTemplates -nargs=1 Vimplate call s:RunVimplate(<f-args>)
