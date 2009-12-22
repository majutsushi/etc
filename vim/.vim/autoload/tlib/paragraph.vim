" paragraph.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-10-26.
" @Last Change: 2009-10-26.
" @Revision:    0.0.12

let s:save_cpo = &cpo
set cpo&vim


" :def: function! tlib#paragraph#Delete(?register="")
" Almost the same as dap but behaves differently when the cursor is on a 
" blank line or when the paragraph's last line is the last line in the 
" file.
"
" This function assumes that a paragraph is a block of text followed by 
" blank lines or the end of file.
function! tlib#paragraph#Delete(...) "{{{3
    TVarArg 'register'
    if empty(register)
        let prefix = ''
    else
        let prefix = '"'. register
    endif
    let lineno = line('.')
    let lastno  = line('$')
    let hastext = getline(lineno) =~ '\S'
    if line("'}") == lastno
        if lineno == lastno
            silent norm! {j0
        else
            silent norm! }{j0
        endif
        exec 'silent norm! '. prefix .'dG'
    elseif hastext
        silent norm! dap
    else 
        silent norm! {j0dap
    endif
endf


let &cpo = s:save_cpo
unlet s:save_cpo
