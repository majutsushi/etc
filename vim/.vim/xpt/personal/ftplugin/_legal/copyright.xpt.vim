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

XPT copyright hint=Copyright\ (C)\ YYYY
Copyright (C) `year()^ `$author^ <`$email^>
..XPT

