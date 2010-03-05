" Vim plugin for checking attachments with mutt
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: 2010 Mar, 02
" Version:     0.5
" GetLatestVimScripts: 2796 4 :AutoInstall: CheckAttach.vim

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

" List of highlighted matches
let s:matchid=[]

" For which filetypes to check for attachments
" Define as comma separated list. If you want additional filetypes
" besides mail, use attach_check_ft to specify all filetypes
let s:filetype=(exists("attach_check_ft") ? attach_check_ft : 'mail')

" On which keywords to trigger, comma separated list of keywords
let g:attach_check_keywords = 'attach,attachment,angehängt,Anhang'

fu! <SID>AutoCmd()

    if !empty("s:load_autocmd") && s:load_autocmd 
	augroup CheckAttach  
	    au! BufWriteCmd * :call <SID>CheckAttach() 
	augroup END
    else
	silent! au! CheckAttach BufWriteCmd *
	silent! augroup! CheckAttach
        call map(s:matchid, 'matchdelete(v:val)')
	let s:matchid=[]
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
fu! <SID>CheckAttach()"{{{
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
    if search('\c\%('.val.'\)','W')
	call add(s:matchid,matchadd('WarningMsg', '\%('.val.'\)'))
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
endfu"}}}

" Define commands that will disable and enable the plugin.
command! DisableCheckAttach let s:load_autocmd=0 | :call <SID>CheckFT()
command! EnableCheckAttach let s:load_autocmd=1 | :call <SID>CheckFT()

" Enable autocommand when loading file
":call <SID>AutoCmd()

fu! <SID>CheckFT()
    let s:filetype=(exists("attach_check_ft") ? attach_check_ft : 'mail')
    let s:check_filetype=join(split(escape(s:filetype, '\\*?'),','),'\|')
    "au FileType * if expand("<amatch>") =~ 'mail' | :call <SID>AutoCmd() | endif
    if &ft =~ s:check_filetype | :call <SID>AutoCmd() | endif
endfun
