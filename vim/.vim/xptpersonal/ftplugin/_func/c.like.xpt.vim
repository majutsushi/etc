XPTemplate priority=personal

"let s:f = g:XPTfuncs()

"XPTvar $TRUE           1
"XPTvar $FALSE          0
"XPTvar $NULL           NULL

"XPTvar $BRif           ' '
"XPTvar $BRloop         ' '
"XPTvar $BRstc          ' '
"XPTvar $BRfun          \n

"XPTvar $VOID_LINE      /* void */;
"XPTvar $CURSOR_PH      /* cursor */

"XPTvar $CL  /*
"XPTvar $CM   *
"XPTvar $CR   */
"XPTinclude
"      \ _common/common


" ================================= Snippets ===================================
XPTemplateDef


XPT fun hint=func..\ (\ ..\ )\ {...
`int^ `name^(`argument^`...^, `arg^`...^)
{
    `cursor^
}
..XPT


XPT fun_ hint=func..\ (\ SEL\ )\ {...
`int^ `name^(`argument^`...^, `arg^`...^)
{
    `wrapped^`cursor^
}
..XPT

