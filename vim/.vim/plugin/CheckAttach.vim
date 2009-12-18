" Vim plugin for checking attachments with mutt
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: 2009 Oct 1
" Version:     0.3
" GetLatestVimScripts: 2796 2 :AutoInstall: CheckAttach.vim

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
" - the autocmd event is not availble.
if exists("g:loaded_checkattach") || &cp || !exists("##BufWriteCmd") || !exists("##FileWriteCmd")
  finish
endif
let g:loaded_checkattach = 1

" enable Autocommand for attachment checking
let s:load_autocmd=1

" On which keywords to trigger, comma separated list of keywords
let g:attach_check_keywords = 'attached,attachment,angehängt,Anhang'

fu! <SID>AutoCmd()
    if !empty("s:load_autocmd") && s:load_autocmd && &ft == 'mail'
	augroup CheckAttach  
	    au! BufWriteCmd mutt* :call <SID>CheckAttach() 
	augroup END
    else
	silent! au! CheckAttach BufWriteCmd mutt*
	silent! augroup! CheckAttach
    endif
endfu

" Write the Buffer contents
fu! <SID>WriteBuf(bang)
    :exe ":write" . (a:bang ? '!' : '') . ' '  . expand("<amatch>")
    :setl nomod
endfu

" This function checks your mail for the words specified in
" check, and if it find them, you'll be asked to attach
" a file.
fu! <SID>CheckAttach()
    if exists("g:attach_check_keywords")
       let s:attach_check = g:attach_check_keywords
    endif

    if empty("s:attach_check") || v:cmdbang
	:call <SID>WriteBuf(v:cmdbang)
	return
    endif
    let oldPos=getpos('.')
    let ans=1
    let val = join(split(escape(s:attach_check,' \.+*'), ','),'\|')
    1
    if search('\%('.val.'\)','W')
        let ans=input("Attach file: (leave empty to abbort): ", "", "file")
        while (ans != '') && (ans != 'n')
                let list = split(expand(glob(ans)), "\n")
                for attach in list
                    normal magg}-
                    call append(line('.'), 'Attach: ' . escape(attach, ' '))
                    redraw
                endfor
            let ans=input("Attach another file?: (leave empty to abbort): ", "", "file")
        endwhile
    endif
    :call <SID>WriteBuf(v:cmdbang)
    call setpos('.', oldPos)
endfu

" Define commands that will disable and enable the plugin.
command! DisableCheckAttach let s:load_autocmd=0 | :call <SID>AutoCmd()
command! EnableCheckAttach let s:load_autocmd=1 | :call <SID>AutoCmd() 

" Enable autocommand when loading file
:call <SID>AutoCmd()

augroup CheckAttach
    au!
    au FileType * if expand("<amatch>") =~ 'mail' | :call <SID>AutoCmd() | endif
augroup END

