" pairs.vim -- Smart pairs handling
" Author       : Jan Larres <jan@majutsushi.net>

let s:parens = { '(' : ')', '{' : '}', '[' : ']', '<' : '>' }
let s:parensr = {}
for [key, val] in items(s:parens)
    let s:parensr[val] = key
endfor
let s:quotes = { '"' : '"', "'" : "'", '`' : '`' }
let s:pairs = extend(copy(s:parens), s:quotes)

" Taken from delimitMate
" \! => opening character
" \# => closing character
let s:right_regex = '^\%(\w\|\!\|£\|\$\|_\|["'']\s*\S\)'

" s:getcharrel() {{{2
function! s:getcharrel(pos) abort
    let line = getline('.')
    let idx  = col('.') - 1

    if idx + a:pos < 0
        return ''
    endif

    return line[idx + a:pos]
endfunction

" s:OnOpenChar() {{{2
function! s:OnOpenChar(char) abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    " Don't pair escaped characters
    if cprev == '\'
        return a:char
    endif

    if has_key(s:parens, a:char)
        " Don't pair characters if text to the right of cursor matches
        " s:right_regex
        let right_regex = substitute(s:right_regex, '\\\!',
                    \ a:char == '[' ? '\\\[' : a:char, '')
        let right_regex = substitute(right_regex, '\\\#',
                    \ s:pairs[a:char] == ']' ? '\\\]' : s:pairs[a:char], '')
        if getline('.')[col('.') - 1:] =~# right_regex
            return a:char
        endif
    else
        " Make quotes smarter
        let exclre = '\w\|[^[:punct:][:space:]]'
        if cprev == a:char || cprev =~# exclre || ccur =~# exclre
            return a:char
        end
    endif

    return a:char . s:pairs[a:char] . "\<Left>"
endfunction

for char in keys(s:pairs)
    execute 'inoremap <expr> <silent> ' . char . ' <SID>OnOpenChar("' . (char == '"' ? '\"' : char) . '")'
endfor

" s:OnCloseChar() {{{2
function! s:OnCloseChar(char) abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    if cprev == '\'
        return a:char
    endif

    if a:char == ccur
        return "\<Right>"
    endif

    return a:char
endfunction

for char in values(s:parens)
    execute 'inoremap <expr> <silent> ' . char . ' <SID>OnCloseChar("' . char . '")'
endfor

" s:HandleSpace() {{{2
function! s:HandleSpace() abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    if has_key(s:pairs, cprev) && ccur == s:pairs[cprev]
        return "\<Space>\<Space>\<Left>"
    else
        return "\<Space>"
    endif
endfunction

inoremap <expr> <silent> <Space> <SID>HandleSpace()

" s:HandleBackSpace() {{{2
function! s:HandleBackSpace() abort
    let cpprev = s:getcharrel(-2)
    let cprev  = s:getcharrel(-1)
    let ccur   = s:getcharrel(0)
    let cnext  = s:getcharrel(1)

    let lprev = getline(line('.') - 1)
    let lprevc = lprev[len(lprev) - 1]

    if has_key(s:pairs, cprev) && ccur == s:pairs[cprev]
        return "\<Delete>\<BS>"
    elseif cprev == ' ' && ccur == ' ' &&
         \ has_key(s:pairs, cpprev) && cnext == s:pairs[cpprev]
        return "\<Delete>\<BS>"
    elseif getline('.') =~# '^\s*$' && has_key(s:pairs, lprevc)
        let lnext = getline(line('.') + 1)
        let lnextc = lnext[len(lnext) - 1]

        let closechars = join(values(s:pairs), '')
        let closechars = substitute(closechars, '\]', '\\\]', '')
        let closepattern = '^\s*[' . closechars . ']$'

        if lnext =~# closepattern && lnextc == s:pairs[lprevc]
            return "\<C-U>\<BS>\<Esc>J\<Del>i"
        else
            return "\<BS>"
        endif
    else
        return "\<BS>"
    endif
endfunction

inoremap <expr> <silent> <BS> <SID>HandleBackSpace()

" s:HandleCR() {{{2
function! s:HandleCR(...) abort
    let rv = "\<CR>"
    if a:0 > 0
        let maprhs = a:1
        let mapexpr = a:2
        let mapnore = a:3
        if mapexpr
            let rv = eval(maprhs)
        else
            " Can't flush the typeahead to check line numbers :(
            call feedkeys(maprhs, mapnore ? 'n' : 'm')
            let rv = ''
        endif
    endif

    if rv !~# "\<CR>$" && rv != ''
        return rv
    endif

    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    " echomsg cprev
    " echomsg ccur

    " feedkeys() necessary here since the return value will be executed before
    " the feedkeys() above
    if has_key(s:pairs, cprev) && ccur == s:pairs[cprev]
        call feedkeys(rv . "\<Esc>==O", 'n')
        return ''
    else
        call feedkeys(rv, 'n')
        return ''
    endif
endfunction

" s:MapCRLocal() {{{2
function! s:MapCRLocal() abort
    let maprhs  = escape(maparg('<CR>', 'i'), '"')
    if maprhs != '' && maprhs !~# '_HandleCR('
        if v:version > 703 || v:version == 703 && has('patch032')
            let mapdict = maparg('<CR>', 'i', 0, 1)
            let args = '"' . maprhs . '", ' . mapdict.expr . ', ' . mapdict.noremap
            execute 'inoremap <expr> <silent> <buffer> <CR> <SID>HandleCR(' . args . ')'
        else
            " This is a guess, but should probably be ok for our use case
            let mapexpr = maprhs !~# "<C-R>=" && maprhs !~# "<Plug>"
            let args = '"' . maprhs . '", ' . mapexpr . ', 1'
            execute 'inoremap <expr> <silent> <buffer> <CR> <SID>HandleCR(' . args . ')'
        endif
    endif
endfunction

autocmd BufEnter * call s:MapCRLocal()
