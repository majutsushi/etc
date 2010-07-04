XPTemplate priority=personal
"XPTemplate priority=lang indent=auto


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
"XPTinclude
"      \ _comment/doubleSign

"XPTinclude
"      \ _condition/c.like
"      \ _func/c.like
"      \ _loops/c.while.like
"      \ _preprocessor/c.like
"      \ _structures/c.like

"XPTinclude
"      \ _loops/for

XPTinclude
      \ _loops/c.for.like


"" ================================= Snippets ===================================
XPTemplateDef


XPT printf hint=printf\(...)
XSET elts|pre=Echo('')
XSET elts=c_printfElts( R( 'pattern' ) )
printf("`pattern^"`elts^)
..XPT


XPT sprintf hint=sprintf\(...)
XSET elts|pre=Echo('')
XSET elts=c_printfElts( R( 'pattern' ) )
sprintf(`str^, "`pattern^"`elts^)
..XPT


XPT snprintf hint=snprintf\(...)
XSET elts|pre=Echo('')
XSET elts=c_printfElts( R( 'pattern' ) )
snprintf(`str^, `size^, "`pattern^"`elts^)
..XPT


XPT fprintf hint=fprintf\(...)
XSET elts|pre=Echo('')
XSET elts=c_printfElts( R( 'pattern' ) )
fprintf(`stream^, "`pattern^"`elts^)
..XPT

