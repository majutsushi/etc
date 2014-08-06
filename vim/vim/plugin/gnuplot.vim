" Execute Gnuplot on selection
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net

" s:gnuplot() {{{1
function! s:gnuplot(args) range
    if a:args == ''
        let style = 'linespoints'
    else
        let style = a:args
    endif

    let datafile = tempname()

    let vmode = visualmode()

    if vmode ==# ''
        let reg_save = @g

        normal! gv"gy
        execute 'redir! > ' . datafile
        echo @g
        redir END

        let @g = reg_save
    else
        execute "keepalt " . a:firstline . "," . a:lastline . "write! " . datafile
    endif

    let commandfile = tempname()

    execute 'redir! > ' . commandfile
    echon "load '~/.etc/gnuplot/grey.gnuplot'\n"
    echon "plot('" . datafile . "') with " . style . "\n"
    redir END

    call s:exec_gnuplot(commandfile)

    call delete(datafile)
    call delete(commandfile)
endfunction

" s:exec_gnuplot() {{{1
function! s:exec_gnuplot(commandfile)
    let output = system('gnuplot -p ' . a:commandfile)

    if v:shell_error
        echoerr output
    endif
endfunction

" Command {{{1
command! -nargs=* -range=% Gnuplot silent <line1>,<line2>call s:gnuplot(<q-args>)
