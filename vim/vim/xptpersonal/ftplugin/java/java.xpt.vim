XPTemplate priority=personal


"XPTvar $TRUE           1
"XPTvar $FALSE          0
"XPTvar $NULL           NULL

XPTvar $BRif           ' '
XPTvar $BRel           ' '
"XPTvar $BRloop         ' '
"XPTvar $BRstc          ' '
"XPTvar $BRfun          \n

"XPTvar $VOID_LINE      /* void */;
"XPTvar $CURSOR_PH      /* cursor */

"XPTinclude
"      \ _common/common

"XPTvar $CL  /*
"XPTvar $CM   *
"XPTvar $CR   */


"" ================================= Snippets ===================================
XPTemplateDef

XPT _args hidden " expandable arguments
XSET arg*|post=ExpandInsideEdge( ',$SPop', '' )
`$SParg`arg*`$SParg^

XPT method " method (..) {}
`public^ `name^(`:_args:^)` throws `Exception^ {
    `cursor^
}
..XPT
