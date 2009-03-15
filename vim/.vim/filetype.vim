" set filetypes
augroup filetypedetect
au BufNewFile,BufReadPost *.rhtml setfiletype eruby
au BufNewFile,BufReadPost *.rbx setfiletype ruby
au BufNewFile,BufReadPost *.viki setfiletype viki
au BufNewFile,BufReadPost *.mips setfiletype mips
"au BufNewFile,BufReadPost COMMIT_EDITMSG setfiletype git
au BufNewFile,BufReadPost *.mkd setfiletype mkd
augroup END

