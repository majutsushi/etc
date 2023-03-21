if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim


syntax match   vfBullet  "^ *\zs\*"
syntax match   vfNote    "^ *[^ *-].*"
syntax match   vfHashtag "#\w\+"
syntax match   vfAttag   "@\w\+"

syntax match   vfBold    "\*\w\+\*"
syntax match   vfItalic  "/\w\+/"

syntax region vfDone           start='^\z(\s*\)-' skip='\z1\s' end='^\z1\ze\S'me=s-1 end='^\z1\@!' contains=vfDoneFirstLine
syntax match  vfDoneFirstLine  "^ *- \zs.*" contained

highlight default vfDone           guifg=#999999 ctermfg=247
highlight default vfDoneFirstLine  guifg=#999999 gui=strikethrough ctermfg=247 term=strikethrough
highlight default vfNote           guifg=#bbbbbb ctermfg=250

highlight default vfBold   gui=bold   term=bold   cterm=bold
highlight default vfItalic gui=italic term=italic cterm=italic

highlight default link vfBullet    Keyword
highlight default link vfHashtag   Identifier
highlight default link vfAttag     Identifier


let b:current_syntax = "vf"

let &cpo = s:cpo_save
unlet s:cpo_save
