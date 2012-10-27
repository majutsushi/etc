" pairs.vim -- Smart pairs handling
" Author       : Jan Larres <jan@majutsushi.net>

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

" s:HandleOpenParen() {{{2
function! s:HandleOpenParen(char) abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    " Don't pair escaped characters
    if cprev == '\'
        return a:char
    endif

    " Don't pair characters if text to the right of cursor matches
    " s:right_regex
    let right_regex = substitute(s:right_regex, '\\\!',
                \ a:char == '[' ? '\\\[' : a:char, '')
    let right_regex = substitute(right_regex, '\\\#',
                \ b:pairs_conf.parens[a:char] == ']' ? '\\\]' : b:pairs_conf.parens[a:char], '')
    if getline('.')[col('.') - 1:] =~# right_regex
        return a:char
    endif

    return a:char . b:pairs_conf.parens[a:char] . "\<Left>"
endfunction

" s:HandleCloseParen() {{{2
function! s:HandleCloseParen(char) abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    if cprev == '\'
        return a:char
    endif

    if ccur == a:char
        return "\<Right>"
    endif

    return a:char
endfunction

" s:HandleQuote() {{{2
function! s:HandleQuote(char) abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    " Don't pair escaped characters
    if cprev == '\'
        return a:char
    endif

    " Jump out of string
    if ccur == a:char
        return "\<Right>"
    endif

    " Make quotes smarter
    let exclre = '\w\|[^[:punct:][:space:]]'
    if cprev == a:char || cprev =~# exclre || ccur =~# exclre
        return a:char
    end

    return a:char . b:pairs_conf.quotes[a:char] . "\<Left>"
endfunction

" s:HandleSpace() {{{2
function! s:HandleSpace() abort
    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    if has_key(b:pairs_conf.parens, cprev) && ccur == b:pairs_conf.parens[cprev]
        return "\<C-]>\<Space>\<Space>\<Left>"
    else
        return "\<C-]>\<Space>"
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

    if has_key(b:pairs_conf.pairs, cprev) && ccur == b:pairs_conf.pairs[cprev]
        " delete pair
        return "\<Delete>\<BS>"
    elseif cprev == ' ' && ccur == ' ' &&
         \ has_key(b:pairs_conf.parens, cpprev) && cnext == b:pairs_conf.parens[cpprev]
        " delete padding spaces
        return "\<Delete>\<BS>"
    elseif getline('.') =~# '^\s*$' && has_key(b:pairs_conf.pairs, lprevc)
        " change
        "
        " foo {
        "     |
        " }
        "
        " to
        "
        " foo {|}
        let lnext = getline(line('.') + 1)
        let lnextc = lnext[len(lnext) - 1]

        let closechars = join(values(b:pairs_conf.pairs), '')
        let closechars = substitute(closechars, '\]', '\\\]', '')
        let closepattern = '^\s*[' . closechars . ']$'

        if lnext =~# closepattern && lnextc == b:pairs_conf.pairs[lprevc]
            let delline = col('.') > 1 ? "\<C-U>" : ""
            return delline . "\<BS>\<Esc>J\<Del>i"
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

    if rv !~ "^\<C-]>"
        let rv = "\<C-]>" . rv
    endif

    let cprev = s:getcharrel(-1)
    let ccur  = s:getcharrel(0)

    " feedkeys() necessary here since the return value will be executed before
    " the feedkeys() above
    if has_key(b:pairs_conf.pairs, cprev) && ccur == b:pairs_conf.pairs[cprev]
        call feedkeys(rv . "\<Esc>==O", 'n')
        return ''
    else
        call feedkeys(rv, 'n')
        return ''
    endif
endfunction

" s:Init() {{{2
function! s:Init() abort
    if exists('b:pairs_conf')
        return
    endif

    let b:pairs_conf = {}

    let b:pairs_conf.parens = {}
    for pair in split(exists('b:pairs_parens') ? b:pairs_parens : &matchpairs, ',')
        let [open, close] = split(pair, ':')
        let b:pairs_conf.parens[open] = close
    endfor

    let b:pairs_conf.quotes = {}
    for quote in exists('b:pairs_quotes') ? split(b:pairs_quotes, '\zs') : ['"', "'", '`']
        let b:pairs_conf.quotes[quote] = quote
    endfor

    let b:pairs_conf.pairs  = extend(copy(b:pairs_conf.parens), b:pairs_conf.quotes)

    let mappre = 'inoremap <expr> <silent> <buffer> '
    for char in keys(b:pairs_conf.parens)
        if mapcheck(char, 'i') == ''
            execute mappre . char . ' <SID>HandleOpenParen("' . char . '")'
        endif
    endfor
    for char in values(b:pairs_conf.parens)
        if mapcheck(char, 'i') == ''
            execute mappre . char . ' <SID>HandleCloseParen("' . char . '")'
        endif
    endfor
    for char in keys(b:pairs_conf.quotes)
        if mapcheck(char, 'i') == ''
            execute mappre . char . ' <SID>HandleQuote("' . (char == '"' ? '\"' : char) . '")'
        endif
    endfor

    let maprhs = escape(maparg('<CR>', 'i'), '"')
    if maprhs != ''
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
    else
        inoremap <expr> <silent> <buffer> <CR> <SID>HandleCR()
    endif
endfunction

autocmd BufEnter * call s:Init()
