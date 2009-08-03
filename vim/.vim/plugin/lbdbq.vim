" Name: lbdbq.vim
" Summary: functions and mode mappings for querying lbdb from Vim
" Copyright: Copyright (C) 2007 Stefano Zacchiroli <zack@bononia.it>
" License: GNU GPL version 3 or above
" Maintainer: Stefano Zacchiroli <zack@bononia.it>
" URL: http://www.vim.org/scripts/script.php?script_id=1757
" Version: 0.3

if exists("loaded_lbdbq")
    finish
endif
let loaded_lbdbq = 1

" queries lbdb with a query string and return a list of pairs:
" [['full name', 'email'], ['full name', 'email'], ...]
function! LbdbQuery(qstring)
  let output = system("lbdbq '" . a:qstring . "'")
  let results = []
  for line in split(output, "\n")[1:] " skip first line (lbdbq summary)
    let fields = split(line, "\t")
    let results += [ [fields[1], fields[0]] ]
  endfor
  return results
endfunction

" check if a potential query string has already been expanded in a complete
" recipient. E.g.: 'Stefano Zacchiroli <zack@bononia.it>' is a complete
" recipient, 'stefano zacchiroli' and 'stefano' are not
function! LbdbIsExpanded(qstring)
  return (a:qstring =~ '^\S\+@\S\+$\|<\S\+@\S\+>$')
endfunction

function! LbdbTrim(s)
  return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" expand a (short) contact given as a query string, asking interactively if
" disambiguation is needed
" E.g.: 'stefano zacchiroli' -> 'Stefano Zacchiroli <zack@bononia.it>'
function! LbdbExpandContact(qstring)
  let qstring = LbdbTrim(a:qstring)
  if LbdbIsExpanded(qstring)
    return qstring
  else  " try to expand (short) contact
    let contacts = LbdbQuery(qstring)
    let contact = []
    if empty(contacts)  " no matching (long) contact found
      return qstring
    elseif len(contacts) > 1  " multiple matches: disambiguate
      echo "Choose a recipient for '" . qstring . "':"
      let choices = []
      let counter = 0
      for contact in contacts
        let choices += [ printf("%2d. %s <%s>", counter, contact[0], contact[1]) ]
        let counter += 1
      endfor
      let contact = contacts[inputlist(choices)]
    else  " len(contacts) == 1, i.e. one single match
      let contact = contacts[0]
    endif
    return printf("\"%s\" <%s>", escape(contact[0], '"'), contact[1])
  endif
endfunction

" as above but support input strings composed by comma separated (short)
" contacts
function! LbdbExpandContacts(raw)
  let raw = LbdbTrim(a:raw)
  let qstrings = split(raw, '\s*,\s*')
  let exp_strings = []
  for qstring in qstrings
    let exp_strings += [ LbdbExpandContact(qstring) ]
  endfor
  return join(exp_strings, ', ')
endfunction

" expand all (short) contacts on a given recipient line, asking interactively
" if disambiguation is needed.
" E.g.:
" 'To: stefano zacchiroli, bram'
" -> 'To: Stefano Zacchiroli <zack@bononia.it>, Bram Moolenaar <Bram@moolenaar.net>
function! LbdbExpandRcptLine(recpt_line)
  if a:recpt_line =~ '^\w\+:'  " line is the *beginning* of a RFC822 field
    let raw = substitute(a:recpt_line, '^\w\+:\s*', '', '')
    let recpt_kind = substitute(a:recpt_line, '^\(\w\+\):\s*.*$', '\1', '')
    let exp_line = recpt_kind . ': ' . LbdbExpandContacts(raw)
  elseif a:recpt_line =~ '^\s\+'  " line is the *continuation* of a RFC822 field
    let raw = substitute(a:recpt_line, '^\s\+', '', '')
    let lpadding = substitute(a:recpt_line, '\S.*$', '', '')
    let exp_line = lpadding . LbdbExpandContacts(raw)
  else
    return a:recpt_line
  endif
  if a:recpt_line =~ ',\s*$'
    let exp_line .= ','
  endif
  return exp_line
endfunction

function! LbdbExpandCurLine()
  call setline(line('.'), LbdbExpandRcptLine(getline('.')))
endfunction

function! LbdbExpandVisual()
  if visualmode() ==# 'v'
    normal gvy
    let raw = getreg('"')
    let expanded = ''
    if raw =~ ","
      let expanded = LbdbExpandContacts(raw)
    else
      let expanded = LbdbExpandContact(raw)
    endif
    call setreg('"', expanded)
    normal gvP
  elseif visualmode() ==# 'V'
    call LbdbExpandCurLine()
  end
endfunction

nmap <silent> <LocalLeader>lb :call LbdbExpandCurLine()<RETURN>
vmap <silent> <LocalLeader>lb :call LbdbExpandVisual()<RETURN>
imap <silent> <LocalLeader>lb <ESC>:call LbdbExpandCurLine()<RETURN>A

