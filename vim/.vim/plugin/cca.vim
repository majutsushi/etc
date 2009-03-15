" ==========================================================
" Script Name:  code complete again
" File Name:    cca.vim
" Author:       StarWing
" Version:      0.2
" Last Change:  2009-02-14 22:57:15
" How To Use: {{{1
"       Useage:
"
"           this is a re-code version of code_complete(new update)
"           (http://www.vim.org/scripts/script.php?script_id=2427) the
"           original version of code_complete is write by mingbai, at
"           (http://www.vim.org/scripts/script.php?script_id=1764)
"
"           this plugin remix the features of code_complete and snippetEmu,
"           you can put the snippet file in the cca_snippets_folder (defaultly
"           "snippets"), and put template file in cca_template_folder
"           (defaultly "templates"). then you can input a tigger word and a
"           hotkey to complete. e.g: if the hotkey is <m-d> (Alt+d or Meta+d,
"           i found this combine-key is easy to press :) ) and you has a
"           snippet named foo, when you input the "foo<m-d>", it maybe changed
"           to: (which "|" is the position of your cursor)
"
"               foobar|
"
"           cca support snippetsEmu-style named tag and command tag in your
"           snippet (and template file). you can define the tag-mark youself,
"           and it will be highlighted (if you open the built-in highlight
"           function of Vim). this is a summary of the kinds of tag. (the tags
"           will be highlighted special, if you open highlight. and suppose
"           the cca_tagstart is "<{". the tagcommand is ':',  and the tagend
"           is "}>")
"
"               - cursor tag:  <{}>  or <{:}> if you press hotkey, and next
"                               tag is a empty tag, the cursor will move to
"                               there.
"               - named tag:    <{foo}> after you press hotkey, the name of
"                               the tag will selected, and if you input a text
"                               to replace it, all tag has the same name with
"                               current tag will be replaced to the same
"                               value.  e.g:  (the pipe is position of cursor)
"
"                               |   <{foo:1}> is a <{foo:2}>. 
"
"                               after you press <a-d> and input "bar"
"                               directly, it will changed to:
"
"                               bar| is a bar.
"
"                               the :1 and :2 mark is for sign tags for
"                               regconize it when you make nest tags.
"
"               - identifier tag:
"                               cca must register tag's name and command for
"                               replace nest tag correctlly.  if you can sure
"                               the tag is only for name replace, user won't
"                               make complete in it (that is, it will never be
"                               a nest tag), and it didn't have any command,
"                               you can just add a "cmd" mark after
"                               identifier.  e.g: <{i:}>. and cca won't
"                               register this tag.
"
"               - command tag:  <{foo:1}>, or <{:1}> where "1" may be any
"                               number. this is the command number in
"                               dictionary b:cca.tag_table. if this is a
"                               noname command tag, the command will calculate
"                               immediately. and if it has a name, it will act
"                               as a named tag, and calculate the command when
"                               you leave the tag (goto the next tag).  the
"                               "xt" snippet in common.vim is a noname command
"                               tag, and "printf" in c_snippets.vim is a named
"                               command tag.
"
"                       XXX:    you can complete at normal, select and insert
"                               mode, but you must notice that the first char
"                               of tag is not "in" the tag.  e.g: |<{A}> now
"                               cursor is NOT in the tag A. so it is in normal
"                               mode, so if you want to jump to next tag, you
"                               should make sure the cursor is just in the tag
"
"       Options:
"
"               cca_hotkey      this defined the hotkey for complete
"
"               cca_submitkey   this defined the submitkey.(that is, jump over
"                               a line, and leave all tags in this line into
"                               its default value).
"
"               cca_tagstart
"               cca_tagend
"               cca_tagcommand  this defined the tag mark. and you can
"                               define them as buffer-variables. 
"             
"               cca_search_range
"                               this define the search range for tag jump.
"                               defaultly it is 100, it means just search the
"                               tags in 100 line under current line. if it set
"                               to zero, only search tags in screen.
"
"               cca_filetype_ext_var
"                               this define the filetype buffer variable name.
"                               snippets support this name to show the ext
"                               name for specific filetype. it defaultly
"                               "ft_ext", and b:ft_ext will be used as a
"                               ext-name specified variable name.
"
"               cca_locale_tag_var
"                               this is a dictionary name for snippets file
"                               show its locale tag marks. it has three item:
"                               start, end and cmd. it defined tagstart,
"                               tagend and tagcommand in specified snippets
"                               file.
"
"                       XXX:    to use cca_filetype_ext_var and
"                               cca_locale_tag_var, see the specified snippets
"                               files.
"
"               cca_snippets_folder
"               cca_template_folder
"                               these define the default folder where cca to
"                               find the snippets files and template files. it
"                               must be found at 'runtimepath'.
"
"
"       Command:
"
"               StartComplete
"               StopComplete
"                               Start and stop the complete this will register
"                               or unregister the key map and do some
"                               initialliztion or clean work.
"
"               DefineSnippet   define the snippets. each snippets file are
"                               all combined with this command. the format is:
"                               DefineSnippet {trigger word}: {complete text}
"                               trigger word can be anything. it can have
"                               space, can be a symbol. but if it have space
"                               and have more than one symbol, when you input
"                               it, you should add a "#" before it. e.g: now
"                               we define a sinppet:
"
"                       DefineSnippet trigger with word: this is a trigger with <{}>word
"
"                               then we can input:
"                               #trigger with word<m-d>
"
"                               then it will change to:
"                               this is a trigger with |word
"
"                               the cursor is before "word"
"
"               RefreshSnippets refresh the current snippets file. if no
"                               filetype is set, this command will load
"                               "common.vim" in snippets folder. the snippets
"                               file is under "filetype" folder in snippets
"                               folder, or named "filetype_others.vim", which
"                               others can be any words. all of snippets file
"                               will load in.
"             
" this line is for getscript.vim:
" GetLatestVimScripts: 2535  1 :AutoInstall: cca.vim
" }}}1
" Must After Vim 7.0 {{{1

if exists('loaded_cca')
    finish
endif
let loaded_cca = 'v0.1'

if v:version < 700
    echomsg "cca.vim requires Vim 7.0 or above."
    finish
endif

" :%s/" \zeCCAtrace//g
" :%s/^\s*\zsCCAtrace/" &/g
" map <m-r> :exec '!start '.expand('%:p:h:h').'/run.cmd'<CR>
" let s:debug = 1
let old_cpo = &cpo
set cpo&vim

" }}}1
" ==========================================================
" Options to modify cca {{{1

" complete hotkey {{{2

if !exists('cca_hotkey')
    let cca_hotkey = "<m-d>"
endif

if !exists('cca_submitkey')
    let cca_submitkey = "<m-s>"
endif

" }}}2
" marks for jump {{{2

" tag start mark {{{3

if !exists('cca_tagstart')
    let cca_tagstart = '<{'
endif

" }}}3
" tag end mark {{{3

if !exists('cca_tagend')
    let cca_tagend = '}>'
endif

" }}}3
" the beginning of command in tag {{{3
if !exists('cca_command')
    let cca_tagcommand = ':'
endif

" }}}3

" }}}2
" search range {{{2

if !exists('cca_search_range')
    let cca_search_range = 100
endif

" }}}2
" default filetype ext buffer-variable {{{2
" the 'filetype' name isn't always the ext-name of file. so if file-ext isn't
" same with filetype, use this variable. for default, if you set
" cca_filetype_ext_var to 'ft_ext' (just let it is), this variable is"
" "b:ft_ext", but you can change it. it normally defined in {&ft}_snippets.vim
" in your cca_snippets_folder

if !exists('cca_filetype_ext_var')
    let cca_filetype_ext_var = 'ft_ext'
endif

" }}}2
" locale tags in snippets plugin file {{{2
" the tags in your snippets may different with your settings, but they can use
" this var to converse the locale tags into your tags.

if !exists('cca_locale_tag_var')
    let cca_locale_tag_var = 'snippets_tag'
endif

" }}}2
" snippets folder {{{2

if !exists('cca_snippets_folder')
    let cca_snippets_folder = 'snippets'
endif

" }}}2
" template folder {{{2

if !exists('cca_template_folder')
    let cca_template_folder = 'templates'
endif

" }}}2

" }}}1
" Commands, autocmds and menus {{{1

" commands
command! -nargs=+ DefineSnippet :call s:define_snippets(<q-args>)
command! -nargs=+ -complete=file -range=% MakeTemplate
            \ :<line1>,<line2>call s:make_template(<q-args>)
command! -bar EditSnippets :call s:edit_snippetsfile()
command! -bar -bang RefreshSnippets :call s:refresh_snippets('<bang>')
command! -bar -bang StartComplete :call s:start_complete('<bang>')
command! -bar StopComplete :call s:stop_complete()

if exists('s:debug') && s:debug == 1
    set noshowmode
    command! -nargs=+ CCAtrace echom 'cca: '.<args>
else
    command! -nargs=+ CCAtrace
endif

" autocmds
augroup cca_autocmd
    au!
    au VimEnter * StartComplete
    au BufNew * StartComplete|CCAtrace 'BufNew:'.expand('<amatch>')
    au FileType * StartComplete|CCAtrace 'FileType:'.expand('<amatch>')
augroup END

" menus
amenu &Tools.&cca.&Start\ Complete :StartComplete<CR>
amenu &Tools.&cca.S&top\ Complete :StopComplete<CR>
amenu &Tools.&cca.&Refresh\ Snippets :RefreshSnippets<CR>

" highlight link
hi def link ccaTag Identifier
hi def link ccaTagMatch Special

" }}}1
" ==========================================================
" main {{{1

" s:start_complete {{{2

function! s:start_complete(bang)
    " create buffer info
    call s:refresh_menu()
    if !exists('b:cca') || b:cca.cur_ft != &ft || a:bang == '!'
        call s:refresh_snippets(a:bang)
    endif

    if exists('b:cca')
        " maps
        if !hasmapto('<Plug>CCA_complete', 'iv')
            exec 'imap <buffer>'.g:cca_hotkey.' <Plug>CCA_complete'
            exec 'nmap <buffer>'.g:cca_hotkey.' <Plug>CCA_complete'
            exec 'smap <buffer>'.g:cca_hotkey.' <Plug>CCA_complete'
        endif

        if !hasmapto('<Plug>CCA_submit'. 'iv')
            exec 'imap <buffer>'.g:cca_submitkey.' <Plug>CCA_submit'
            exec 'nmap <buffer>'.g:cca_submitkey.' <Plug>CCA_submit'
            exec 'smap <buffer>'.g:cca_submitkey.' <Plug>CCA_submit'
        endif

        imap <silent> <script> <Plug>CCA_complete <C-R>=<SID>complete()<CR>
                    \<C-R>=<SID>jump_next()<CR>
        imap <silent> <script> <Plug>CCA_submit <C-R>=<SID>complete()<CR>
                    \<C-R>=<SID>submit()<CR>
        nmap <silent> <script> <Plug>CCA_complete i<C-R>=<SID>jump_next()<CR>
        nmap <silent> <script> <Plug>CCA_submit i<C-R>=<SID>submit()<CR>
        smap <silent> <script> <Plug>CCA_complete <ESC>i<C-R>=<SID>jump_next()<CR>
        smap <silent> <script> <Plug>CCA_submit <ESC>i<C-R>=<SID>submit()<CR>

        " create syntax group
        " FIXME: must define syntax region every time. if we don't define it when
        " the b:cca is exists, the hightlight will invaild, anyone knows why?
        exec 'syntax region ccaTag matchgroup=ccaTagMatch keepend extend '.
                    \ "contains=ccaTag containedin=ALL oneline start='".
                    \ b:cca.pat.start.'\ze.{-}'.b:cca.pat.end."' skip='".'\\'.
                    \ b:cca.pat.end."' end='\\%(".b:cca.pat.cmd.'\d+)='.
                    \ b:cca.pat.end."'"
    endif
endfunction

" }}}2
" s:stop_complete {{{2

function! s:stop_complete()
    syntax clear ccaTag
    unlet! b:cca
    exec 'iunmap <buffer>'.g:cca_hotkey
    exec 'iunmap <buffer>'.g:cca_submitkey
    exec 'nunmap <buffer>'.g:cca_hotkey
    exec 'nunmap <buffer>'.g:cca_submitkey
    exec 'sunmap <buffer>'.g:cca_hotkey
    exec 'sunmap <buffer>'.g:cca_submitkey
endfunction

" }}}2
" s:complete {{{2
" the main complete function, will called immedially when you press the hotkey

function! s:complete()
    " special!
    if b:cca.status.jump > 0
        return ''
    endif

    let b:cca.status.line = line('.')
    let b:cca.status.col = col('.')
    let ret = (g:cca_hotkey =~ '\c<tab>' ? "\<tab>" : '')

    " find the keyword for complete
    let c_line = getline('.')[:col('.')-2]
    let mlist = matchlist(c_line, '\v((\w+)\s*(\()=)$')

    " if has '(', it's a function complete
    if !empty(mlist) && mlist[3] != ''
        let text = s:function_complete(mlist[2])
        return text != '' ? text : ret
    endif

    " s:text is the return string value of s:process_call()
    if !empty(mlist) && s:process_call(mlist)
        return s:text
    endif

    for pat in ['\v((\W+)\s*)$', '\v((\S+)\s*)$', '\v(#\s*(.{-})\s*)$']
        let mlist = matchlist(c_line, pat)
        if !empty(mlist) && s:process_call(mlist)
            return s:text
        endif
    endfor

    return ret
endfunction

" }}}2
" s:submit {{{2

function! s:submit()
    let line = (b:cca.status.jump > 0 ? b:cca.status.line : line('.'))

    try
        exec 'norm! '.s:jump_next()
        while line('.') == line
            exec 'norm! '.s:jump_next()
        endwhile
    catch
    endtry

    return line('.') == line ? "\<C-\>\<C-N>$a" : ''
endfunction

" }}}2
" s:jump_next {{{2
" jump to next tag and calculate command section of tag, if need.

function! s:jump_next()
    " special!
    if b:cca.status.jump < 0
        let b:cca.status.jump = 1
        return ''
    endif

    " CCAtrace 'jump_next() line: '.getline('.')
    call setpos("''", getpos('.'))

    if b:cca.status.jump > 0
        let b:cca.status.jump = 0
        call cursor(b:cca.status.line, b:cca.status.col)
    endif

    let bound = s:get_tag_bound()
    " CCAtrace 'jump_next: bound:'.string(bound)
    if bound[1] == 0 || bound[1] == -2
        let bound = s:replace_tags(bound)
    endif

    let pair = s:find_next_tag(bound[0])
    if empty(pair)
        let b:cca.tag_table = {}
        call setpos('.', getpos("''"))
        return ''
    endif

    " CCAtrace 'jump_next: tag:'.getline('.')[pair[0]-1:pair[1]-1]
    " get tag information
    let info = s:get_tag_info(pair)
    " CCAtrace 'jump_next: info:'.string(info)

    " if tag name is not empty, register the name of tag. the command runs
    " when you leaved the tag, so we needn't process it now.
    if !empty(info[0])
        let b:cca.status.cur_tag = info[0]

        " we just select the info[0] now
        let begin = pair[0] + strlen(b:cca.tag.start)
        call s:select_text([begin, begin + strlen(info[0]) - 1])
        return "\<c-\>\<c-n>gvo\<c-g>"
    endif

    " if command is not empty (and the tag name is empty), we process the
    " command at next jump.
    if !empty(info[1])
        " calc the command
        call s:exec_cmd(info[1], pair)
        " run jump_next again
        return s:jump_next()
    endif

    " no command, and no name, just jump to there
    call s:select_text(pair)
    return "\<c-\>\<c-n>gvc"
endfunction

" }}}2

" }}}1
" complete {{{1

" function complete {{{2

function! s:function_complete(word)
    CCAtrace 'function_complete() called word='.a:word
    let sig_list = []
    let sig_word = {}
    let ftags = taglist('^\V'.escape(a:word, '\').'\$')

    " CCAtrace 'function_complete() tag='.string(ftags)
    " if can't find the function
    if empty(ftags)
        return ''
    endif

    for item in ftags
        " item must have keys kind, name and signature, and must be the
        " type of p(declare) or f(defination), function name must be same
        " with a:fun, and must have param-list
        " if any reason can't satisfy, to next iteration
        if !has_key(item, 'kind') || (item.kind != 'p' && item.kind != 'f')
                    \ || !has_key(item, 'name') || item.name != a:word
                    \ || !has_key(item, 'signature')
                    \ || match(item.signature, '^(\s*\%(void\)\=\s*)$') >= 0
            continue
        endif
        let sig = s:process_signature(item.signature).cca:make_tag()
        if !has_key(sig_word, sig)
            let sig_word[sig] = 0
            let sig_list += [{'word': sig, 'menu': item.filename}]
        endif
    endfor

    " only one list find, that is we need!
    if len(sig_list) == 1
        let b:cca.status.jump = 1
        return sig_list[0].word
    endif

    " can't find the argument-list, means it's a void function
    if empty(sig_list)
        return ')'
    endif

    " make a complete menu
    let b:cca.status.jump = -1
    call complete(col('.'), sig_list)
    return ''
endfunction

" }}}2
" template complete {{{2

function! s:template_complete(word)
    let fname = get(b:cca.tmpfiles, a:word, '')

    if empty(fname)
        return ''
    endif

    let tlist = readfile(fname)
    if empty(tlist)
        return ''
    endif

    " read the modeline of template file
    let mline = matchstr(tlist[0], '\<cca:\v\s*\zs%(.{-}\:)+')
    if !empty(mline)
        let tag_marks = {}

        for expr in filter(split(mline, '\s*\\\@<!:\s*'),
                    \ '!empty(v:val) && v:val =~ "="')
            let expr = substitute(expr, '\:', ':', 'g')
            silent! sandbox exec 'let tag_marks.'.expr
        endfor
        call remove(tlist, 0)
    endif

    let indent = matchstr(getline('.'), '^\s*')
    let text = join(tlist, "<CR><ESC>Vc0<C-D>".indent)

    if exists('tag_marks')
        let text = s:format_tags(tag_marks, text)
    endif

    exec 'let text = "'.escape(text, '"<\').'"'

    return substitute(text, b:cca.pat.start.'([^'."\<CR>".']{-})\\@<!'.
                \ b:cca.pat.end, '\=cca:register_tag()', 'g')
endfunction

" }}}2
" snippets complete {{{2

function! s:snippet_complete(word)
    let text = get(b:cca.snippets, s:encode(a:word), '')
    " CCAtrace 'snippet_complete() called, word = '.a:word.
                \ ', encoded word = '.s:encode(a:word)

    if text == ''
        return ''
    endif

    exec 'let text = "'.escape(text, '"<\').'"'

    return substitute(text, b:cca.pat.start.'([^'."\<CR>".']{-})\\@<!'.
                \ b:cca.pat.end, '\=cca:register_tag()', 'g')
endfunction

" }}}2

" }}}1
" utility {{{1

" cca:count {{{2
function! cca:count(haystack, pattern)
    let counter = 0
    let index = match(a:haystack, a:pattern)
    while index > -1
        let counter = counter + 1
        let index = match(a:haystack, a:pattern, index+1)
    endwhile
    return counter
endfunction

" }}}2
" cca:make_tag {{{2

function! cca:make_tag(...)
    let text = a:0 != 0 ? a:1 : ''
    return b:cca.tag.start . text . b:cca.tag.end
endfunction

" }}}2
" cca:normal {{{2

function! cca:normal(cmd, ...)
    exec 'norm'.(a:0 == 0 ? '' : a:1).' '.a:cmd
    return ''
endfunction

" }}}2
" cca:format_tag {{{2

function! cca:format_tag(end)
    let te = b:cca.tag.end
    let cmd = submatch(2)

    if !empty(cmd)
        if a:end != te
            let cmd = substitute(cmd, b:cca.pat.end, '\'.te, 'g')
            let cmd = substitute(cmd, '\\\V'.escape(a:end, '\'), a:end, 'g')
        endif
        let cmd = b:cca.tag.cmd . cmd
    endif

    return cca:make_tag(submatch(1).cmd)
endfunction

" }}}2
" cca:register_tag {{{2

function! cca:register_tag()
    let info = s:get_tag_info(submatch(0))
    let [idx, cmd, dict] = [1, '', b:cca.tag_table]

    while has_key(dict, idx)
        let idx += 1
    endwhile

    if info[1] != '' || (info[0] != '' && info[2] != '')
        let dict[idx] = [info[0], substitute(info[1], '\\'.b:cca.pat.end,
                    \ b:cca.tag.end, 'g')]
        let cmd = b:cca.tag.cmd . idx
    endif

    return cca:make_tag(info[0] . cmd)
endfunction

" }}}2
" cca:unlet {{{2

function! cca:unlet(var)
    exec 'silent! unlet '.var
endfunction

" }}}2
" s:echoerr {{{2

function! s:echoerr(msg)
    echohl ErrorMsg
    echomsg 'cca: '.a:msg
    echohl NONE
endfunction

" }}}2
" s:strtrim {{{2

function! s:strtrim(str)
    return matchstr(a:str, '^\s*\zs.\{-}\ze\s*$')
endfunction

" }}}2
" s:encode s:decode {{{2
" s:encode allows the use of special characters in snippets
function! s:encode(text)
    return substitute(a:text, '\(\A\)',
                \ '\="%".char2nr(submatch(1))', 'g')
endfunction

" s:decode allows the use of special characters in snippets
function! s:decode(text)
    return substitute(a:text, '%\(\d\+\)',
                \ '\=nr2char(submatch(1))', 'g')
endfunction
" }}}2
" s:create_bufinfo {{{2

function! s:create_bufinfo()
    let b:cca = {}
    " the info table of tags, will fill by cca:register_tag()
    let b:cca.tag_table = {}
    let b:cca.snippets = {}
    let b:cca.tmpfiles = {}
    let b:cca.cur_ft = &ft

    " the status of complete, 
    " cur_tag is the current tag's name
    " jump shows whether jump to the head before jump_next, 
    " >0: jump to the status.line and col
    " 0: do not jump, just find tags at current position
    " <0: pass the chance to jump_next()
    " line and col is the position of begining of complete, 
    let b:cca.status = {
                \ 'cur_tag': "",
                \ 'jump': 0,
                \ 'line': 0,
                \ 'col': 0}

    " will fill at once below. tag and tag pattern
    let b:cca.tag = {
                \ 'start': 'tagstart',
                \ 'end': 'tagend',
                \ 'cmd': 'tagcommand'}
    let b:cca.pat = {}

    for [key, val] in items(b:cca.tag)
        if exists('b:cca_'.val)
            let b:cca.tag[key] = b:cca_{val}
        else
            let b:cca.tag[key] = g:cca_{val}
        endif
        let b:cca.pat[key] = '\V'.escape(b:cca.tag[key], '\').'\v'
    endfor
endfunction

" }}}2
" s:define_snippets {{{2

function! s:define_snippets(cmd)
    if bufname("%") =~ 'NERD_tree'
        return
    endif

    if !exists('b:cca')
        call s:create_bufinfo()
    endif

    " find first ":" without a '\' before itself.
    let mlist = matchlist(a:cmd, '\v^(.{-})\\@<!\s+(.+)$')
    if empty(mlist)
        return
    endif

    " calculate the name and value
    let name = s:encode(s:strtrim(substitute(mlist[1], '\\\ze\s', '', 'g')))
    let value = s:strtrim(mlist[2])

    " format the tag, if needed
    if exists('b:'.g:cca_locale_tag_var)
        let value = s:format_tags(b:{g:cca_locale_tag_var}, value)
    endif

    " registe the snippet
    let b:cca.snippets[name] = value
endfunction

" }}}2
" s:refresh_snippets {{{2

function! s:refresh_snippets(bang)
    if a:bang == '!'
        silent! unlet b:cca
    endif

    let sf = g:cca_snippets_folder

    exec 'runtime! '.sf.'/common.vim'
    
    if !empty(&ft)
        for name in split(&ft, '\.')
            exec 'runtime! '.sf.'/'.name.'.vim '.sf.'/'.name.'_*.vim '.
                        \ sf.'/'.name.'/*.vim'
        endfor

        let tf = g:cca_template_folder
        let ft_ext = get(b:, g:cca_filetype_ext_var, &ft)
        for file in split(globpath(&rtp, tf.'/*'), "\<NL>")
            let ext = fnamemodify(file, ':e')
            if empty(ext) || ext == ft_ext
                let b:cca.tmpfiles[fnamemodify(file, ':t:r')] = file
            endif
        endfor
    endif
endfunction

" }}}2
" s:make_template {{{2

function! s:make_template(file) range
    let com_start = matchstr(&comments, 's.\=:\zs[^,]\+\ze')
    if !empty(com_start)
        let com_start .= ' '
        let com_end = ' '.matchstr(&comments, 'e.\=:\zs[^,]\+\ze')
    else
        let com_start = matchstr(&comments, ':\zs[^,]\+').' '
        let com_end = ''
    endif
    let template = [com_start.'cca: start="'.escape(b:cca.tag.start, '\":').
                \ '" : end="'.escape(b:cca.tag.end, '\":').
                \ '" : cmd="'.escape(b:cca.tag.cmd, '\":').'" :'.com_end]

    let pat = '^\s\{'.(&et ? indent(a:firstline) :
                \ indent(a:firstline)/&ts).'}'

    for i in range(a:firstline, a:lastline)
        let text = substitute(getline(i), pat, '', '')
        let text = substitute(text, '<', '<lt>', 'g')
        let text = substitute(text, "\r", '<NL>','g')
        let template = template + [text]
    endfor

    if exists('b:'.g:cca_filetype_ext_var)
                \ && !empty(b:{g:cca_filetype_ext_var})
        let ft_ext = '.'.b:{g:cca_filetype_ext_var}
    elseif !empty(&ft)
        let ft_ext = '.'.&ft
    else
        let ft_ext = ''
    endif

    for dir in split(globpath(&rtp, g:cca_template_folder), "\<NL>")
        let fname = dir.glob('/').fnamemodify(a:file, ':t:r').ft_ext
        try
            if writefile(template, fname) == 0
                echomsg 'template write success: '.fname
                echomsg len(template)." line(s) written"
            endif
        catch
            call s:echoerr('template write failed: '.v:exception)
        endtry
        return
    endif
endfunction

" }}}2
" s:edit_snippetsfile {{{2

function! s:edit_snippetsfile()
    let filelist = []
    let sf = g:cca_snippets_folder
    let filelist += split(globpath(&rtp, sf.'/common.vim'), "\<NL>")

    if &ft != ''
        let filelist += split(globpath(&rtp, sf.'/'.&ft.'/*.vim'), "\<NL>")
        let filelist += split(globpath(&rtp, sf.'/'.&ft.'_*.vim'), "\<NL>")
    endif

    if !empty(filelist)
        if len(filelist) == 1
            exec 'drop '.escape(filelist[0], ' ')
        else
            let idx = 1
            let list = ["Select a snippets file:"]
            for file in filelist
                let list += [idx.'. '.file]
                let idx += 1
            endfor
            let res = get(filelist, inputlist(list)-1, '')
            if !empty(res)
                exec 'drop '.escape(res, ' ')
            endif
        endif
    endif
endfunction

" }}}2
" s:refresh_menu {{{2

function! s:refresh_menu()
    let ft = {}
    let sf = g:cca_snippets_folder
    for file in split(globpath(&rtp, sf.'/*'), "\<NL>")
        let type = matchlist(file, '\V'.escape(sf, '\').
                    \ '\v[\\/]%(([^\\/]*)[\\/]|([^_]*)%(_)=).*\.vim')
        if empty(type)
            continue
        endif
        let key = (!empty(type[1]) ? type[1] : type[2])
        if !empty(key) && !has_key(ft, key)
            let ft[key] = ''
            exec 'amenu &Tools.cca.S&nippets\ File\ List.'.escape(key, ' \').
                        \ ' :run! '.sf.'/'.key.'/*.vim '.sf.'/'.key.'_*.vim<CR>'
        endif
    endfor
endfunction

" }}}2
" s:exec_cmd {{{2
" calc the tag-command, if needed. and save it to @z, then use it to replace
" the current selected tag.

function! s:exec_cmd(tag_nr, range)
    let tag = get(b:cca.tag_table, a:tag_nr, [])
    " CCAtrace 'exec_cmd() called, tag = '.string(tag)
    call s:select_text(a:range)

    if !empty(tag)
        call remove(b:cca.tag_table, a:tag_nr)
        if !empty(tag[1])
            try
                if tag[1][0] == '!'
                    let tag[1] = tag[1][1:]
                else
                    let old_z = @z
                endif
                let res = eval(tag[1])
                let @z = res
            catch
                " if eval has error occured, print error
                call s:echoerr('calculate command error, at ['.line('.').
                            \ ', '.col('.').'], tag_name = "'.tag[0].
                            \ '", expr = "'.tag[1].'":'.
                            \ matchstr(v:exception, 'E.*'))
            endtry
        endif
    endif

    " CCAtrace 'exec_cmd() line: '.getline('.')
    exec 'norm! gv"zp'
    " put cursor after the text we pasted
    if !empty(@z)
        call cursor(0, col('.') + 1)
    endif
    if exists('old_z')
        let @z = old_z
    endif
    " CCAtrace 'exec_cmd() line: '.getline('.')
endfunction

" }}}2
" s:find_next_tag {{{2

function! s:find_next_tag(end)
    " CCAtrace 'find_next_tag() called'
    " type([]) == 3
    let [end_line, end_col] = (type(a:end) == 3 ? a:end : [a:end, -1])
    let res = searchpos('\\\@<!'.b:cca.pat.start, 'nc', end_line)

    while 1
        " CCAtrace 'find_next_tag() res='.string(res)
        if res[1] == 0 || (end_col > 0 && res[1] > end_col)
            return []
        endif
        call cursor(res)
        if s:find_match_tag(0) >= 0
            return [res[1], col('.')]
        endif
        let res = searchpos('\\\@<!'.b:cca.pat.start, 'n', end_line)
    endwhile
endfunction

" }}}2
" s:find_match_tag {{{2
" if dir == 0, right, dir != 0, left. return the tags number between marks and
" cursor.

function! s:find_match_tag(dir)
    let cline = line('.')
    let [level, times] = [0, -1]
    let [flag, dir] = (a:dir ? ['bep', 1] : ['ep', -1])
    let pat = '\v\\@<!%(('.b:cca.pat.start.'&.)|('.b:cca.pat.end.'))'

    while level != dir
        let res = search(pat, flag, cline)
        if res == 0
            return -1
        endif
        let times += 1
        let level += (res == 2 ? 1 : -1)
    endwhile

    return times / 2
endfunction

" }}}2
" s:format_tags {{{2
" set the tags into the format in current buffer

function! s:format_tags(info, text)
    let t = copy(b:cca.tag)
    for key in keys(a:info)
        let t[key] = a:info[key]
    endfor

    let pat = '\V'.escape(t.start, '\').'\v(.{-})%(\V'.escape(t.cmd, '\').
                \ '\v(.*))=\\@<!\V'.escape(t.end, '\')

    return substitute(a:text, pat, '\=cca:format_tag(t.end)', 'g')
endfunction

" }}}2
" s:replace_tags {{{2
" replace tags in bound region. if this region is only a simple tag, replace
" all tag in file has same name with current tag. then, if the region is a
" next tag. replace tag in this bound region. return the new position after
" replaced.

function! s:replace_tags(bound)
    " CCAtrace 'replace_tags() called'
    let bound = a:bound
    while 1
        " CCAtrace 'replace_tags(): bound='.string(bound)
        if bound[1] == 0
            " a simple tag
            " CCAtrace 'replace_tags:replace begin'
            let old_z = @z
            let info = s:get_tag_info(bound[2])
            let @z = info[0]
            let cur_tag = empty(info[1]) ? b:cca.status.cur_tag :
                        \ get(b:cca.tag_table, info[1], [''])[0]
            " CCAtrace 'replace_tags:replace: cur_tag=:'.cur_tag
            call s:exec_cmd(info[1], bound[2])
            call setpos("''", getpos('.'))
            let bound = s:get_tag_bound()
            " CCAtrace 'replace_tags:replace: bound='.string(bound)

            if !empty(cur_tag)
                let view_save = winsaveview()
                let pair = s:find_next_tag(bound[0])
                if !empty(pair)
                    while !empty(pair)
                        let info = s:get_tag_info(pair)
                        if info[0] == cur_tag
                            call s:exec_cmd(info[1], pair)
                        endif
                        let pair = s:find_next_tag(bound[0])
                    endwhile
                    " CCAtrace 'replace_tags:replace end'
                    call winrestview(view_save)
                    let bound = s:get_tag_bound()
                endif
            endif
            let @z = old_z
        endif

        if bound[1] > 0 || bound[1] == -1
            return bound
        endif

        if bound[1] == -2
            " only head, delete it
            let cp = getpos('.')
            let ts_len = strlen(b:cca.tag.start)
            call cursor(0, bound[2])
            call s:delete_text(ts_len, 1)
            if col("''") >= bound[2] + ts_len
                call cursor(line("''"), col("''") - ts_len)
                call setpos("''", getpos('.'))
            endif
            if cp[1] >= bound[2] + ts_len
                call cursor(cp[0], cp[1] - ts_len)
            endif
            let bound = s:get_tag_bound()
        endif
    endwhile
endfunction

" }}}2
" s:get_tag_bound {{{2
" return [end, cnt, bound]

function! s:get_tag_bound()
    let [cline, col_save] = [line('.'), col('.')]
    " CCAtrace 'get_tag_bound() called col='.col_save

    let cnt = s:find_match_tag(1)
    if cnt == -1
        call cursor(0, col_save)
        " CCAtrace 'get_tag_bound() returned -1'
        return [(g:cca_search_range == 0 ? line('$') :
                \ cline + g:cca_search_range), -1]
    endif

    let col_start = col('.')
    let cnt = s:find_match_tag(0)
    if cnt == -1
        call cursor(0, col_save)
        " CCAtrace 'get_tag_bound() returned -2'
        return [(g:cca_search_range == 0 ? line('$') :
                \ cline + g:cca_search_range), -2, col_start]
    endif
    let col_end = col('.')

    " CCAtrace 'get_tag_bound() tag='.getline('.')[col_start-1:col_end-1]
    " CCAtrace 'get_tag_bound() returned '.cnt
    call cursor(0, col_save)
    return [[cline, col_end], cnt, [col_start, col_end]]
endfunction

" }}}2
" s:get_tag_info {{{2
" if args is a list, it's the column number range of current line. signs the
" beginning of tag and the end of tag. and if it's a string, it's the tag
" itself. if tag is in buffer, the number after last pc is the id of cmd,
" else, the identifier before the first pc is the id of tag.

function! s:get_tag_info(args)
    if type(a:args) == 3 " type([])
        let tag = getline('.')[a:args[0]-1:a:args[1]-1]
        let pat = '\d+'
    else
        let tag = a:args
        let pat = '.*'
    endif

    " get inner text of tag
    let inner = matchstr(tag, '^'.b:cca.pat.start.'\zs.{-}\ze\\@<!'.
                \ b:cca.pat.end.'$')

    if !empty(inner)
        " get tag(mlist[1]) and command(mlist[2])
        let mlist = matchlist(inner, '^\v(.{-})%(('.b:cca.pat.cmd.
                    \ ')('.pat.'))=$')
        return [mlist[1], mlist[3], mlist[2]]
    endif

    return ['', '', '']
endfunction

" }}}2
" s:select_text {{{2

function! s:select_text(range)
    " CCAtrace 'select_text() called, range = '.string(a:range)
    if foldclosed(line('.')) != -1
        norm! zO
    endif

    exec "norm! \<c-\>\<c-n>"
    call cursor(0, a:range[0])
    norm! v
    call cursor(0, a:range[1] + (&sel == 'exclusive'))
    " leave visual mode, you can use "gv" re-select the same region
    " CCAtrace 'select_text() line = '.getline('.')
    exec "norm! \<esc>"
endfunction

" }}}2
" s:delete_text {{{2
" this funciotn can use in :call and in <c-r>= mode.
" if has second argument and it's nonzero, delete the text at the position of
" cursor. e.g: delete the "xxx" in "abcxxx" when the cursor is on the "x"
" (when len == 3). else, delete the text just before the cursor. e.g: delete
" the "abc" in "abcxxx" when the cursor is on the "x".

function! s:delete_text(len, ...)
    " CCAtrace 'delete_text: '.getline('.')
    let c = col('.')

    if a:0 != 0 && a:1 != 0
        exec "norm! ".a:len.'xa'
        call cursor(0, c)
    else
        exec "norm! ".a:len.'h'.a:len.'xa'
        " fix when the cursor is at the last of line
        call cursor(0, c - a:len)
    endif

    " CCAtrace 'delete_text: '.getline('.')
    return ''
endfunction

" }}}2
" s:process_call {{{2

function! s:process_call(mlist)
    " CCAtrace 'process_call() called, mlist = '.string(a:mlist)
    if !empty(a:mlist)
        let wlen = strlen(a:mlist[1])
        for func in ['s:template_complete', 's:snippet_complete']
            let text = call(func, [a:mlist[2]])
            if text != ''
                let b:cca.status.col -= wlen
                let b:cca.status.jump = 1

                call s:delete_text(wlen)
                let s:text = text
                return 1
            endif
        endfor
    endif
endfunction

" }}}2
" s:process_signature {{{2

function! s:process_signature(sig)
    let res = b:cca.tag.start
    let level = 0
    for ch in split(substitute(a:sig[1:-2],'\s*,\s*',',','g'), '\zs')
        if ch == ','
            if level != 0
                let res .= ', '
            else
                let res .= b:cca.tag.end.', '.b:cca.tag.start
            endif
        else
            let res .= ch
            let level += (ch == '(' ? 1 : (ch == ')' ? -1 : 0 ))
        endif
    endfor
    return res.b:cca.tag.end.')'
endfunction

" }}}2

" }}}1
" ==========================================================
" History: {{{1
"
" 2009-02-17 15:38:41   change the format of DefineSnippet command
"                       improve the complete function, make it more clever
" 2009-02-14 22:35:33   fix the submit error. now submit key can be work fine
"                       make select more effective.
"                       add s:strtrim function, for delete the space before
"                       and after the text. this is a little boxing.
"                       fix the bug when the next tag is in a fold, the whole
"                       fold will be delete (oh, this is a big bug...)
"
" 2009-02-04 12:19:48   fix the error of the priority of complete trigger find
"                       fix the autocmd to BufEnter.
"                       optimize the refresh_snippets()
"
" }}}1
" Restore cpo {{{1

let &cpo = old_cpo

" }}}1
" vim: ft=vim:ff=unix:fdm=marker:ts=4:sw=4:et:sta:nu
