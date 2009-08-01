" viki.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim-viki)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-03-25.
" @Last Change: 2009-02-15.
" @Revision:    0.521

if &cp || exists("loaded_viki_auto") "{{{2
    finish
endif
let loaded_viki_auto = 1

""" General {{{1

" Outdated way to keep cursor information
function! s:ResetSavedCursorPosition() "{{{3
    let s:cursorSet  = -1
    let s:cursorCol  = -1
    let s:cursorVCol = -1
    let s:cursorLine = -1
    let s:cursorWinTLine = -1
    let s:cursorEol  = 0
    let s:lazyredraw = &lazyredraw
endf

call s:ResetSavedCursorPosition()

" Outdated: a cheap implementation of printf
function! s:sprintf1(string, arg) "{{{3
    if exists('printf')
        return printf(string, a:arg)
    else
        let rv = substitute(a:string, '\C[^%]\zs%s', escape(a:arg, '"\'), 'g')
        let rv = substitute(rv, '%%', '%', 'g')
        return rv
    end
endf

let s:InterVikiRx = '^\(['. g:vikiUpperCharacters .']\+\)::\(.*\)$'
let s:InterVikis  = []

" Define an interviki name
" viki#Define(name, prefix, ?suffix="*", ?index="Index.${suffix}")
" suffix == "*" -> g:vikiNameSuffix
function! viki#Define(name, prefix, ...) "{{{3
    if a:name =~ '[^A-Z]'
        throw 'Invalid interviki name: '. a:name
    endif
    call add(s:InterVikis, a:name .'::')
    call sort(s:InterVikis)
    let g:vikiInter{a:name}          = a:prefix
    let g:vikiInter{a:name}_suffix   = a:0 >= 1 && a:1 != '*' ? a:1 : g:vikiNameSuffix
    let index = a:0 >= 2 && a:2 != '' ? a:2 : g:vikiIndex
    let findex = fnamemodify(g:vikiInter{a:name} .'/'. index . g:vikiInter{a:name}_suffix, ':p')
    if filereadable(findex)
        let vname = viki#MakeName(a:name, index, 0)
        let g:vikiInter{a:name}_index = index
    else
        " let vname = '[['. a:name .'::]]'
        let vname = a:name .'::'
    end
    " let vname = escape(vname, ' \%#')
    " exec 'command! -bang -nargs=? -complete=customlist,viki#EditComplete '. a:name .' call viki#Edit(escape(empty(<q-args>) ?'. string(vname) .' : <q-args>, "#"), "<bang>")'
    if !exists(':'+ a:name)
        exec 'command -bang -nargs=? -complete=customlist,viki#EditComplete '. a:name .' call viki#Edit(empty(<q-args>) ? '. string(vname) .' : viki#InterEditArg('. string(a:name) .', <q-args>), "<bang>")'
    else
        echom "Viki: Command already exists. Cannot define a command for "+ a:name
    endif
    if g:vikiMenuPrefix != ''
        if g:vikiMenuLevel > 0
            let name = [ a:name[0 : g:vikiMenuLevel - 1] .'&'. a:name[g:vikiMenuLevel : -1] ]
            let weight = []
            for i in reverse(range(g:vikiMenuLevel))
                call insert(name, a:name[i])
                call insert(weight, char2nr(a:name[i]) + 500)
            endfor
            let ml = len(split(g:vikiMenuPrefix, '[^\\]\zs\.'))
            let mw = repeat('500.', ml) . join(weight, '.')
        else
            let name = [a:name]
            let mw = ''
        endif
        exec 'amenu '. mw .' '. g:vikiMenuPrefix . join(name, '.') .' :VikiEdit! '. vname .'<cr>'
    endif
endf

for [s:iname, s:idef] in items(g:viki_intervikis)
    " viki#Define(name, prefix, ?suffix="*", ?index="Index.${suffix}")
    if type(s:idef) == 1
        call call('viki#Define', [s:iname, s:idef])
    else
        call call('viki#Define', [s:iname] + s:idef)
    endif
    unlet! s:iname s:idef
endfor

function! s:AddToRegexp(regexp, pattern) "{{{3
    if a:pattern == ''
        return a:regexp
    elseif a:regexp == ''
        return a:pattern
    else
        return a:regexp .'\|'. a:pattern
    endif
endf

" Make all filenames use slashes
function! viki#CanonicFilename(fname) "{{{3
    return substitute(simplify(a:fname), '[\/]\+', '/', 'g')
endf

" Build the rx to find viki names
function! viki#FindRx() "{{{3
    let rx = s:AddToRegexp('', b:vikiSimpleNameSimpleRx)
    let rx = s:AddToRegexp(rx, b:vikiExtendedNameSimpleRx)
    let rx = s:AddToRegexp(rx, b:vikiUrlSimpleRx)
    return rx
endf

" Wrap edit commands. Every action that creates a new buffer should use 
" this function.
function! s:EditWrapper(cmd, fname) "{{{3
    " TLogVAR a:cmd, a:fname
    let fname = escape(simplify(a:fname), ' %#')
    " let fname = escape(simplify(a:fname), '%#')
    if a:cmd =~ g:vikiNoWrapper
        " TLogDBG a:cmd .' '. fname
        " echom 'No wrapper: '. a:cmd .' '. fname
        exec a:cmd .' '. fname
    else
        try
            if g:vikiHide == 'hide'
                " TLogDBG 'hide '. a:cmd .' '. fname
                exec 'hide '. a:cmd .' '. fname
            elseif g:vikiHide == 'update'
                update
                " TLogDBG a:cmd .' '. fname
                exec a:cmd .' '. fname
            else
                " TLogDBG a:cmd .' '. fname
                exec a:cmd .' '. fname
            endif
        catch /^Vim\%((\a\+)\)\=:E37/
            echoerr "Vim raised E37: You tried to abondon a dirty buffer (see :h E37)"
            echoerr "Viki: You may want to reconsider your g:vikiHide or 'hidden' settings"
        catch /^Vim\%((\a\+)\)\=:E325/
        " catch
        "     echohl error
        "     echom v:errmsg
        "     echohl NONE
        endtry
    endif
endf

" Find the previous heading
function! viki#FindPrevHeading()
    let vikisr=@/
    let cl = getline('.')
    if cl =~ '^\*'
        let head = matchstr(cl, '^\*\+')
        let head = '*\{1,'. len(head) .'}'
    else
        let head = '*\+'
    endif
    call search('\V\^'. head .'\s', 'bW')
    let @/=vikisr
endf

" Find the next heading
function! viki#FindNextHeading()
    let pos = getpos('.')
    " TLogVAR pos
    let cl  = getline('.')
    " TLogDBG 'line0='. cl
    if cl =~ '^\*'
        let head = matchstr(cl, '^\*\+')
        let head = '*\{1,'. len(head) .'}'
    else
        let head = '*\+'
    endif
    " TLogDBG 'head='. head
    " TLogVAR pos
    call setpos('.', pos)
    let vikisr = @/
    call search('\V\^'. head .'\s', 'W')
    let @/=vikisr
endf

" Test whether we want to markup a certain viki name type for the current 
" buffer
" viki#IsSupportedType(type, ?types=b:vikiNameTypes)
function! viki#IsSupportedType(type, ...) "{{{3
    if a:0 >= 1
        let types = a:1
    elseif exists('b:vikiNameTypes')
        let types = b:vikiNameTypes
    else
        let types = g:vikiNameTypes
    end
    if types == ''
        return 1
    else
        " return stridx(b:vikiNameTypes, a:type) >= 0
        return types =~# '['. a:type .']'
    endif
endf

" Build an rx from a list of names
function! viki#RxFromCollection(coll) "{{{3
    " TAssert IsList(a:coll)
    let rx = join(a:coll, '\|')
    if rx == ''
        return ''
    else
        return '\V\('. rx .'\)'
    endif
endf

" Mark inexistent viki names
" VikiMarkInexistent(line1, line2, ?maxcol, ?quick)
" maxcol ... check only up to maxcol
" quick  ... check only if the cursor is located after a link
function! s:MarkInexistent(line1, line2, ...) "{{{3
    if !exists('b:vikiMarkInexistent') || !b:vikiMarkInexistent
        return
    endif
    if s:cursorCol == -1
        " let cursorRestore = 1
        let li0 = line('.')
        let co0 = col('.')
        let co1 = co0 - 1
    else
        " let cursorRestore = 0
        let li0 = s:cursorLine
        let co0 = s:cursorCol
        let co1 = co0 - 2
    end
    if a:0 >= 2 && a:2 > 0 && synIDattr(synID(li0, co1, 1), 'name') !~ '^viki.*Link$'
        return
    endif

    let lazyredraw = &lazyredraw
    set lazyredraw

    let maxcol = a:0 >= 1 ? (a:1 == -1 ? 9999999 : a:1) : 9999999

    if a:line1 > 0
        keepjumps call cursor(a:line1, 1)
        let min = a:line1
    else
        go
        let min = 1
    endif
    let max = a:line2 > 0 ? a:line2 : line('$')

    if line('.') == 1 && line('$') == max
        let b:vikiNamesNull = []
        let b:vikiNamesOk   = []
    else
        if !exists('b:vikiNamesNull') | let b:vikiNamesNull = [] | endif
        if !exists('b:vikiNamesOk')   | let b:vikiNamesOk   = [] | endif
    endif
    let b:vikiNamesNull0 = copy(b:vikiNamesNull)
    let b:vikiNamesOk0   = copy(b:vikiNamesOk)

    let feedback = (max - min) > b:vikiFeedbackMin
    let b:vikiMarkingInexistent = 1
    try
        if feedback
            call tlib#progressbar#Init(line('$'), 'Viki: Mark inexistent %s', 20)
        endif

        " if line('.') == 1
        "     keepjumps norm! G$
        " else
        "     keepjumps norm! k$
        " endif

        let rx = viki#FindRx()
        let pp = 0
        let ll = 0
        let cc = 0
        keepjumps let li = search(rx, 'Wc', max)
        let co = col('.')
        while li != 0 && !(ll == li && cc == co) && li >= min && li <= max && co <= maxcol
            let lic = line('.')
            if synIDattr(synID(lic, col('.'), 1), "name") !~ '^vikiFiles'
                if feedback
                    call tlib#progressbar#Display(lic)
                endif
                let ll  = li
                let co1 = co - 1
                " TLogVAR co1
                let def = viki#GetLink(1, getline('.'), co1)
                " TAssert IsList(def)
                " TLogDBG getline('.')[co1 : -1]
                " TLogVAR def
                if empty(def)
                    echom 'Internal error: VikiMarkInexistent: '. co .' '. getline('.')
                else
                    exec viki#SplitDef(def)
                    " TLogVAR v_part
                    if v_part =~ '^'. b:vikiSimpleNameSimpleRx .'$'
                        if v_dest =~ g:vikiSpecialProtocols
                            " TLogDBG "v_dest =~ g:vikiSpecialProtocols => 0"
                            let check = 0
                        elseif v:version >= 700 && viki#IsHyperWord(v_part)
                            " TLogDBG "viki#IsHyperWord(v_part) => 0"
                            let check = 0
                        elseif v_name == g:vikiSelfRef
                            " TLogDBG "simple self ref"
                            let check = 0
                        else
                            " TLogDBG "else1 => 1"
                            let check = 1
                            let partx = escape(v_part, "'\"\\/")
                            if partx !~ '^\['
                                let partx = '\<'.partx
                            endif
                            if partx !~ '\]$'
                                let partx = partx.'\>'
                            endif
                        endif
                    elseif v_dest =~ '^'. b:vikiUrlSimpleRx .'$'
                        " TLogDBG "v_dest =~ '^'. b:vikiUrlSimpleRx .'$' => 0"
                        let check = 0
                        let partx = escape(v_part, "'\"\\/")
                        call filter(b:vikiNamesNull, 'v:val != partx')
                        if index(b:vikiNamesOk, partx) == -1
                            call insert(b:vikiNamesOk, partx)
                        endif
                    elseif v_part =~ b:vikiExtendedNameSimpleRx
                        if v_dest =~ '^'. g:vikiSpecialProtocols .':'
                            " TLogDBG "v_dest =~ '^'. g:vikiSpecialProtocols .':' => 0"
                            let check = 0
                        else
                            " TLogDBG "else2 => 1"
                            let check = 1
                            let partx = escape(v_part, "'\"\\/")
                        endif
                        " elseif v_part =~ b:vikiCmdSimpleRx
                        " <+TODO+>
                    else
                        " TLogDBG "else3 => 0"
                        let check = 0
                    endif
                    " TLogVAR check, v_dest
                    " if check && v_dest != "" && v_dest != g:vikiSelfRef && !isdirectory(v_dest)
                    if check && v_dest != g:vikiSelfRef && !isdirectory(v_dest)
                        if filereadable(v_dest)
                            call filter(b:vikiNamesNull, 'v:val != partx')
                            if index(b:vikiNamesOk, partx) == -1
                                call insert(b:vikiNamesOk, partx)
                            endif
                        else
                            if index(b:vikiNamesNull, partx) == -1
                                call insert(b:vikiNamesNull, partx)
                            endif
                            call filter(b:vikiNamesOk, 'v:val != partx')
                        endif
                        " TLogVAR partx, b:vikiNamesNull, b:vikiNamesOk
                    endif
                endif
                unlet! def
            endif
            keepjumps let li = search(rx, 'W', max)
            let co = col('.')
        endwh
        if b:vikiNamesOk0 != b:vikiNamesOk || b:vikiNamesNull0 != b:vikiNamesNull
            call viki#HighlightInexistent()
            if tlib#var#Get('vikiCacheInexistent', 'wbg')
                call viki#SaveCache()
            endif
        endif
        let b:vikiCheckInexistent = 0
    finally
        " if cursorRestore && !s:cursorSet
        "     call viki#RestoreCursorPosition(li0, co0)
        " endif
        if feedback
            call tlib#progressbar#Restore()
        endif
        let &lazyredraw = lazyredraw
        unlet! b:vikiMarkingInexistent
    endtry
endf

" Actually highlight inexistent file names
function! viki#HighlightInexistent() "{{{3
    if b:vikiMarkInexistent == 1
        if exists('b:vikiNamesNull')
            exe 'syntax clear '. b:vikiInexistentHighlight
            let rx = viki#RxFromCollection(b:vikiNamesNull)
            if rx != ''
                exe 'syntax match '. b:vikiInexistentHighlight .' /'. rx .'/'
            endif
        endif
    elseif b:vikiMarkInexistent == 2
        if exists('b:vikiNamesOk')
            syntax clear vikiOkLink
            syntax clear vikiExtendedOkLink
            let rx = viki#RxFromCollection(b:vikiNamesOk)
            if rx != ''
                exe 'syntax match vikiOkLink /'. rx .'/'
            endif
        endif
    endif
endf

" Check a text element for inexistent names
if v:version == 700 && !has('patch8')
    function! s:SID()
        let fullname = expand("<sfile>")
        return matchstr(fullname, '<SNR>\d\+_')
    endf

    function! viki#MarkInexistentInElement(elt) "{{{3
        let lr = &lazyredraw
        set lazyredraw
        call viki#SaveCursorPosition()
        let kpk = s:SID() . "MarkInexistentIn" . a:elt
        call {kpk}()
        call viki#RestoreCursorPosition()
        call s:ResetSavedCursorPosition()
        let &lazyredraw = lr
        return ''
    endf
else
    function! viki#MarkInexistentInElement(elt) "{{{3
        let lr = &lazyredraw
        set lazyredraw
        " let pos = getpos('.')
        " TLogVAR pos
        try
            call viki#SaveCursorPosition()
            call s:MarkInexistentIn{a:elt}()
            call viki#RestoreCursorPosition()
            call s:ResetSavedCursorPosition()
            return ''
        finally
            " TLogVAR pos
            " call setpos('.', pos)
            let &lazyredraw = lr
        endtry
    endf
endif

function! viki#MarkInexistentInRange(line1, line2) "{{{3
    let lr = &lazyredraw
    set lazyredraw
    " let pos = getpos('.')
    " TLogVAR pos
    try
        call viki#SaveCursorPosition()
        call s:MarkInexistent(a:line1, a:line2)
        call viki#RestoreCursorPosition()
        call s:ResetSavedCursorPosition()
        " call s:MarkInexistent(a:line1, a:line2)
    finally
        " TLogVAR pos
        " call setpos('.', pos)
        let &lazyredraw = lr
    endtry
endf

function! s:MarkInexistentInParagraph() "{{{3
    if getline('.') =~ '\S'
        call s:MarkInexistent(line("'{"), line("'}"))
    endif
endf

function! s:MarkInexistentInDocument() "{{{3
    call s:MarkInexistent(1, line("$"))
endf

function! s:MarkInexistentInParagraphVisible() "{{{3
    let l0 = max([line("'{"), line("w0")])
    " let l1 = line("'}")
    let l1 = line(".")
    call s:MarkInexistent(l0, l1)
endf

function! s:MarkInexistentInParagraphQuick() "{{{3
    let l0 = line("'{")
    let l1 = line("'}")
    call s:MarkInexistent(l0, l1, -1, 1)
endf

function! s:MarkInexistentInLine() "{{{3
    call s:MarkInexistent(line("."), line("."))
endf

function! s:MarkInexistentInLineQuick() "{{{3
    call s:MarkInexistent(line("."), line("."), (col('.') + 1), 1)
endf

" Set values for the cache
function! s:CValsSet(cvals, var) "{{{3
    if exists('b:'. a:var)
        let a:cvals[a:var] = b:{a:var}
    endif
endf

" First-time markup of inexistent names. Handles cached values. Called 
" from syntax/viki.vim
function! viki#MarkInexistentInitial() "{{{3
    " let save_inexistent = 0
    if tlib#var#Get('vikiCacheInexistent', 'wbg')
        let cfile = tlib#cache#Filename('viki_inexistent', '', 1)
        " TLogVAR cfile
        if getftime(cfile) < getftime(expand('%:p'))
            " let cfile = ''
            " let save_inexistent = 1
        elseif !empty(cfile)
        " if !empty(cfile)
            let cvals = tlib#cache#Get(cfile)
            " TLogVAR cvals
            if !empty(cvals)
                for [key, value] in items(cvals)
                    let b:{key} = value
                    unlet value
                endfor
                call viki#HighlightInexistent()
                return
            endif
        endif
    else
        let cfile = ''
    endif
    call viki#MarkInexistentInElement('Document')
    " if save_inexistent
    "     call viki#SaveCache(cfile)
    " endif
endf

function! viki#SaveCache(...) "{{{3
    if tlib#var#Get('vikiCacheInexistent', 'wbg')
        let cfile = a:0 >= 1 ? a:1 : tlib#cache#Filename('viki_inexistent', '', 1)
        if !empty(cfile)
            " TLogVAR cfile
            let cvals = {}
            call s:CValsSet(cvals, 'vikiNamesNull')
            call s:CValsSet(cvals, 'vikiNamesOk')
            call s:CValsSet(cvals, 'vikiInexistentHighlight')
            call s:CValsSet(cvals, 'vikiMarkInexistent')
            call tlib#cache#Save(cfile, cvals)
        endif
    endif
endf

" The function called from autocommands: re-check for inexistent names 
" when re-entering a buffer.
function! viki#CheckInexistent() "{{{3
    if g:vikiEnabled && exists("b:vikiCheckInexistent") && b:vikiCheckInexistent > 0
        call viki#MarkInexistentInRange(b:vikiCheckInexistent, b:vikiCheckInexistent)
    endif
endf

" Initialize buffer-local variables on the basis of other variables "..." 
" or from a global variable.
function! viki#SetBufferVar(name, ...) "{{{3
    if !exists('b:'.a:name)
        if a:0 > 0
            let i = 1
            while i <= a:0
                exe 'let altVar = a:'. i
                if altVar[0] == '*'
                    exe 'let b:'.a:name.' = '. strpart(altVar, 1)
                    return
                elseif exists(altVar)
                    exe 'let b:'.a:name.' = '. altVar
                    return
                endif
                let i = i + 1
            endwh
            throw 'VikiSetBuffer: Couldn't set '. a:name
        else
            exe 'let b:'.a:name.' = g:'.a:name
        endif
    endif
endf

" Get some vimscript code to set a variable from either a buffer-local or 
" a global variable
function! s:LetVar(name, var) "{{{3
    if exists('b:'.a:var)
        return 'let '.a:name.' = b:'.a:var
    elseif exists('g:'.a:var)
        return 'let '.a:name.' = g:'.a:var
    else
        return ''
    endif
endf

" Call a fn.family if existent, call fn otherwise.
" viki#DispatchOnFamily(fn, ?family='', *args)
function! viki#DispatchOnFamily(fn, ...) "{{{3
    let fam = a:0 >= 1 && a:1 != '' ? a:1 : viki#Family()
    if !exists('g:loaded_viki_'. fam)
        exec 'runtime autoload/viki_'. fam .'.vim'
    endif
    if fam == '' || !exists('*viki_'.fam.'#'.a:fn)
        let cmd = 'viki'
    else
        let cmd = fam
    endif
    let cmd .= '#'. a:fn
    if a:0 >= 2
        let args = join(map(range(2, a:0), 'string(a:{v:val})'), ', ')
    else
        let args = ''
    endif
    " TLogDBG args
    " TLogDBG cmd .'('. args .')'
    exe 'return viki_'. cmd .'('. args .')'
endf

function! viki#IsHyperWord(word) "{{{3
    if !exists('b:vikiHyperWordTable')
        return 0
    endif
    return has_key(b:vikiHyperWordTable, s:CanonicHyperWord(a:word))
endf

function! viki#HyperWordValue(word) "{{{3
    return b:vikiHyperWordTable[s:CanonicHyperWord(a:word)]
endf

function! s:CanonicHyperWord(word) "{{{3
    " return substitute(a:word, '\s\+', '\\s\\+', 'g')
    return substitute(a:word, '\s\+', ' ', 'g')
endf

function! viki#CollectFileWords(table, simpleWikiName) "{{{3
    let patterns = []
    if exists('b:vikiNameSuffix')
        call add(patterns, b:vikiNameSuffix)
    endif
    if g:vikiNameSuffix != '' && index(patterns, g:vikiNameSuffix) == -1
        call add(patterns, g:vikiNameSuffix)
    end
    let suffix = '.'. expand('%:e')
    if suffix != '.' && index(patterns, suffix) == -1
        call add(patterns, suffix)
    end
    for p in patterns
        let files = glob(expand('%:p:h').'/*'. p)
        if files != ''
            let files_l = split(files, '\n')
            call filter(files_l, '!isdirectory(v:val) && v:val != expand("%:p")')
            if !empty(files_l)
                for w in files_l
                    let ww = s:CanonicHyperWord(fnamemodify(w, ":t:r"))
                    if !has_key(a:table, ww) && 
                                \ (a:simpleWikiName == '' || ww !~# a:simpleWikiName)
                        let a:table[ww] = w
                    endif
                endfor
            endif
        endif
    endfor
endf


function! viki#CollectHyperWords(table) "{{{3
    let vikiWordsBaseDir = expand('%:p:h')
    for filename in g:vikiHyperWordsFiles
        if filename =~ '^\./'
            let bn  = fnamemodify(filename, ':t')
            let filename = vikiWordsBaseDir . filename[1:-1]
            let acc = []
            for dir in tlib#file#Split(vikiWordsBaseDir)
                call add(acc, dir)
                let fn = tlib#file#Join(add(copy(acc), bn))
                call s:CollectVikiWords(a:table, fn, vikiWordsBaseDir)
            endfor
        else
            call s:CollectVikiWords(a:table, filename, vikiWordsBaseDir)
        endif
    endfor
endf


function! s:CollectVikiWords(table, filename, basedir) "{{{3
    " TLogVAR a:filename, a:basedir
    if filereadable(a:filename)
        let dir = fnamemodify(a:filename, ':p:h')
        " TLogVAR dir
        call tlib#dir#Push(dir, 1)
        try
            let hyperWords = readfile(a:filename)
            for wl in hyperWords
                if wl =~ '^\s*%'
                    continue
                endif
                let ml = matchlist(wl, '^\(.\{-}\) *\t\+ *\(.\+\)$')
                " let ml = matchlist(wl, '^\(\S\+\) *\t\+ *\(.\+\)$')
                " let ml = matchlist(wl, '^\(\S\+\)[[:space:]]\+\(.\+\)$')
                if !empty(ml)
                    let mkey = s:CanonicHyperWord(ml[1])
                    let mval = ml[2]
                    if mval == '-'
                        if has_key(a:table, mkey)
                            call remove(a:table, mkey)
                        endif
                    elseif !has_key(a:table, mkey)
                        " TLogVAR mval
                        " call TLogDBG(viki#IsInterViki(mval))
                        if viki#IsInterViki(mval)
                            let interviki = viki#InterVikiName(mval)
                            let suffix    = viki#InterVikiSuffix(mval, interviki)
                            let name      = viki#InterVikiPart(mval)
                            " TLogVAR mkey, interviki, suffix, name
                            let a:table[mkey] = {
                                        \ 'interviki': interviki,
                                        \ 'suffix':    suffix,
                                        \ 'name':      name,
                                        \ }
                        else
                            let a:table[mkey] = tlib#file#Relative(mval, a:basedir)
                            " TLogVAR mkey, mval, a:basedir, a:table[mkey]
                        endif
                    endif
                endif
            endfor
        finally
            call tlib#dir#Pop()
        endtry
    endif
endf

" Get a rx that matches a simple name
function! viki#GetSimpleRx4SimpleWikiName() "{{{3
    let upper = s:UpperCharacters()
    let lower = s:LowerCharacters()
    let simpleWikiName = '\<['.upper.']['.lower.']\+\(['.upper.']['.lower.'0-9]\+\)\+\>'
    " This will mistakenly highlight words like LaTeX
    " let simpleWikiName = '\<['.upper.']['.lower.']\+\(['.upper.']['.lower.'0-9]\+\)\+'
    return simpleWikiName
endf

" Return a viki name for a vikiname on a specified interviki
" viki#MakeName(iviki, name, ?quote=1)
function! viki#MakeName(iviki, name, ...) "{{{3
    let quote = a:0 >= 1 ? a:1 : 1
    let name  = a:name
    if quote && name !~ '\C'. viki#GetSimpleRx4SimpleWikiName()
        let name = '[-'. name .'-]'
    endif
    if a:iviki != ''
        let name = a:iviki .'::'. name
    endif
    return name
endf

" Return a string defining upper-case characters
function! s:UpperCharacters() "{{{3
    return exists('b:vikiUpperCharacters') ? b:vikiUpperCharacters : g:vikiUpperCharacters
endf

" Return a string defining lower-case characters
function! s:LowerCharacters() "{{{3
    return exists('b:vikiLowerCharacters') ? b:vikiLowerCharacters : g:vikiLowerCharacters
endf

" Remove backslashes from string
function! s:StripBackslash(string) "{{{3
    return substitute(a:string, '\\\(.\)', '\1', 'g')
endf

" Map a key that triggers checking for inexistent names
function! viki#MapMarkInexistent(key, element) "{{{3
    if a:key == "\n"
        let key = '<cr>'
    elseif a:key == ' '
        let key = '<space>'
    else
        let key = a:key
    endif
    let arg = maparg(key, 'i')
    if arg == ''
        let arg = key
    endif
    let map = '<c-r>=viki#MarkInexistentInElement("'. a:element .'")<cr>'
    let map = stridx(g:vikiMapBeforeKeys, a:key) != -1 ? arg.map : map.arg
    exe 'inoremap <silent> <buffer> '. key .' '. map
endf


" In case this function gets called repeatedly for the same position, check only once.
let s:hookcursormoved_oldpos = []
function! viki#HookCheckPreviousPosition(mode) "{{{3
    " if a:mode == 'n'
    if s:hookcursormoved_oldpos != b:hookcursormoved_oldpos
        keepjumps keepmarks call s:MarkInexistent(b:hookcursormoved_oldpos[1], b:hookcursormoved_oldpos[1])
        let s:hookcursormoved_oldpos = b:hookcursormoved_oldpos
    endif
endf


" Restore the cursor position
" TODO: adapt for vim7
" viki#RestoreCursorPosition(?line, ?VCol, ?EOL, ?Winline)
function! viki#RestoreCursorPosition(...) "{{{3
    " let li  = a:0 >= 1 && a:1 != '' ? a:1 : s:cursorLine
    " " let co  = a:0 >= 2 && a:2 != '' ? a:2 : s:cursorVCol
    " let co  = a:0 >= 2 && a:2 != '' ? a:2 : s:cursorCol
    " " let eol = a:0 >= 3 && a:3 != '' ? a:3 : s:cursorEol
    " let wli = a:0 >= 4 && a:4 != '' ? a:4 : s:cursorWinTLine
    let li  = s:cursorLine
    let co  = s:cursorCol
    let wli = s:cursorWinTLine
    if li >= 0
        let ve = &virtualedit
        set virtualedit=all
        if wli > 0
            exe 'keepjumps norm! '. wli .'zt'
        endif
        " TLogVAR li, co
        call cursor(li, co)
        let &virtualedit = ve
    endif
endf

" Save the cursor position
" TODO: adapt for vim7
function! viki#SaveCursorPosition() "{{{3
    let ve = &virtualedit
    set virtualedit=all
    " let s:lazyredraw   = &lazyredraw
    " set nolazyredraw
    let s:cursorSet     = 1
    let s:cursorCol     = col('.')
    let s:cursorEol     = (col('.') == col('$'))
    let s:cursorVCol    = virtcol('.')
    if s:cursorEol
        let s:cursorVCol = s:cursorVCol + 1
    endif
    let s:cursorLine    = line('.')
    keepjumps norm! H
    let s:cursorWinTLine = line('.')
    call cursor(s:cursorLine, s:cursorCol)
    let &virtualedit    = ve
    " call viki#DebugCursorPosition()
    return ''
endf

" Display a debug message
function! viki#DebugCursorPosition(...) "{{{3
    let msg = 'DBG '
    if a:0 >= 1 && a:1 != ''
        let msg = msg . a:1 .' '
    endif
    let msg = msg . "s:cursorCol=". s:cursorCol
                \ ." s:cursorEol=". s:cursorEol
                \ ." ($=". col('$') .')'
                \ ." s:cursorVCol=". s:cursorVCol
                \ ." s:cursorLine=". s:cursorLine
                \ ." s:cursorWinTLine=". s:cursorWinTLine
    if a:0 >= 2 && a:2
        echo msg
    else
        echom msg
    endif
endf

" Check if the key maps should support a specified functionality
function! viki#MapFunctionality(mf, key)
    return a:mf == 'ALL' || (a:mf =~# '\<'. a:key .'\>')
endf

" Re-set minor mode if the buffer is already in viki minor mode.
function! viki#MinorModeReset() "{{{3
    if exists("b:vikiEnabled") && b:vikiEnabled == 1
        call viki#DispatchOnFamily('MinorMode', '', 1)
    endif
endf

" Check whether line is within a region syntax
function! viki#IsInRegion(line) "{{{3
    let i   = 0
    let max = col('$')
    while i < max
        if synIDattr(synID(a:line, i, 1), "name") == "vikiRegion"
            return 1
        endif
        let i = i + 1
    endw
    return 0
endf

" Set back references for use with viki#GoBack()
function! s:SetBackRef(file, li, co) "{{{3
    let br = s:GetBackRef()
    call filter(br, 'v:val[0] != a:file')
    call insert(br, [a:file, a:li, a:co])
endf

" Retrieve a certain back reference
function! s:SelectThisBackRef(n) "{{{3
    return 'let [vbf, vbl, vbc] = s:GetBackRef()['. a:n .']'
endf

" Select a back reference
function! s:SelectBackRef(...) "{{{3
    if a:0 >= 1 && a:1 >= 0
        let s = a:1
    else
        let br  = s:GetBackRef()
        let br0 = map(copy(br), 'v:val[0]')
        let st  = tlib#input#List('s', 'Select Back Reference', br0)
        if st != ''
            let s = index(br0, st)
        else
            let s = -1
        endif
    endif
    if s >= 0
        return s:SelectThisBackRef(s)
    endif
    return ''
endf

" Retrieve information for back references
function! s:GetBackRef()
    if g:vikiSaveHistory
        let id = expand('%:p')
        if empty(id)
            return []
        else
            if !has_key(g:VIKIBACKREFS, id)
                let g:VIKIBACKREFS[id] = []
            endif
            return g:VIKIBACKREFS[id]
        endif
    else
        if !exists('b:VIKIBACKREFS')
            let b:VIKIBACKREFS = []
        endif
        return b:VIKIBACKREFS
    endif
endf

" Jump to the parent buffer (or go back in history)
function! viki#GoParent() "{{{3
    if exists('b:vikiParent')
        call viki#Edit(b:vikiParent)
    else
        call viki#GoBack()
    endif
endf

" Go back in history
function! viki#GoBack(...) "{{{3
    let s  = (a:0 >= 1) ? a:1 : -1
    let br = s:SelectBackRef(s)
    if br == ''
        echomsg "Viki: No back reference defined? (". s ."/". br .")"
    else
        exe br
        let buf = bufnr("^". vbf ."$")
        if buf >= 0
            call s:EditWrapper('buffer', buf)
        else
            call s:EditWrapper('edit', vbf)
        endif
        if vbf == expand("%:p")
            call cursor(vbl, vbc)
        else
            throw "Viki: Couldn't open file: ". vbf
        endif
    endif
endf

" Expand template strings as in
" "foo %{FILE} bar", 'FILE', 'file.txt' => "foo file.txt bar"
function! viki#SubstituteArgs(str, ...) "{{{3
    let i  = 1
    " let rv = escape(a:str, '\')
    let rv = a:str
    let default = ''
    let done = 0
    while a:0 >= i
        exec "let lab = a:". i
        exec "let val = a:". (i+1)
        if lab == ''
            let default = val
        else
            let rv0 = substitute(rv, '\C\(^\|[^%]\)\zs%{'. lab .'}', escape(val, '\~&'), 'g')
            if rv != rv0
                let done = 1
                let rv = rv0
            endif
        endif
        let i = i + 2
    endwh
    if !done
        let rv .= ' '. default
    end
    let rv = substitute(rv, '%%', "%", "g")
    return rv
endf

" Handle special anchors in extented viki names
" Example: [[index#l=10]]
if !exists('*VikiAnchor_l') "{{{2
    function! VikiAnchor_l(arg) "{{{3
        if a:arg =~ '^\d\+$'
            exec a:arg
        endif
    endf
endif

" Example: [[index#line=10]]
if !exists('*VikiAnchor_line') "{{{2
    function! VikiAnchor_line(arg) "{{{3
        call VikiAnchor_l(a:arg)
    endf
endif

" Example: [[index#rx=foo]]
if !exists('*VikiAnchor_rx') "{{{2
    function! VikiAnchor_rx(arg) "{{{3
        let arg = escape(s:StripBackslash(a:arg), '/')
        exec 'keepjumps norm! gg/'. arg .''
    endf
endif

" Example: [[index#vim=/foo]]
if !exists('*VikiAnchor_vim') "{{{2
    function! VikiAnchor_vim(arg) "{{{3
        exec s:StripBackslash(a:arg)
    endf
endif

" Return an rx for searching anchors
function! viki#GetAnchorRx(anchor)
    " TLogVAR a:anchor
    let anchorRx = tlib#var#Get('vikiAnchorMarker', 'wbg') . a:anchor
    if exists('b:vikiEnabled')
        let anchorRx = '\^\s\*\('. b:vikiCommentStart .'\)\?\s\*'. anchorRx
        if exists('b:vikiAnchorRx')
            " !!! b:vikiAnchorRx must be a very nomagic (\V) regexp 
            "     expression
            let varx = viki#SubstituteArgs(b:vikiAnchorRx, 'ANCHOR', a:anchor)
            let anchorRx = '\('.anchorRx.'\|'. varx .'\)'
        endif
    endif
    " TLogVAR anchorRx
    return '\V'. anchorRx
endf

" Set automatic anchor marks: #ma => 'a
function! viki#SetAnchorMarks() "{{{3
    let pos = getpos(".")
    " TLogVAR pos
    let sr  = @/
    let anchorRx = viki#GetAnchorRx('m\zs\[a-zA-Z]\ze\s\*\$')
    " TLogVAR anchorRx
    " exec 'silent keepjumps g /'. anchorRx .'/exec "norm! m". substitute(getline("."), anchorRx, ''\2'', "")'
    exec 'silent keepjumps g /'. anchorRx .'/exec "norm! m". matchstr(getline("."), anchorRx)'
    let @/ = sr
    " TLogVAR pos
    call setpos('.', pos)
endf

" Get the window number where the destination file should be opened
function! viki#GetWinNr(...) "{{{3
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    if type(winNr) == 0 && winNr == 0
        if exists('b:vikiSplit')
            let winNr = b:vikiSplit
        elseif exists('g:vikiSplit')
            let winNr = g:vikiSplit
        else
            let winNr = 0
        endif
    endif
    return winNr
endf

" Set the window where to open a file/display a buffer
function! viki#SetWindow(winNr) "{{{3
    let winNr = viki#GetWinNr(a:winNr)
    " TLogVAR winNr
    if type(winNr) == 1 && winNr == 'tab'
        tabnew
    elseif winNr != 0
        let wm = s:HowManyWindows()
        if winNr == -2
            wincmd v
        elseif wm == 1 || winNr == -1
            wincmd s
        else
            exec winNr ."wincmd w"
        end
    endif
endf

" Open a filename in a certain window and jump to an anchor if any
" viki#OpenLink(filename, anchor, ?create=0, ?postcmd='', ?wincmd=0)
function! viki#OpenLink(filename, anchor, ...) "{{{3
    " TLogVAR a:filename
    let create  = a:0 >= 1 ? a:1 : 0
    let postcmd = a:0 >= 2 ? a:2 : ''
    if a:0 >= 3
        let winNr = a:3
    elseif exists('b:vikiNextWindow')
        let winNr = b:vikiNextWindow
    else
        let winNr = 0
    endif
    " TLogVAR winNr
    
    let li = line('.')
    let co = col('.')
    let fi = expand('%:p')
   
    let filename = fnamemodify(a:filename, ':p')
    if exists('*simplify')
        let filename = simplify(filename)
    endif
    " TLogVAR filename
    let buf = bufnr('^'. filename .'$')
    call viki#SetWindow(winNr)
    if buf >= 0 && bufloaded(buf)
        call s:EditLocalFile('buffer', buf, fi, li, co, a:anchor)
    elseif create && exists('b:createVikiPage')
        call s:EditLocalFile(b:createVikiPage, filename, fi, li, co, g:vikiDefNil)
    elseif exists('b:editVikiPage')
        call s:EditLocalFile(b:editVikiPage, filename, fi, li, co, g:vikiDefNil)
    elseif isdirectory(filename)
        call s:EditLocalFile(g:vikiExplorer, tlib#dir#PlainName(filename), fi, li, co, g:vikiDefNil)
    else
        call s:EditLocalFile('edit', filename, fi, li, co, a:anchor)
    endif
    if postcmd != ''
        exec postcmd
    endif
endf

" Open a local file in vim
function! s:EditLocalFile(cmd, fname, fi, li, co, anchor) "{{{3
    " TLogVAR a:cmd, a:fname
    let vf = viki#Family()
    let cb = bufnr('%')
    call tlib#dir#Ensure(fnamemodify(a:fname, ':p:h'))
    call s:EditWrapper(a:cmd, a:fname)
    if cb != bufnr('%')
        set buflisted
    endif
    if vf != ''
        let b:vikiFamily = vf
    endif
    call s:SetBackRef(a:fi, a:li, a:co)
    if g:vikiPromote && (!exists('b:vikiEnabled') || !b:vikiEnable)
        call viki#DispatchOnFamily('MinorMode', vf, 1)
    endif
    call viki#DispatchOnFamily('FindAnchor', vf, a:anchor)
endf

" Get the current viki family
function! viki#Family(...) "{{{3
    let anyway = a:0 >= 1 ? a:1 : 0
    if (anyway || (exists('b:vikiEnabled') && b:vikiEnabled)) && exists('b:vikiFamily') && !empty(b:vikiFamily)
        return b:vikiFamily
    else
        return g:vikiFamily
    endif
endf

" Return the number of windows
function! s:HowManyWindows() "{{{3
    let i = 1
    while winbufnr(i) > 0
        let i = i + 1
    endwh
    return i - 1
endf

" Decompose an url into filename, anchor, args
function! viki#DecomposeUrl(dest) "{{{3
    let dest = substitute(a:dest, '^\c/*\([a-z]\)|', '\1:', "")
    let rv = ""
    let i  = 0
    while 1
        let in = match(dest, '%\d\d', i)
        if in >= 0
            let c  = "0x".strpart(dest, in + 1, 2)
            let rv = rv. strpart(dest, i, in - i) . nr2char(c)
            let i  = in + 3
        else
            break
        endif
    endwh
    let rv     = rv. strpart(dest, i)
    let uend   = match(rv, '[?#]')
    if uend >= 0
        let args   = matchstr(rv, '?\zs.\+$', uend)
        let anchor = matchstr(rv, '#\zs.\+$', uend)
        let rv     = strpart(rv, 0, uend)
    else
        let args   = ""
        let anchor = ""
        let rv     = rv
    end
    return "let filename='". rv ."'|let anchor='". anchor ."'|let args='". args ."'"
endf

" Get a list of special files' suffixes
function! viki#GetSpecialFilesSuffixes() "{{{3
    " TAssert IsList(g:vikiSpecialFiles)
    if exists("b:vikiSpecialFiles")
        " TAssert IsList(b:vikiSpecialFiles)
        return b:vikiSpecialFiles + g:vikiSpecialFiles
    else
        return g:vikiSpecialFiles
    endif
endf

" Get an rx matching special files' suffixes
function! viki#GetSpecialFilesSuffixesRx(...) "{{{3
    let sfx = a:0 >= 1 ? a:1 : viki#GetSpecialFilesSuffixes()
    return join(sfx, '\|')
endf

" Check if dest is a special file
function! viki#IsSpecialFile(dest) "{{{3
    return (a:dest =~ '\.\('. viki#GetSpecialFilesSuffixesRx() .'\)$' &&
                \ (g:vikiSpecialFilesExceptions == "" ||
                \ !(a:dest =~ g:vikiSpecialFilesExceptions)))
endf

" Check if dest uses a special protocol
function! viki#IsSpecialProtocol(dest) "{{{3
    return a:dest =~ '^\('.b:vikiSpecialProtocols.'\):' &&
                \ (b:vikiSpecialProtocolsExceptions == "" ||
                \ !(a:dest =~ b:vikiSpecialProtocolsExceptions))
endf

" Check if dest is somehow special
function! viki#IsSpecial(dest) "{{{3
    return viki#IsSpecialProtocol(a:dest) || 
                \ viki#IsSpecialFile(a:dest) ||
                \ isdirectory(a:dest)
endf

" Open a viki name/link
function! s:FollowLink(def, ...) "{{{3
    " TLogVAR a:def
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    exec viki#SplitDef(a:def)
    if type(winNr) == 0 && winNr == 0
        " TAssert IsNumber(winNr)
        if exists('v_winnr')
            let winNr = v_winnr
        elseif exists('b:vikiOpenInWindow')
            if b:vikiOpenInWindow =~ '^l\(a\(s\(t\)\?\)\?\)\?'
                let winNr = s:HowManyWindows()
            elseif b:vikiOpenInWindow =~ '^[+-]\?\d\+$'
                if b:vikiOpenInWindow[0] =~ '[+-]'
                    exec 'let winNr = '. bufwinnr("%") . b:vikiOpenInWindow
                else
                    let winNr = b:vikiOpenInWindow
                endif
            endif
        endif
    endif
    let inter = s:GuessInterViki(a:def)
    let bn    = bufnr('%')
    " TLogVAR v_name, v_dest, v_anchor
    if v_name == g:vikiSelfRef || v_dest == g:vikiSelfRef
        call viki#DispatchOnFamily('FindAnchor', '', v_anchor)
    elseif v_dest == g:vikiDefNil
		throw 'No target? '. string(a:def)
    else
        call s:OpenLink(v_dest, v_anchor, winNr)
    endif
    if exists('b:vikiEnabled') && b:vikiEnabled && inter != '' && !exists('b:vikiInter')
        let b:vikiInter = inter
    endif
    return ""
endf

" Actually open a viki name/link
function! s:OpenLink(dest, anchor, winNr)
    let b:vikiNextWindow = a:winNr
    " TLogVAR a:dest, a:anchor, a:winNr
    try
        if viki#IsSpecialProtocol(a:dest)
            let url = viki#MakeUrl(a:dest, a:anchor)
            " TLogVAR url
            call VikiOpenSpecialProtocol(url)
        elseif viki#IsSpecialFile(a:dest)
            call VikiOpenSpecialFile(a:dest)
        elseif isdirectory(a:dest)
            " exec g:vikiExplorer .' '. a:dest
            call viki#OpenLink(a:dest, a:anchor, 0, '', a:winNr)
        elseif filereadable(a:dest) "reference to a local, already existing file
            call viki#OpenLink(a:dest, a:anchor, 0, '', a:winNr)
        elseif bufexists(a:dest) && buflisted(a:dest)
            call s:EditWrapper('buffer!', a:dest)
        else
            let ok = input("File doesn't exists. Create '".a:dest."'? (Y/n) ", "y")
            if ok != "" && ok != "n"
                let b:vikiCheckInexistent = line(".")
                call viki#OpenLink(a:dest, a:anchor, 1, '', a:winNr)
            endif
        endif
    finally
        let b:vikiNextWindow = 0
    endtry
endf

function! viki#MakeUrl(dest, anchor) "{{{3
    if a:anchor == ""
        return a:dest
    else
        " if a:dest[-1:-1] != '/'
        "     let dest = a:dest .'/'
        " else
        "     let dest = a:dest
        " endif
        " return join([dest, a:anchor], '#')
        return join([a:dest, a:anchor], '#')
    endif 
endf

" Guess the interviki name from a viki name definition
function! s:GuessInterViki(def) "{{{3
    exec viki#SplitDef(a:def)
    if v_type == 's'
        let exp = v_name
    elseif v_type == 'e'
        let exp = v_dest
    else
        return ''
    endif
    if viki#IsInterViki(exp)
        return viki#InterVikiName(exp)
    else
        return ''
    endif
endf

" Somewhat pointless legacy function
" TODO: adapt for vim7
function! s:MakeVikiDefPart(txt) "{{{3
    if a:txt == ''
        return g:vikiDefNil
    else
        return a:txt
    endif
endf

" TODO: adapt for vim7
" Return a structure or whatever describing a viki name/link
function! viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type) "{{{3
    let arr = map([a:v_name, a:v_dest, a:v_anchor, a:v_part, a:v_type, 0], 's:MakeVikiDefPart(v:val)')
    " TLogDBG string(arr)
    return arr
endf

" Legacy function: Today we would use dictionaries for this
" TODO: adapt for vim7
" Return vimscript code that defines a set of variables on the basis of a 
" viki name definition
function! viki#SplitDef(def) "{{{3
    " TAssert IsList(a:def)
    " TLogDBG string(a:def)
    if empty(a:def)
        let rv = 'let [v_name, v_dest, v_anchor, v_part, v_type, v_winnr] = ["", "", "", "", "", ""]'
    else
        if a:def[4] == 'e'
            let mod = viki#ExtendedModifier(a:def[3])
            if mod =~# '*'
                let a:def[5] = -1
            endif
        endif
        let rv = 'let [v_name, v_dest, v_anchor, v_part, v_type, v_winnr] = '. string(a:def)
    endif
    return rv
endf

" Get a viki name's/link's name, destination, or anchor
" function! s:GetVikiNamePart(txt, erx, idx, errorMsg) "{{{3
"     if a:idx
"         " let rv = substitute(a:txt, '^\C'. a:erx ."$", '\'.a:idx, "")
"         let rv = matchlist(a:txt, '^\C'. a:erx ."$")[a:idx]
"         if rv == ''
"             return g:vikiDefNil
"         else
"             return rv
"         endif
"     else
"         return g:vikiDefNil
"     endif
" endf

function! s:ExtractMatch(match, idx, default) "{{{3
    if a:idx > 0
        return get(a:match, a:idx, a:default)
    else
        return a:default
    endif
endf

" If txt matches a viki name typed as defined by compound return a 
" structure defining this viki name.
function! viki#LinkDefinition(txt, col, compound, ignoreSyntax, type) "{{{3
    " TLogVAR a:txt, a:compound, a:col
    exe a:compound
    if erx != ''
        let ebeg = -1
        let cont = match(a:txt, erx, 0)
        " TLogDBG 'cont='. cont .'('. a:col .')'
        while (ebeg >= 0 || (0 <= cont) && (cont <= a:col))
            let contn = matchend(a:txt, erx, cont)
            " TLogDBG 'contn='. contn .'('. cont.')'
            if (cont <= a:col) && (a:col < contn)
                let ebeg = match(a:txt, erx, cont)
                let elen = contn - ebeg
                break
            else
                let cont = match(a:txt, erx, contn)
            endif
        endwh
        " TLogDBG 'ebeg='. ebeg
        if ebeg >= 0
            let part   = strpart(a:txt, ebeg, elen)
            let match  = matchlist(part, '^\C'. erx .'$')
            let name   = s:ExtractMatch(match, nameIdx,   g:vikiDefNil)
            let dest   = s:ExtractMatch(match, destIdx,   g:vikiDefNil)
            let anchor = s:ExtractMatch(match, anchorIdx, g:vikiDefNil)
            " let name   = s:GetVikiNamePart(part, erx, nameIdx,   "no name")
            " let dest   = s:GetVikiNamePart(part, erx, destIdx,   "no destination")
            " let anchor = s:GetVikiNamePart(part, erx, anchorIdx, "no anchor")
            " TLogVAR name, dest, anchor, part, a:type
            return viki#MakeDef(name, dest, anchor, part, a:type)
        elseif a:ignoreSyntax
            return []
        else
            throw "Viki: Malformed viki v_name: " . a:txt . " (". erx .")"
        endif
    else
        return []
    endif
endf

" Return a viki filename with a suffix
function! viki#WithSuffix(fname)
    " TLogVAR a:fname
    " TLogDBG isdirectory(a:fname)
    if isdirectory(a:fname)
        return a:fname
    else
        return a:fname . s:GetSuffix()
    endif
endf

" Get the suffix to use for viki filenames
function! s:GetSuffix() "{{{3
    if exists('b:vikiNameSuffix')
        return b:vikiNameSuffix
    endif
    if g:vikiUseParentSuffix
        let sfx = expand("%:e")
        " TLogVAR sfx
        if !empty(sfx)
            return '.'. sfx
        endif
    endif
    return g:vikiNameSuffix
endf

" Return the real destination for a simple viki name
function! viki#ExpandSimpleName(dest, name, suffix) "{{{3
    " TLogVAR a:dest
    if a:name == ''
        return a:dest
    else
        if a:dest == ''
            let dest = a:name
        else
            let dest = a:dest . g:vikiDirSeparator . a:name
        endif
        " TLogVAR dest, a:suffix
        if a:suffix == g:vikiDefSep
            " TLogDBG 'ExpandSimpleName 1'
            return viki#WithSuffix(dest)
        elseif isdirectory(dest)
            " TLogDBG 'ExpandSimpleName 2'
            return dest
        else
            " TLogDBG 'ExpandSimpleName 3'
            return dest . a:suffix
        endif
    endif
endf

" Check whether a vikiname uses an interviki
function! viki#IsInterViki(vikiname)
    return  viki#IsSupportedType('i') && a:vikiname =~# s:InterVikiRx
endf

" Get the interviki name of a vikiname
function! viki#InterVikiName(vikiname)
    " return substitute(a:vikiname, s:InterVikiRx, '\1', '')
    return matchlist(a:vikiname, s:InterVikiRx)[1]
endf

" Get the plain vikiname of a vikiname
function! viki#InterVikiPart(vikiname)
    " return substitute(a:vikiname, s:InterVikiRx, '\2', '')
    return matchlist(a:vikiname, s:InterVikiRx)[2]
endf

" Return vimscript code describing an interviki
function! s:InterVikiDef(vikiname, ...)
    let ow = a:0 >= 1 ? a:1 : viki#InterVikiName(a:vikiname)
    let vd = s:LetVar('i_dest', 'vikiInter'.ow)
    let id = s:LetVar('i_index', 'vikiInter'.ow.'_index')
    " TLogVAR a:vikiname, ow, id
    if !empty(id)
        let vd .= '|'. id
    endif
    " TLogVAR vd
    if vd != ''
        exec vd
        if i_dest =~ '^\*\S\+('
            let it = 'fn'
        elseif i_dest[0] =~ '%'
            let it = 'fmt'
        else
            let it = 'prefix'
        endif
        return vd .'|let i_type="'. it .'"|let i_name="'. ow .'"'
    end
    return vd
endf

" Return an interviki's root directory
function! viki#InterVikiDest(vikiname, ...)
    TVarArg 'ow', ['rx', 0]
    " TLogVAR ow, rx
    if empty(ow)
        let ow     = viki#InterVikiName(a:vikiname)
        let v_dest = viki#InterVikiPart(a:vikiname)
    else
        let v_dest = a:vikiname
    endif
    let vd = s:InterVikiDef(a:vikiname, ow)
    " TLogVAR vd
    if vd != ''
        exec vd
        let f = strpart(i_dest, 1)
        " TLogVAR i_type, i_dest
        if !empty(rx)
            let f = s:RxifyFilename(f)
        endif
        if i_type == 'fn'
            exec 'let v_dest = '. s:sprintf1(f, v_dest)
        elseif i_type == 'fmt'
            let v_dest = s:sprintf1(f, v_dest)
        else
            if empty(v_dest) && exists('i_index')
                let v_dest = i_index
            endif
            let i_dest = expand(i_dest)
            if !empty(rx)
                let sep    = '[\/]'
                let i_dest = s:RxifyFilename(i_dest)
            else
                let sep    = g:vikiDirSeparator
            endif
            let v_dest = i_dest . sep . v_dest
        endif
        " TLogVAR v_dest
        return v_dest
    else
        " TLogVAR ow
        echohl Error
        echom "Viki: InterViki is not defined: ". ow
        echohl NONE
        return g:vikiDefNil
    endif
endf

function! s:RxifyFilename(filename) "{{{3
    let f = tlib#rx#Escape(a:filename)
    if exists('+shellslash')
        let f = substitute(f, '\(\\\\\|/\)', '[\\/]', 'g')
    endif
    return f
endf

" Return an interviki's suffix
function! viki#InterVikiSuffix(vikiname, ...)
    exec tlib#arg#Let(['ow'])
    if empty(ow)
        let ow = viki#InterVikiName(a:vikiname)
    endif
    let vd = s:InterVikiDef(a:vikiname, ow)
    if vd != ''
        exec vd
        if i_type =~ 'fn'
            return ''
        else
            if fnamemodify(a:vikiname, ':e') != ''
                let useSuffix = ''
            else
                exec s:LetVar('useSuffix', 'vikiInter'.ow.'_suffix')
            endif
            return useSuffix
        endif
    else
        return ''
    endif
endf

" Return the modifiers in extended viki names
function! viki#ExtendedModifier(part)
    " let mod = substitute(a:part, b:vikiExtendedNameRx, '\'.b:vikiExtendedNameModIdx, '')
    let mod = matchlist(a:part, b:vikiExtendedNameRx)[b:vikiExtendedNameModIdx]
    if mod != a:part
        return mod
    else
        return ''
    endif
endf

" Complete a file's basename on the basis of a list of suffixes
function! viki#FindFileWithSuffix(filename, suffixes) "{{{3
    " TAssert IsList(a:suffixes)
    " TLogVAR a:filename, a:suffixes
    if filereadable(a:filename)
        return a:filename
    else
        for elt in a:suffixes
            if elt != ''
                let fn = a:filename .".". elt
                if filereadable(fn)
                    return fn
                endif
            else
                return g:vikiDefNil
            endif
        endfor
    endif
    return g:vikiDefNil
endf

" Do something if no viki name was found under the cursor position
function! s:LinkNotFoundEtc(oldmap, ignoreSyntax) "{{{3
    if a:oldmap == ""
        echomsg "Viki: Show me the way to the next viki name or I have to ... ".a:ignoreSyntax.":".getline(".")
    elseif a:oldmap == 1
        return "\<c-cr>"
    else
        return a:oldmap
    endif
endf

" This is the core function that builds a viki name definition from what 
" is under the cursor.
" viki#GetLink(ignoreSyntax, ?txt, ?col=0, ?supported=b:vikiNameTypes)
function! viki#GetLink(ignoreSyntax, ...) "{{{3
    let col   = a:0 >= 2 ? a:2 : 0
    let types = a:0 >= 3 ? a:3 : b:vikiNameTypes
    if a:0 >= 1 && a:1 != ''
        let txt      = a:1
        let vikiType = a:ignoreSyntax
        let tryAll   = 1
    else
        let synName = synIDattr(synID(line('.'), col('.'), 0), 'name')
        if synName ==# 'vikiLink'
            let vikiType = 1
            let tryAll   = 0
        elseif synName ==# 'vikiExtendedLink'
            let vikiType = 2
            let tryAll   = 0
        elseif synName ==# 'vikiURL'
            let vikiType = 3
            let tryAll   = 0
        elseif synName ==# 'vikiCommand' || synName ==# 'vikiMacro'
            let vikiType = 4
            let tryAll   = 0
        elseif a:ignoreSyntax
            let vikiType = a:ignoreSyntax
            let tryAll   = 1
        else
            return ''
        endif
        let txt = getline('.')
        let col = col('.') - 1
    endif
    " TLogDBG "txt=". txt
    " TLogDBG "col=". col
    " TLogDBG "tryAll=". tryAll
    " TLogDBG "vikiType=". tryAll
    if (tryAll || vikiType == 2) && viki#IsSupportedType('e', types)
        if exists('b:getExtVikiLink')
            exe 'let def = ' . b:getExtVikiLink.'()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiExtendedNameCompound, a:ignoreSyntax, 'e')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteExtendedNameDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 3) && viki#IsSupportedType('u', types)
        if exists('b:getURLViki')
            exe 'let def = ' . b:getURLViki . '()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiUrlCompound, a:ignoreSyntax, 'u')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteExtendedNameDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 4) && viki#IsSupportedType('x', types)
        if exists('b:getCmdViki')
            exe 'let def = ' . b:getCmdViki . '()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiCmdCompound, a:ignoreSyntax, 'x')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteCmdDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 1) && viki#IsSupportedType('s', types)
        if exists('b:getVikiLink')
            exe 'let def = ' . b:getVikiLink.'()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiSimpleNameCompound, a:ignoreSyntax, 's')
        endif
        " TLogVAR def
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteSimpleNameDef', '', def)
        endif
    endif
    return []
endf

" Follow a viki name if any or complain about not having found a valid 
" viki name under the cursor.
" viki#MaybeFollowLink(oldmap, ignoreSyntax, ?winNr=0)
function! viki#MaybeFollowLink(oldmap, ignoreSyntax, ...) "{{{3
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    let def = viki#GetLink(a:ignoreSyntax)
    " TAssert IsList(def)
    if empty(def)
        return s:LinkNotFoundEtc(a:oldmap, a:ignoreSyntax)
    else
        return s:FollowLink(def, winNr)
    endif
endf


function! viki#InterEditArg(iname, name) "{{{3
    if a:name !~ '^'. tlib#rx#Escape(a:iname) .'::'
        return a:iname .'::'. a:name
    else
        return a:name
    endif
endf


" Edit a vikiname
" viki#Edit(name, ?bang='', ?winNr=0, ?ìgnoreSpecial=0)
function! viki#Edit(name, ...) "{{{3
    TVarArg ['bang', ''], ['winNr', 0], ['ignoreSpecial', 0]
    " TLogVAR a:name
    if exists('b:vikiEnabled') && bang != '' && 
                \ exists('b:vikiFamily') && b:vikiFamily != ''
                " \ (!exists('b:vikiFamily') || b:vikiFamily != '')
        if g:vikiHomePage != ''
            call viki#OpenLink(g:vikiHomePage, '', '', '', winNr)
        else
            call s:EditWrapper('buffer', 1)
        endif
    endif
    if a:name == '*'
        let name = g:vikiHomePage
    else
        let name = a:name
    end
    let name = substitute(name, '\\', '/', 'g')
    if !exists('b:vikiNameTypes')
        call viki#SetBufferVar('vikiNameTypes')
        call viki#DispatchOnFamily('SetupBuffer', '', 0)
    endif
    let def = viki#GetLink(1, '[['. name .']]', 0, '')
    " TLogVAR def
    " TAssert IsList(def)
    if empty(def)
        call s:LinkNotFoundEtc('', 1)
    else
        exec viki#SplitDef(def)
        if ignoreSpecial
            call viki#OpenLink(v_dest, '', '', '', winNr)
        else
            call s:OpenLink(v_dest, '', winNr)
        endif
    endif
endf


function! viki#Browse(name) "{{{3
    " TLogVAR a:name
    let iname = a:name .'::'
    let vd = s:InterVikiDef(iname, a:name)
    " TLogVAR vd
    if !empty(vd)
        exec vd
        " TLogVAR i_type
        if i_type == 'prefix'
            exec s:LetVar('sfx', 'vikiInter'. a:name .'_suffix')
            " TLogVAR i_dest, sfx
            let files = split(globpath(i_dest, '**'), '\n')
            if !empty(sfx)
                call filter(files, 'v:val =~ '''. tlib#rx#Escape(sfx) .'$''')
            endif
            let files = tlib#input#List('m', 'Select files', files, [
                        \ {'display_format': 'filename'},
                        \ ])
            for fn in files
                call viki#OpenLink(fn, g:vikiDefNil)
                " echom fn
            endfor
            return
        endif
    endif
    echoerr 'Viki: No an interviki name: '. a:name
endf

function! viki#BrowseComplete(ArgLead, CmdLine, CursorPos) "{{{3
    let rv = copy(s:InterVikis)
    let rv = filter(rv, 'v:val =~ ''^'. a:ArgLead .'''')
    let rv = map(rv, 'matchstr(v:val, ''\w\+'')')
    return rv
endf


" Helper function for the command line completion of :VikiEdit
function! s:EditCompleteAgent(interviki, afname, fname) "{{{3
    if isdirectory(a:afname)
        return a:afname .'/'
    else
        if exists('g:vikiInter'. a:interviki .'_suffix')
            let sfx = g:vikiInter{a:interviki}_suffix
        else
            let sfx = s:GetSuffix()
        endif
        if sfx != '' && sfx == '.'. fnamemodify(a:fname, ':e')
            let name = fnamemodify(a:fname, ':t:r')
        else
            let name = a:fname
        endif
        " if name !~ '\C'. viki#GetSimpleRx4SimpleWikiName()
        "     let name = '[-'. a:fname .'-]'
        " endif
        if a:interviki != ''
            let name = a:interviki .'::'. name
        endif
        return name
    endif
endf

" Helper function for the command line completion of :VikiEdit
function! s:EditCompleteMapAgent1(val, sfx, iv, rx) "{{{3
    if isdirectory(a:val)
        let rv = a:val .'/'
    else
        let rsfx = '\V'. a:sfx .'\$'
        if a:sfx != '' && a:val !~ rsfx
            return ''
        else
            let rv = substitute(a:val, rsfx, '', '')
            if isdirectory(rv)
                let rv = a:val
            endif
        endif
    endif
    " TLogVAR rv, a:rx
    " let rv = substitute(rv, a:rx, '\1', '')
    let rv = matchlist(rv, a:rx)[1]
    " TLogVAR rv
    if empty(a:iv)
        return rv
    else
        return a:iv .'::'. rv
    endif
endf

" Command line completion of :VikiEdit
function! viki#EditComplete(ArgLead, CmdLine, CursorPos) "{{{3
    " TLogVAR a:ArgLead, a:CmdLine, a:CursorPos
    " let arglead = a:ArgLead
    let rx_pre = '^\s*\(\d*\(verb\|debug\|sil\|sp\|vert\|tab\)\w\+!\?\s\+\)*'
    let arglead = matchstr(a:CmdLine, rx_pre .'\(\u\+\)\s\zs.*')
    let ii = matchstr(a:CmdLine, rx_pre .'\zs\(\u\+\)\ze\s')
    " TLogVAR ii
    if !empty(ii) && arglead !~ '::'
        let arglead = ii.'::'.arglead
    endif
    let i = viki#InterVikiName(arglead)
    " TLogVAR i, arglead
    if index(s:InterVikis, i.'::') >= 0
        if exists('g:vikiInter'. i .'_suffix')
            let sfx = g:vikiInter{i}_suffix
        else
            let sfx = s:GetSuffix()
        endif
    else
        let i = ''
        let sfx = s:GetSuffix()
    endif
    " TLogVAR i
    if i != '' && exists('g:vikiInter'. i)
        " TLogDBG 'A'
        let f  = matchstr(arglead, '::\(\[-\)\?\zs.*$')
        let d  = viki#InterVikiDest(f.'*', i)
        let r  = '^'. viki#InterVikiDest('\(.\{-}\)', i, 1) .'$'
        " TLogVAR f,d,r
        let d  = substitute(d, '\', '/', 'g')
        let rv = split(glob(d), '\n')
        " call map(rv, 'escape(v:val, " ")')
        " TLogVAR d,rv
        if sfx != ''
            call filter(rv, 'isdirectory(v:val) || ".". fnamemodify(v:val, ":e") == sfx')
        endif
        " TLogVAR rv
        call map(rv, 's:EditCompleteMapAgent1(v:val, sfx, i, r)')
        " TLogVAR rv
        call filter(rv, '!empty(v:val)')
        " TLogVAR rv
        " call map(rv, string(i). '."::". substitute(v:val, r, ''\1'', "")')
    else
        " TLogDBG 'B'
        let rv = split(glob(arglead.'*'.sfx), '\n')
        " TLogVAR rv
        call map(rv, 's:EditCompleteAgent('. string(i) .', v:val, v:val)')
        " TLogVAR rv
        " call map(rv, 'escape(v:val, " ")')
        " TLogVAR rv
        if arglead == ''
            let rv += s:InterVikis
        else
            let rv += filter(copy(s:InterVikis), 'v:val =~ ''\V\^''.arglead')
        endif
    endif
    " TLogVAR rv
    " call map(rv, 'substitute(v:val, ''^\(.\{-}\s\ze\S*$'', "", "")')
    " call map(rv, 'escape(v:val, "%# ")')
    return rv
endf

" Edit the current directory's index page
function! viki#Index() "{{{3
    if exists('b:vikiIndex')
        let fname = viki#WithSuffix(b:vikiIndex)
    else
        let fname = viki#WithSuffix(g:vikiIndex)
    endif
    if filereadable(fname)
        return viki#OpenLink(fname, '')
    else
        echom "Index page not found: ". fname
    endif
endf


fun! viki#FindNextRegion(name) "{{{3
    let rx = s:GetRegionStartRx(a:name)
    return search(rx, 'We')
endf


""" indent {{{1
fun! viki#GetIndent()
    let lr = &lazyredraw
    set lazyredraw
    try
        let cnum = v:lnum
        " Find a non-blank line above the current line.
        let lnum = prevnonblank(v:lnum - 1)

        " At the start of the file use zero indent.
        if lnum == 0
            " TLogVAR lnum
            return 0
        endif

        let ind  = indent(lnum)
        " if ind == 0
        "     TLogVAR ind
        "     return 0
        " end

        let line = getline(lnum)      " last line
        " TLogVAR lnum, ind, line
        
        let cind  = indent(cnum)
        let cline = getline(cnum)
        " TLogVAR v:lnum, cnum, cind, cline
        
        " Do not change indentation in regions
        if viki#IsInRegion(cnum)
            " TLogVAR cnum, cind
            return cind
        endif
        
        let cHeading = matchend(cline, '^\*\+\s\+')
        if cHeading >= 0
            " TLogVAR cHeading
            return 0
        endif
            
        let pnum   = v:lnum - 1
        let pind   = indent(pnum)
        let pline  = getline(pnum) " last line
        let plCont = matchend(pline, '\\$')
        
        if plCont >= 0
            " TLogVAR plCont, cind
            return cind
        end
        
        if cind > 0
            " TLogVAR cind
            " Do not change indentation of:
            "   - commented lines
            "   - headings
            if cline =~ '^\(\s*%\|\*\)'
                " TLogVAR cline, ind
                return ind
            endif

            let markRx = '^\s\+\([#?!+]\)\1\{2,2}\s\+'
            let listRx = '^\s\+\([-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\)\s\+'
            let priRx  = '^\s\+#[A-Z]\d\? \+\([x_0-9%-]\+ \+\)\?'
            let descRx = '^\s\+.\{-1,}\s::\s\+'
            
            let clMark = matchend(cline, markRx)
            let clList = matchend(cline, listRx)
            let clPri  = matchend(cline, priRx)
            let clDesc = matchend(cline, descRx)
            " let cln    = clList >= 0 ? clList : clDesc

			let swhalf = &sw / 2

            if clList >= 0 || clDesc >= 0 || clMark >= 0 || clPri >= 0
                " let spaceEnd = matchend(cline, '^\s\+')
                " let rv = (spaceEnd / &sw) * &sw
                let rv = (cind / &sw) * &sw
                " TLogVAR clList, clDesc, clMark, clPri, rv
                return rv
            else
                let plMark = matchend(pline, markRx)
                if plMark >= 0
                    " TLogVAR plMark
                    " return plMark
                    return pind + 4
                endif
                
                let plList = matchend(pline, listRx)
                if plList >= 0
                    " TLogVAR plList
                    return plList
                endif

                let plPri = matchend(pline, priRx)
                if plPri >= 0
                    " let rv = indent(pnum) + &sw / 2
                    let rv = pind + swhalf
                    " TLogVAR plPri, rv
                    " return plPri
                    return rv
                endif

                let plDesc = matchend(pline, descRx)
                if plDesc >= 0
                    " TLogVAR plDesc, pind
                    if plDesc >= 0 && g:vikiIndentDesc == '::'
                        " return plDesc
                        return pind
                    else
                        return pind + swhalf
                    endif
                endif

                " TLogVAR cind, ind
                if cind < ind
                    let rv = (cind / &sw) * &sw
                    return rv
                elseif cind >= ind
                    if cind % &sw == 0
                        return cind
                    else
                        return ind
                    end
                endif
            endif
        endif

        " TLogVAR ind
        return ind
    finally
        let &lazyredraw = lr
    endtry
endf

function! viki#ExecExternal(cmd) "{{{3
    " TLogVAR a:cmd
    exec a:cmd
    if !has("gui_running")
        " Scrambled window with vim
        redraw!
    endif
endf


""" #Files related stuff {{{1
fun! viki#FilesUpdateAll() "{{{3
    let p = getpos('.')
    try
        norm! gg
        while viki#FindNextRegion('Files')
            call viki#FilesUpdate()
            norm! j
        endwh
    finally
        call setpos('.', p)
    endtry
endf

fun! viki#FilesExec(cmd, bang, ...) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    if a:0 >= 1 && a:1
        let lb = line('.')
        let le = line('.') + 1
    endif
    let ilen = len(indent)
    let done = []
    for f in s:CollectFileNames(lb, le, a:bang)
        let ff = escape(f, '%#\ ')
        let x = viki#SubstituteArgs(a:cmd, 
                    \ '', ff, 
                    \ 'FILE', f, 
                    \ 'FFILE', ff,
                    \ 'DIR', fnamemodify(f, ':h'))
        if index(done, x) == -1
            exec x
            call add(done, x)
        endif
    endfor
endf

fun! viki#FilesCmd(cmd, bang) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        exec VikiCmd_{a:cmd} .' '. escape(t, '%#\ ')
    endfor
endf

fun! viki#FilesCall(cmd, bang) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        call VikiCmd_{a:cmd}(t)
    endfor
endf

fun! s:CollectFileNames(lb, le, bang) "{{{3
    let afile = viki#FilesGetFilename(getline('.'))
    let acc   = []
    for l in range(a:lb, a:le - 1)
        let line  = getline(l)
        let bfile = viki#FilesGetFilename(line)
        if s:IsEligibleLine(afile, bfile, a:bang)
            call add(acc, fnamemodify(bfile, ':p'))
        endif
    endfor
    return acc
endf

fun! s:IsEligibleLine(afile, bfile, bang) "{{{3
    if empty(a:bang)
        return 1
    else
        if isdirectory(a:bfile)
            return 0
        else
            let adir  = isdirectory(a:afile) ? a:afile : fnamemodify(a:afile, ':h')
            let bdir  = isdirectory(a:bfile) ? a:bfile : fnamemodify(a:bfile, ':h')
            let rv = s:IsSubdir(adir, bdir)
            return rv
        endif
    endif
endf

fun! s:IsSubdir(adir, bdir) "{{{3
    if a:adir == '' || a:bdir == ''
        return 0
    elseif a:adir == a:bdir
        return 1
    else
        return s:IsSubdir(a:adir, fnamemodify(a:bdir, ':h'))
    endif
endf

fun! viki#FilesUpdate() "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    " 'vikiFiles', 'vikiFilesRegion'
    call s:DeleteRegionBody(lb, le)
    call viki#DirListing(lh, lb, indent)
endf

fun! viki#DirListing(lhs, lhb, indent) "{{{3
    let args = s:GetRegionArgs(a:lhs, a:lhb - 1)
    " TLogVAR args
    let patt = get(args, 'glob', '')
    " TLogVAR patt
    if empty(patt)
        echoerr 'Viki: No glob pattern defnied: '. string(args)
    else
        let p = getpos('.')
        let t = @t
        try
            " let style = get(args, 'style', 'ls')
            " let ls = VikiGetDirListing_{style}(split(glob(patt), '\n'))
            let ls = split(glob(patt), '\n')
            " TLogVAR ls
            let types = get(args, 'types', '')
            " TLogVAR ls
            if !empty(types)
                let show_files = stridx(types, 'f') != -1
                let show_dirs  = stridx(types, 'd') != -1
                call filter(ls, '(show_files && !isdirectory(v:val)) || (show_dirs && isdirectory(v:val))')
            endif
            let filter = get(args, 'filter', '')
            if !empty(filter)
                call filter(ls, 'v:val =~ filter')
            endif
            let exclude = get(args, 'exclude', '')
            if !empty(exclude)
                call filter(ls, 'v:val !~ exclude')
            endif
            let order = get(args, 'order', '')
            " if !empty(order)
            "     if order == 'd'
            "         call sort(ls, 's:SortDirsFirst')
            "     endif
            " endif
            let list = split(get(args, 'list', ''), ',\s*')
            call map(ls, 'a:indent.s:GetFileEntry(v:val, list)')
            let @t = join(ls, "\<c-j>") ."\<c-j>"
            exec 'norm! '. a:lhb .'G"tP'
        finally
            let @t = t
            call setpos('.', p)
        endtry
    endif
endf

" fun! VikiGetDirListing_ls(files)
"     return a:files
" endf

fun! s:GetFileEntry(file, list) "{{{3
    " let prefix = substitute(a:file, '[^/]', '', 'g')
    " let prefix = substitute(prefix, '/', repeat(' ', &shiftwidth), 'g')
    let attr = []
    if index(a:list, 'detail') != -1
        let type = getftype(a:file)
        if type != 'file'
            if type == 'dir'
                call add(attr, 'D')
            else
                call add(attr, type)
            endif
        endif
        call add(attr, strftime('%c', getftime(a:file)))
        call add(attr, getfperm(a:file))
    else
        if isdirectory(a:file)
            call add(attr, 'D')
        endif
    endif
    let f = []
    let d = s:GetDepth(a:file)
    " if index(a:list, 'tree') == -1
    "     call add(f, '[[')
    "     call add(f, repeat('|-', d))
    "     if index(attr, 'D') == -1
    "         call add(f, ' ')
    "     else
    "         call add(f, '-+ ')
    "     endif
    "     call add(f, fnamemodify(a:file, ':t') .'].]')
    " else
        if index(a:list, 'flat') == -1
            call add(f, repeat(' ', d * &shiftwidth))
        endif
        call add(f, '[['. a:file .']!]')
    " endif
    if !empty(attr)
        call add(f, ' {'. join(attr, '|') .'}')
    endif
    let c = get(s:savedComments, a:file, '')
    if !empty(c)
        call add(f, c)
    endif
    return join(f, '')
endf

fun! s:GetDepth(file) "{{{3
    return len(substitute(a:file, '[^/]', '', 'g'))
endf

fun! s:GetRegionArgs(ls, le) "{{{3
    let t = @t
    " let p = getpos('.')
    try
        let t = s:GetBrokenLine(a:ls, a:le)
        " TLogVAR t
        let t = matchstr(t, '^\s*#\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)\zs.\{-}\ze<<$')
        " TLogVAR t
        let args = {}
        let rx = '^\s*\(\(\S\{-}\)=\("\(\(\"\|.\{-}\)\{-}\)"\|\(\(\S\+\|\\ \)\+\)\)\|\(\w\)\+!\)\s*'
        let s  = 0
        let sm = len(t)
        while s < sm
            let m = matchlist(t, rx, s)
            " TLogVAR m
            if empty(m)
                echoerr "Viki: Can't parse argument list: ". t
            else
                let key = m[2]
                " TLogVAR key
                if !empty(key)
                    let val = empty(m[4]) ? m[6] : m[4]
                    if val =~ '^".\{-}"'
                        let val = val[1:-2]
                    endif
                    let args[key] = substitute(val, '\\\(.\)', '\1', 'g')
                else
                    let key = m[8]
                    if key == '^no\u'
                        let antikey = substitute(key, '^no\zs.', '\l&', '')
                    else
                        let antikey = 'no'. substitute(key, '^.', '\u&', '')
                    endif
                    let args[key] = 1
                    let args[antikey] = 0
                endif
                let s += len(m[0])
            endif
        endwh
        return args
    finally
        let @t = t
        " call setpos('.', p)
    endtry
endf

fun! s:GetBrokenLine(ls, le) "{{{3
    let t = @t
    try
        exec 'norm! '. a:ls .'G"ty'. a:le .'G'
        let @t = substitute(@t, '[^\\]\zs\\\n\s*', '', 'g')
        let @t = substitute(@t, '\n*$', '', 'g')
        return @t
    finally
        let @t = t
    endtry
endf

fun! s:GetRegionStartRx(...) "{{{3
    let name = a:0 >= 1 && !empty(a:1) ? '\(\('. a:1 .'\>\)\)' : '\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)'
    let rx_start = '^\([[:blank:]]*\)#'. name .'\(\\\n\|.\)\{-}<<\(.*\)$'
    return rx_start
endf

fun! s:GetRegionGeometry(...) "{{{3
    let p = getpos('.')
    try
        norm! $
        let rx_start = s:GetRegionStartRx(a:0 >= 1 ? a:1 : '')
        let hds = search(rx_start, 'cbWe')
        if hds > 0
            let hde = search(rx_start, 'ce')
            let hdt = s:GetBrokenLine(hds, hde)
            let hdm = matchlist(hdt, rx_start)
            let hdi = hdm[1]
            let rx_end = '\V\^\[[:blank:]]\*'. escape(hdm[5], '\') .'\[[:blank:]]\*\$'
            let hbe = search(rx_end)
            if hds > 0 && hde > 0 && hbe > 0
                return [hds, hde + 1, hbe, hdi]
            else
                echoerr "Viki: Can't determine region geometry: ". string([hds, hde, hbe, hdi, hdm, rx_start, rx_end])
            endif
        else
            echoerr "Viki: Can't determine region geometry: ". join([rx_start], ', ')
        endif
        return [0, 0, 0, '']
    finally
        call setpos('.', p)
    endtry
endf

fun! s:DeleteRegionBody(...) "{{{3
    if a:0 >= 2
        let lb = a:1
        let le = a:2
    else
        let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    endif
    call s:SaveComments(lb, le - 1)
    if le > lb
        exec 'norm! '. lb .'Gd'. (le - 1) .'G'
    endif
endf

fun! s:SaveComments(lb, le) "{{{3
    let s:savedComments = {}
    for l in range(a:lb, a:le)
        let t = getline(l)
        let k = viki#FilesGetFilename(t)
        if !empty(k)
            let s:savedComments[k] = viki#FilesGetComment(t)
        endif
    endfor
endf

fun! viki#FilesGetFilename(t) "{{{3
    return matchstr(a:t, '^\s*\[\[\zs.\{-}\ze\]!\]')
endf

fun! viki#FilesGetComment(t) "{{{3
    return matchstr(a:t, '^\s*\[\[.\{-}\]!\]\( {.\{-}}\)\?\zs.*')
endf

