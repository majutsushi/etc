" Author:  Jan Larres <jan@majutsushi.net>
" License: MIT/X11

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim


syntax keyword commandsCommands  bind-role bind-table create-local-endpoint
                               \ force-quit help history list-protocols
                               \ list-scenarios load-data-set load-scenario
                               \ print-config print-scenario print-status
                               \ quit ramp-up remove-scenario run-session
                               \ set-endpoint-address set-preferred-scenario
                               \ set-session-rate sleep start-generating
                               \ stop-generating wait-until-operational

syntax region  commandsComment start='#' end='$' contains=@Spell
syntax region  commandsProperty start='\${' end='}'


highlight default link commandsComment   Comment
highlight default link commandsCommands  Keyword
highlight default link commandsProperty  PreProc

let b:current_syntax = "dircolors"

let &cpo = s:cpo_save
unlet s:cpo_save
