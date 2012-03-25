" Execute Gnuplot on selection
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-01-18 00:13:58 +1300 NZDT
" Last changed : 2012-03-25 18:33:38 +1300 NZDT

" s:Gnuplot() {{{1
function! s:Gnuplot() range
    let datafile = tempname()

    let vmode = visualmode()

    if a:firstline == 1 && a:lastline == line('$') && vmode !=# ''
        let datafile = expand('%:p')
    elseif vmode ==# 'V'
        execute "keepalt " . a:firstline . "," . a:lastline . "write! " . datafile
    elseif vmode ==# ''
        let reg_save = @g

        normal! gv"gy
        execute 'redir! > ' . datafile
        echo @g
        redir END

        let @g = reg_save
    else
        echoerr 'Unsupported mode:' vmode
        return
    endif

    let commandfile = tempname()

    execute 'redir! > ' . commandfile
    echon "load '~/.etc/gnuplot/grey.gnuplot'\n"
    echon "plot('" . datafile . "') with linespoints\n"
    redir END

    call s:ExecuteGnuplot(commandfile)
endfunction

" s:ExecuteGnuplot() {{{1
function! s:ExecuteGnuplot(commandfile)
    let output = system('gnuplot -p ' . a:commandfile)

    if v:shell_error
        echoerr output
    endif
endfunction

" Command {{{1
command! -range=% Gnuplot silent <line1>,<line2>call s:Gnuplot()
