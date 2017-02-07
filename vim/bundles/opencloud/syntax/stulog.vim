" Vim syntax file
" Language:    STU log files
" Maintainer:  Jan Larres <jan@majutsushi.net>

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax match logLine /^=\d\{4}-\d\{2}-\d\{2} \+\d\{2}:\d\{2}:\d\{2},\d\{3} \+\[[^]]\+\]\+ \+\w\+ \+\S\+ \+-.*$/ contains=logDate,logTime,logThread,logLevel,logFacility,logText

syntax match logText /.*$/ contained contains=summaryLine,logProblem
syntax match logFacility /\S\+/ nextgroup=logText skipwhite contained
syntax match logLevel /\w\+/ nextgroup=logFacility skipwhite contained
syntax match logThread /\[[^]]\+\]/ nextgroup=logLevel skipwhite contained
syntax match logTime /\d\{2}:\d\{2}:\d\{2},\d\{3}/ nextgroup=logThread skipwhite contained
syntax match logDate /^=\d\{4}-\d\{2}-\d\{2}/hs=s+1 nextgroup=logTime skipwhite contained

syntax match logProblem /final non-match/ contained
syntax match logProblem /does not match/ contained

syntax match summaryLine /summary: .*/ contains=summaryOk,summaryFail

syntax match summaryOk   /\[OK\]/ contained
syntax match summaryFail /\[FAIL\]/ contained

hi default link logDate Comment
hi default link logTime PreProc
hi default link logLevel Statement
hi default link logFacility Type
hi default link logThread Constant
hi default link logText Normal

hi default summaryOk   guifg=#00ff00 gui=bold ctermfg=2 cterm=bold
hi default summaryFail guifg=#ff0000 gui=bold ctermfg=1 cterm=bold

hi default logProblem  guifg=#ff0000 gui=bold ctermfg=1 cterm=bold

let b:current_syntax = "stulog"
