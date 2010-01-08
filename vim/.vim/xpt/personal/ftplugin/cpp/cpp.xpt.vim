XPTemplate priority=personal
"XPTemplate priority=sub

" Setting priority of cpp to "sub" or "subset of language", makes it override
" all c snippet if conflict



"XPTvar $TRUE          true
"XPTvar $FALSE         false
"XPTvar $NULL          NULL

XPTvar $BRif     ' '
XPTvar $BRel     ' '
"XPTvar $BRloop    \n
"XPTvar $BRloop  \n
"XPTvar $BRstc \n
"XPTvar $BRfun   \n

"XPTvar $VOID_LINE  /* void */;
"XPTvar $CURSOR_PH      /* cursor */

"XPTvar $CL  /*
"XPTvar $CM   *
"XPTvar $CR   */

"XPTvar $CS   //



"XPTinclude
"      \ _common/common
"      \ _comment/singleDouble
"      \ _condition/c.like
"      \ _func/c.like
"      \ _loops/c.while.like
"      \ _loops/java.for.like
"      \ _preprocessor/c.like
"      \ _structures/c.like
"XPTinclude
"      \ c/c


" ================================= Snippets ===================================
XPTemplateDef


XPT vector hint=std::vector<..>\ ..;
std::vector<`type^> `var^;
`cursor^


XPT map hint=std::map<..,..>\ ..;
std::map<`typeKey^,`val^> `name^;
`cursor^


XPT class   hint=class\ ..
class `className^
{
    public:
        `className^(`ctorParam^);
        virtual ~`className^();
        `className^(const `className^ &cpy);
        `cursor^
};

`className^::`className^(`ctorParam^)
{
}

`className^::~`className^()
{
}

`className^::`className^(const `className^ &cpy)
{
}
..XPT


XPT templateclass   hint=template\ <>\ class
template <`templateParam^>
class `className^
{
    public:
        `className^(`ctorParam^);
        virtual ~`className^();
        `className^(const `className^ &cpy);
        `cursor^
};

template <`templateParam^>
`className^<`_^cleanTempl(R('templateParam'))^^>::`className^(`ctorParam^)
{
}

template <`templateParam^>
`className^<`_^cleanTempl(R('templateParam'))^^>::~`className^()
{
}

template <`templateParam^>
`className^<`_^cleanTempl(R('templateParam'))^^>::`className^(const `className^ &cpy)
{
}
..XPT


XPT try hint=try\ ...\ catch...
XSET handler=$CL void $CR
try {
    `what^
}`...^ catch (`except^) {
    `handler^
}`...^

..XPT

XPT try_ hint=try\ {\ SEL\ }\ catch...
XSET handler=$CL void $CR
try {
    `wrapped^
}`...^ catch (`except^) {
    `handler^
}`...^

..XPT
