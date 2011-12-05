" devhelp.vim: A Devhelp assistant and search plugin for VIM.
"
" Copyright (c) 2008 Jannis Pohlmann <jannis@xfce.org>
"
" To enable devhelp search:
"   let g:devhelpSearch=1
" 
" To enable devhelp assistant:
"   let g:devhelpAssistant=1
" 
" To change the update delay (e.g. to 150ms):  
"   set updatetime=150
" 
" To change the search key (e.g. to F5):
"   let g:devhelpSearchKey = '<F5>'
" 
" To change the length (e.g. to 5 characters) before a word becomes 
" relevant:
"   let g:devhelpWordLength = 5
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
" General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 59 Temple Place - Suite 330, Boston, 
" MA 02111-1307, USA.

" Devhelp plugin configuration. These variables may be set in .vimrc
" to override the defaults
if !exists ('g:devhelpSearchKey')
  let g:devhelpSearchKey = '<F7>'
endif
if !exists ('g:devhelpWordLength')
  let g:devhelpWordLength = 5
endif

" Variable for remembering the last assistant word 
let s:lastWord = ''

function! GetCursorWord ()
  " Try to get the word below the cursor
  let s:word = expand ('<cword>')

  " If that's empty, try to use the word before the cursor
  if empty (s:word)
    let s:before = getline  ('.')[0 : getpos ('.')[2]-1]
    let s:start  = match    (s:before, '\(\w*\)$')
    let s:end    = matchend (s:before, '\(\w*\)$')
    let s:word   = s:before[s:start : s:end]
  end

  return s:word
endfunction

function! DevhelpUpdate (flag)
  try
    " Get word below or before cursor
    let s:word = GetCursorWord ()

    if a:flag == 'a'
      " Update Devhelp assistant window
      if s:lastWord != s:word && strlen (s:word) > g:devhelpWordLength
        " Update Devhelp
        call system ('devhelp -a '.s:word.' &')
    
        " Remember the word for next time
        let s:lastWord = s:word
      end
    else
      " Update devhelp search window. Since the user intentionally
      " pressed the search key, the word is not checked for its 
      " length or whether it's new
      call system ('devhelp -s '.s:word.' &')
    end
  catch
  endtry
endfunction

function! DevhelpUpdateI (flag)
  " Use normal update function
  call DevhelpUpdate (a:flag)

  if col ('.') == len (getline ('.'))
    " Start appening if the cursor at the end of the line
    startinsert!
  else
    " Otherwise move the cursor to the right and start inserting.
    " This is required because <ESC> moves the cursor to the left
    let s:pos = getpos ('.')
    let s:pos[2] += 1
    call setpos ('.', s:pos)
    startinsert
  endif
endfunction

if exists ('g:devhelpSearch') && g:devhelpSearch
  " Update the main Devhelp window when the search key is pressed
  exec 'nmap '.g:devhelpSearchKey.' :call DevhelpUpdate("s")<CR>'
  exec 'imap '.g:devhelpSearchKey.' <ESC>:call DevhelpUpdateI("s")<CR>'
  exec 'nmap <leader>d :call DevhelpUpdate("a")<CR>'
endif

if exists ('g:devhelpAssistant') && g:devhelpAssistant
  " Update the assistant window if the user hasn't pressed a key for a 
  " while. See :help updatetime for how to change this delay
  au! CursorHold  * nested call DevhelpUpdate('a')
  au! CursorHoldI * nested call DevhelpUpdate('a')
endif
