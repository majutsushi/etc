XPTemplate priority=personal

"let s:f = g:XPTfuncs()

"XPTvar $NULL            NULL
"XPTvar $CURSOR_PH       CURSOR
"XPTvar $BRloop ' '

"XPTvar $VAR_PRE
"XPTvar $FOR_SCOPE

"XPTinclude
"      \ _common/common

" ================================= Snippets ===================================
XPTemplateDef

XPT timestamp hint=Created\ /\ Last\ changed
`$CS^ Created      : `strftime("%Y-%m-%d %H:%M:%S %z %Z")^
`$CS^ Last changed : `strftime("%Y-%m-%d %H:%M:%S %z %Z")^
..XPT

