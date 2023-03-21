"  -- help editing settings
" Author       : Jan Larres <jan@majutsushi.net>
" Website      : http://majutsushi.net
" Created      : 2012-01-14 17:30:52 +1300 NZDT
" Last changed : 2012-01-14 17:30:52 +1300 NZDT

" disable concealing when editing help files
if has('conceal') && &buftype != 'help'
    setlocal conceallevel=0
endif
