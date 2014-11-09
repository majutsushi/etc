" set filetypes
if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
    autocmd BufNewFile,BufReadPost *.rhtml   setfiletype eruby
    autocmd BufNewFile,BufReadPost *.rbx     setfiletype ruby
    autocmd BufNewFile,BufReadPost *.viki    setfiletype viki
    autocmd BufNewFile,BufReadPost *.mips    setfiletype mips
    autocmd BufNewFile,BufReadPost *.tt2     setfiletype tt2
    autocmd BufNewFile,BufReadPost *.gnuplot setfiletype gnuplot
    autocmd BufNewFile,BufReadPost *.gle     setfiletype gle
    autocmd BufNewFile,BufReadPost *.otl.gpg setfiletype vo_base
    autocmd BufNewFile,BufReadPost {.,}tmux.conf setfiletype tmux
    autocmd BufNewFile,BufReadPost sgc*.dat  setfiletype xml
    autocmd BufNewFile,BufReadPost *.gtkrc   setfiletype gtkrc
    autocmd BufNewFile,BufReadPost *.template setfiletype template
    autocmd BufNewFile,BufReadPost *.adoc,*.asciidoc setfiletype asciidoc
augroup END
