" ==========================================================
" File Name:    objc_snippets.vim
" Author:       StarWing
" Maintainer: 	Felix Ingram
" Version:      0.1
" Last Change:  2009-02-17 19:07:01
" ==========================================================
" s:define_snippets {{{1

function! s:define_snippets()
    DefineSnippet cat         @interface <{NSObject}> (<{Category}>)<CR><CR>@end<CR><CR><CR>@implementation <{NSObject}> (<{Category}>)<CR><CR><{}><CR><CR>@end<CR><{}>
    DefineSnippet delacc      - (id)delegate;<CR><CR>- (void)setDelegate:(id)delegate;<CR><{}>
    DefineSnippet ibo         IBOutlet <{NSSomeClass}> *<{someClass}>;<CR><{}>
    DefineSnippet dict        NSMutableDictionary *<{dict}> = [NSMutableDictionary dictionary];<CR><{}>
    DefineSnippet Imp         #import <<{}>.h><CR><{}>
    DefineSnippet objc        @interface <{class}> : <{NSObject}><CR>{<CR>}<CR>@end<CR><CR>@implementation <{class}><CR>- (id)init<CR>{<CR>self = [super init]; <CR>if (self != nil)<CR>{<CR><{}><CR>}<CR>return self;<CR>}<CR>@end<CR><{}>
    DefineSnippet imp         #import "<{}>.h"<CR><{}>
    DefineSnippet bez         NSBezierPath *<{path}> = [NSBezierPath bezierPath];<CR><{}>
    DefineSnippet acc         - (<{"unsigned int"}>)<{thing}><CR>{<CR>return <{fThing}>;<CR>}<CR><CR>- (void)set<{thing:toupper(@z)}>:(<{"unsigned int"}>)new<{thing}><CR>{<CR><{fThing}> = new<{thing}>;<CR>}<CR><{}>
    DefineSnippet format      [NSString stringWithFormat:@"<{}>", <{}>]<{}>
    DefineSnippet focus       [self lockFocus];<CR><CR><{}><CR><CR>[self unlockFocus];<CR><{}>
    DefineSnippet setprefs    [[NSUserDefaults standardUserDefaults] setObject:<{object}> forKey:<{key}>];<CR><{}>
    DefineSnippet log         NSLog(@"%s<{s}>", <{s:repeat(', <{}>', cca:count(@z, '%[^%]'))}>);<{}>
    DefineSnippet gsave       [NSGraphicsContext saveGraphicsState];<CR><{}><CR>[NSGraphicsContext restoreGraphicsState];<CR><{}>
    DefineSnippet forarray    for(unsigned int index = 0; index < [<{array}> count]; index += 1)<CR>{<CR><{id}>object = [<{array}> objectAtIndex:index];<CR><{}><CR>}<{}>
    DefineSnippet classi      @interface <{ClassName}> : <{NSObject}><CR><CR>{<{}><CR><CR>}<CR><CR><{}><CR><CR>@end<CR><{}>
    DefineSnippet array       NSMutableArray *<{array}> = [NSMutableArray array];<{}>
    DefineSnippet getprefs    [[NSUserDefaults standardUserDefaults] objectForKey:<key>];<{}>
    DefineSnippet cati        @interface <{NSObject}> (<{Category}>)<CR><CR><{}><CR><CR>@end<CR><{}>
endfunction

" }}}1
" s:set_compiler_info {{{1

function! s:set_compiler_info()
    
endfunction

" }}}1

if exists('loaded_cca')
    filetype indent on

    " TODO: what is the ext-name of this filetype ?
    " let b:{cca_filetype_ext_var} = '<{ext}>'
    let b:{cca_locale_tag_var} = { "start": "<{", "end" : "}\>", "cmd" : ":"}

    call s:define_snippets()
endif

if exists('loaded_ctk')
    " let b:{ctk_filetype_ext_var} = '<{ext}>'
    call s:set_compiler_info()
endif

delfunc s:define_snippets
delfunc s:set_compiler_info
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sts=4:sw=4:nu:et:sta:ai
