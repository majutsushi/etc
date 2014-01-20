" Vim syntax file
" Language:    Scenario Simulator log files
" Maintainer:  Jan Larres <jan@majutsushi.net>
" Last Change: 2013-05-17 11:27:51 +1200 NZST

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax match logLine /^\d\{4}-\d\{2}-\d\{2} \+\d\{2}:\d\{2}:\d\{2},\d\{3} \+\[[^]]\+\]\+ \+\w\+ \+\S\+ \+-.*$/ contains=logDate,logTime,logThread,logLevel,logFacility,logText

syntax match logText /.*$/ contained
syntax match logFacility /\S\+/ nextgroup=logText skipwhite contained
syntax match logLevel /\w\+/ nextgroup=logFacility skipwhite contained
syntax match logThread /\[[^]]\+\]/ nextgroup=logLevel skipwhite contained
syntax match logTime /\d\{2}:\d\{2}:\d\{2},\d\{3}/ nextgroup=logThread skipwhite contained
syntax match logDate /^\d\{4}-\d\{2}-\d\{2}/ nextgroup=logTime skipwhite contained

hi default link logDate Comment
hi default link logTime PreProc
hi default link logLevel Statement
hi default link logFacility Type
hi default link logThread Constant
hi default link logText Normal

let b:current_syntax = "scenlog"
