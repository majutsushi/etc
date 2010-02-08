setlocal indentexpr=GetGLEIndent()
setlocal nolisp
setlocal smartindent
setlocal autoindent
setlocal indentkeys+=end

if exists("*GetGLEIndent") | finish
endif

function GetGLEIndent()

  " Find a non-blank line above the current line.
  let lnum = prevnonblank(v:lnum - 1)

  " At the start of the file use zero indent.
  if lnum == 0 | return 0
  endif

  let ind = indent(lnum)
  let line = getline(lnum)             " last line
  let cline = getline(v:lnum)          " current line


  " Add a 'shiftwidth' after beginning of environments.
  if line =~ 'begin \(.*\)'
    let ind = ind + &sw
  endif

  " Subtract a 'shiftwidth' when an environment ends
  if cline =~ '\s*end '
    let ind = ind - &sw
  endif
  return ind
endfunction

