" xdefaults.vim -- Handle X resources reloading
" Author       : Jan Larres <jan@majutsushi.net>
" Created      : 2012-02-21 17:11:48 +1300 NZDT
" Last changed : 2012-02-21 18:01:07 +1300 NZDT

" s:prewrite() {{{1
" Save all resources that were not specified in the file to a temporary file
" so they can be restored later
function! s:prewrite(fname)
    let output      = system('xrdb -query')
    let curvalues   = split(output, '\n\+')
    let oldfilevals = readfile(a:fname)

    let unknownvals = []

    for val in curvalues
        let key = split(val, ':')[0]
        if match(oldfilevals, '\V\^' . key . ':') == -1
            let unknownvals += [val]
        endif
    endfor

    let s:unknownstmpfile = tempname()

    execute 'redir! > ' . s:unknownstmpfile
    for val in unknownvals
        echo val
    endfor
    redir END
endfunction

" postwrite() {{{1
" First load the resources that didn't come from the old version of the file
" and then merge in the values from the new version of the file
function! s:postwrite(fname)
    let output = system('xrdb -load ' . s:unknownstmpfile)

    if v:shell_error
        echoerr output
        return
    endif

    let output = system('xrdb -merge ' . a:fname)

    if v:shell_error
        echoerr output
    endif
endfunction

autocmd BufWritePre  <buffer> silent call s:prewrite(expand('<afile>'))
autocmd BufWritePost <buffer> silent call s:postwrite(expand('<afile>'))
