" Includes stuff from
" http://www.derekwyatt.org/vim/working-with-vim-and-cpp/cpp-snippets

XPTemplate priority=personal

let s:f = g:XPTfuncs()

"XPTvar $TRUE          true
"XPTvar $FALSE         false
"XPTvar $NULL          NULL

XPTvar $BRif     ' '
XPTvar $BRel     ' '
"XPTvar $BRloop    \n
"XPTvar $BRloop  \n
"XPTvar $BRstc \n
"XPTvar $BRfun    ' '

"XPTvar $VOID_LINE  /* void */;
"XPTvar $CURSOR_PH      /* cursor */

"XPTvar $CL  /*
"XPTvar $CM   *
"XPTvar $CR   */

"XPTvar $CS   //


XPTinclude
    \ _legal/copyright
    \ _legal/doubleSign
    \ _timestamps/doubleSign


function! s:f.year(...) "{{{
    return strftime("%Y")
endfunction "}}}

function! InsertNameSpace(beginOrEnd)
    let dir = expand('%:p:h')
    let ext = expand('%:e')
    if ext == 'cpp'
        let dir = FSReturnCompanionFilenameString('%')
        let dir = fnamemodify(dir, ':h')
    endif
    let idx = stridx(dir, 'include/')
    let nsstring = ''
    if idx != -1
        let dir = strpart(dir, idx + strlen('include') + 1)
        let nsnames = split(dir, '/')
        let nsdecl = join(nsnames, ' { namespace ')
        let nsdecl = 'namespace '.nsdecl.' {'
        if a:beginOrEnd == 0
            let nsstring = nsdecl . "\n\n"
        else
            for i in nsnames
                let nsstring = nsstring.'} '
            endfor
            let nsstring = "\n".nsstring.'// end of namespace '.join(nsnames, '::')
        endif
        let nsstring = "\n" . nsstring
    endif

    return nsstring
endfunction

function! InsertNameSpaceBegin()
    return InsertNameSpace(0)
endfunction

function! InsertNameSpaceEnd()
    return InsertNameSpace(1)
endfunction

function! GetNSFName(snipend)
    let dirAndFile = expand('%:p')
    let idx = stridx(dirAndFile, 'include')
    if idx != -1
        let fname = strpart(dirAndFile, idx + strlen('include') + 1)
    else
        let fname = expand('%:t')
    endif
    if a:snipend == 1
        let fname = expand(fname.':r')
    endif

    return fname
endfunction

function! GetNSFNameDefine()
    let dir = expand('%:p:h')
    let idx = stridx(dir, 'include')
    if idx != -1
        let subdir = strpart(dir, idx + strlen('include') + 1)
        let define = substitute(subdir, '/', '_', 'g')
        let define = define ."_".expand('%:t:r')."_h"
        let define = toupper(define)
        let define = substitute(define, '^_\+', '', '')
        return define
    else
        return toupper(expand('%:t:r'))."_H"
    endif
endfunction

function! GetHeaderForCurrentSourceFile()
    let header=FSReturnCompanionFilenameString('%')
    if stridx(header, '/include/') == -1
        let header = substitute(header, '^.*/include/', '', '')
    else
        let header = substitute(header, '^.*/include/', '', '')
    endif

    return header
endfunction

function! s:f.getNamespaceFilename(...)
    return GetNSFName(0)
endfunction

function! s:f.getNamespaceFilenameDefine(...)
    return GetNSFNameDefine()
endfunction

function! s:f.getHeaderForCurrentSourceFile(...)
    return GetHeaderForCurrentSourceFile()
endfunction

function! s:f.insertNamespaceEnd(...)
    return InsertNameSpaceEnd()
endfunction

function! s:f.insertNamespaceBegin(...)
    return InsertNameSpaceBegin()
endfunction

function! s:f.returnSkeletonsFromPrototypes(...)
    return protodef#ReturnSkeletonsFromPrototypesForCurrentBuffer({ 'includeNS' : 0})
endfunction


" ================================= Snippets ===================================
XPTemplateDef


XPT vector hint=std::vector<..>\ ..;
std::vector<`type^> `var^;
`cursor^


XPT map hint=std::map<..,..>\ ..;
std::map<`typeKey^,`val^> `name^;
`cursor^


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


"XPT try hint=Try/catch\ block
"try
"{
"    `what^
"}
"catch (`Exception^& e...^)
"{
"    `handler^
"}
"`...^catch (`Exception^& e...^)
"{
"    `handler^
"}`...^
"..XPT


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


XPT test hint=Test\ cpp\ file\ definition
/*
 * `getNamespaceFilename()^
 *
 * `:copyright:^
 *
`:timestamp:^
 */


#include <cppunit/HelperMacros.h>

class `fileRoot()^ : public CPPUNIT_NS::TestCase
{
    CPPUNIT_TEST_SUITE(`fileRoot()^);
    CPPUNIT_TEST(test);
    CPPUNIT_TEST_SUITE_END();

public:
    void test`Function^()
    {
        `cursor^
    }
};

CPPUNIT_TEST_SUITE_REGISTRATION(`fileRoot()^);
..XPT


XPT tf hint=Test\ function\ definition
void test`Name^()
{
    `cursor^
}
..XPT


XPT tsp hint=Typedef\ of\ a\ smart\ pointer
typedef std::tr1::shared_ptr<`type^> `type^Ptr;
..XPT


XPT sp hint=Smart\ pointer\ usage
`const ^std::tr1::shared_ptr<`type^>& `cursor^
..XPT


XPT fullmain hint=C++\ main\ including\ #includes
/*
 * `getNamespaceFilename()^
 *
 * `:copyright:^
 *
`:timestamp:^
 */


#include <map>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

int main(int argv, char** argv)
{
    `cursor^

    return 0;
}
..XPT


XPT src hint=C++\ implementation\ file
/*
 * `getNamespaceFilename()^
 *
 * `:copyright:^
 *
`:timestamp:^
 */


#include <`getHeaderForCurrentSourceFile()^>
`insertNamespaceBegin()^`returnSkeletonsFromPrototypes()^`cursor^`insertNamespaceEnd()^
..XPT


XPT header hint=C++\ header\ file
/*
 * `getNamespaceFilename()^
 *
 * `:copyright:^
 *
`:timestamp:^
 */

#ifndef __`getNamespaceFilenameDefine()^__
#define __`getNamespaceFilenameDefine()^__

`insertNamespaceBegin()^/**
 * @brief `classDescription^
 */
class `fileRoot()^
{
    public:
        /**
         * Constructor
         */
        `fileRoot()^();

        /**
         * Destructor
         */
        virtual ~`fileRoot()^();

        `cursor^
};`insertNamespaceEnd()^

#endif // __`getNamespaceFilenameDefine()^__
..XPT


XPT functor hint=Functor\ definition
struct `FunctorName^
{
    `void^ operator()(`argument^`...^, `arg^`...^)` const^
}
..XPT


XPT class hint=Class\ declaration
/*
 * Class: `fileRoot()^
 *
 * `:copyright:^
 *
`:timestamp:^
 */

/**
 * @brief `briefDescription^
 */
class `fileRoot()^
{
    public:
        `fileRoot()^(`argument^`...^, `arg^`...^);
        virtual ~`fileRoot()^();
        `cursor^
};
..XPT


XPT hfun hint=Member\ function\ declaration
/**
 * `functionName^
 *
 * `cursor^
 */
`int^ `functionName^(`argument^`...^, `arg^`...^)` const^;
..XPT


XPT css hint=const\ std::string&
const std::string& `cursor^
..XPT


XPT cout hint=Basic\ std::cout\ statement
std::cout << "`cursor^" << std::endl;
..XPT


XPT cerr hint=Basic\ std::cerr\ statement
std::cerr << "`cursor^" << std::endl;
..XPT


XPT outcopy hint=Using\ an\ iterator\ to\ output\ to\ stdout
std::copy(`list^.begin(), `list^.end(), std::ostream_iterator<`std::string^>(std::cout, \"\\n\"));
..XPT


XPT boosth hint=Boost\ header\ file\ inclusion
// The boost libraries don't compile well at warning level 4.
// No big surprise here... boost pushes the limits of compilers
// in the extreme.  Warning level 3 is clean.
#pragma warning(push, 3)
#include <boost/`tr1/memory.hpp^>
#pragma warning(pop)
..XPT


XPT cf hint=CPPUNIT_FAIL
CPPUNIT_FAIL("`message^")
..XPT


XPT ca hint=CPPUNIT_ASSERT
CPPUNIT_ASSERT(`condition^)
..XPT


XPT cae hint=CPPUNIT_ASSERT_EQUAL
CPPUNIT_ASSERT_EQUAL(`expected^, `actual^)
..XPT


XPT cade hint=CPPUNIT_ASSERT_DOUBLES_EQUAL
CPPUNIT_ASSERT_DOUBLES_EQUAL(`expected^, `actual^, `delta^)
..XPT


XPT cam hint=CPPUNIT_ASSERT_MESSAGE
CPPUNIT_ASSERT_MESSAGE(`message^, `condition^)
..XPT


XPT cat hint=CPPUNIT_ASSERT_THROW
CPPUNIT_ASSERT_THROW(`expression^, `ExceptionType^)
..XPT


XPT cant hint=CPPUNIT_ASSERT_NO_THROW
CPPUNIT_ASSERT_NO_THROW(`expression^)
..XPT

