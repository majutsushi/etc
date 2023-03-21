if has("autocmd") && exists("+omnifunc")
    augroup syntaxcomplete
	au Filetype *
		\ if &omnifunc == "" |
		\	setl omnifunc=syntaxcomplete#Complete |
		\ endif
    augroup END
endif
