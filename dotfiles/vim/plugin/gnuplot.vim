" Execute Gnuplot on selection
" Author:  Jan Larres <jan@majutsushi.net>
" Website: http://majutsushi.net

let s:theme_default = expand('$DOTFILES/gnuplot/grey.gnuplot')

if !exists('g:gnuplot_theme') && filereadable(s:theme_default)
    let g:gnuplot_theme = s:theme_default
endif

" s:gnuplot() {{{1
function! s:gnuplot(args) range abort
    if a:args == ''
        let style = 'linespoints'
    else
        let style = a:args
    endif

    let datafile = tempname()

    if visualmode() ==# "\026"
        " Visual block mode

        let reg_save = @g

        normal! gv"gy
        execute 'redir! > ' . datafile
        echo @g
        redir END

        let @g = reg_save
    else
        call writefile(getbufline('%', a:firstline, a:lastline), datafile)
    endif

    let commandfile = tempname()

    execute 'redir! > ' . commandfile
    if exists('g:gnuplot_theme')
        echon "load '" . g:gnuplot_theme . "'\n"
    endif
    echon "plot('" . datafile . "') with " . style . "\n"
    redir END

    call s:exec_gnuplot(commandfile)

    call delete(datafile)
    call delete(commandfile)
endfunction

" s:exec_gnuplot() {{{1
function! s:exec_gnuplot(commandfile) abort
    let output = system('gnuplot -p ' . a:commandfile)

    if v:shell_error
        echoerr output
    endif
endfunction

" Command {{{1
command! -nargs=* -range=% Gnuplot silent <line1>,<line2>call s:gnuplot(<q-args>)
