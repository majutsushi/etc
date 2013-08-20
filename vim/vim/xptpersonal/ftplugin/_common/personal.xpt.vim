" Move me to your own fptlugin/_common and config your personal information.
"
" Here is the place to set personal preferences; "priority=personal" is the
" highest which overrides any other XPTvar setting.
"
" You can also set personal variables with 'g:xptemplate_vars' in your .vimrc.
XPTemplate priority=personal


" XPTvar $author       you have not yet set $author variable
" XPTvar $email        you have not yet set $email variable

"XPTemplateDef
"XPT yoursnippet " tips here
"bla bla

XPTvar $SParg ''

XPT dateshort hint=Date\ (Y-m-d)
`strftime("%Y-%m-%d")^
..XPT

XPT datefull hint=Date\ (full)
`strftime("%Y-%m-%d %H:%M:%S %z %Z")^
..XPT
