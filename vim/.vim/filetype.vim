" set filetypes
augroup filetypedetect
    au BufNewFile,BufReadPost *.rhtml   setfiletype eruby
    au BufNewFile,BufReadPost *.rbx     setfiletype ruby
    au BufNewFile,BufReadPost *.viki    setfiletype viki
    au BufNewFile,BufReadPost *.mips    setfiletype mips
    "au BufNewFile,BufReadPost COMMIT_EDITMSG setfiletype git
    au BufNewFile,BufReadPost *.mkd     setfiletype mkd
    au BufNewFile,BufReadPost *.tt2     setfiletype tt2
    au BufNewFile,BufReadPost *.gnuplot setfiletype gnuplot
    au BufNewFile,BufReadPost *.gle     setfiletype gle
    au BufNewFile,BufReadPost *.otl.gpg setfiletype vo_base
augroup END

