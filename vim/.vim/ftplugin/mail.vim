" mail FTplugin
"
" modified from mail.tgz by Brian Medley

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin_after")
  finish
endif
let b:did_ftplugin_after = 1

" Quote definitions {{{1

let s:quote_chars = '|>}#%'

" This re defines a 'quote'

if exists ("g:mail_quote_mark_re")
    let s:quote_mark_re = g:mail_quote_mark_re
else
    " Start
    let s:quote_mark_re = '\%('

    " we don't care about people's websites or where to get files
    let s:quote_mark_re = s:quote_mark_re . '\%(http:\|ftp:\|scp:\)\@!'

    " sometimes there are pesky smiley's on a line
    let s:quote_mark_re = s:quote_mark_re . '\%(:[\-\^]\?[][)(><}{|/DP]\)\@!'

    " some ppl put initals in the quotes
    let s:quote_mark_re = s:quote_mark_re . '\w\{-,4}'

    " actual quote chars
    let s:quote_mark_re = s:quote_mark_re . '[' . s:quote_chars . ']'

    " Ignore long "runs" of quote_chars.  This is to avoid "separators" in
    " email: e.g.
    "
    "   > ################### begin excerpt ###################
    "   > blah blah blah
    "   > ################### end excerpt   ###################
    let s:quote_mark_re = s:quote_mark_re . '\%([' . s:quote_chars . ']\{4,}\)\@!'

    " some ppl put whitespace in the quote, and others don't.
    let s:quote_mark_re = s:quote_mark_re . '\s\?'

    " End
    let s:quote_mark_re = s:quote_mark_re . '\)'
endif

let s:quote_block_re = '^' . s:quote_mark_re . '\+'

" Mappings {{{1

if !exists("no_plugin_maps") && !exists("no_mail_after_maps")

    if !hasmapto('<Plug>MailQuoteFixupSpaces', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qfs <Plug>MailQuoteFixupSpaces
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteFixupSpaces <SID>QuoteFixupSpaces
    nnoremap <buffer> <SID>QuoteFixupSpaces :call <SID>QuoteFixupSpaces("inc_or_dec")<cr>

    if !hasmapto('<Plug>MailQuoteFixupSpaces', 'v')
        xmap <silent> <buffer> <unique> <LocalLeader>qfs <Plug>MailQuoteFixupSpaces
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteFixupSpaces <SID>QuoteFixupSpaces
    vnoremap <buffer> <SID>QuoteFixupSpaces :call <SID>QuoteFixupSpaces("visual")<cr>

    " -----------------

    if !hasmapto('<Plug>MailQuoteMangledMerge', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qmm <Plug>MailQuoteMangledMerge
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteMangledMerge <SID>QuoteMangledMerge
    nnoremap <buffer> <SID>QuoteMangledMerge :.,.+1call <SID>QuoteMangledMerge()<cr>

    if !hasmapto('<Plug>MailQuoteMangledMerge', 'v')
        xmap <silent> <buffer> <unique> <LocalLeader>qmm <Plug>MailQuoteMangledMerge
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteMangledMerge <SID>QuoteMangledMerge
    vnoremap <buffer> <SID>QuoteMangledMerge :call <SID>QuoteMangledMerge()<cr>

    " -----------------

    if !hasmapto('<Plug>MailQuoteDelEmpty', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qde <Plug>MailQuoteDelEmpty
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteDelEmpty <SID>QuoteDelEmpty
    nnoremap <buffer> <SID>QuoteDelEmpty :%call <SID>QuoteDelEmpty()<cr>

    if !hasmapto('<Plug>MailQuoteDelEmpty', 'v')
        xmap <silent> <buffer> <unique> <LocalLeader>qde <Plug>MailQuoteDelEmpty
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteDelEmpty <SID>QuoteDelEmpty
    vnoremap <buffer> <SID>QuoteDelEmpty :call <SID>QuoteDelEmpty()<CR>

    " -----------------

    " Provide a motion operator for commands (so you can delete a quote
    " segment, or format quoted segment)
    "
    if !hasmapto('<Plug>MailQuoteMotion', 'o')
        omap <silent> <buffer> <unique> q <Plug>MailQuoteMotion
    endif
    onoremap <buffer> <unique> <script> <Plug>MailQuoteMotion <SID>QuoteMotion
    onoremap <buffer> <script> <SID>QuoteMotion :execute "normal!" . <SID>QuoteMotion(line("."), "inc_or_dec")<cr>
endif

" Functions {{{1

" QuoteEraseSig {{{2
" This routine will try and remove 'quoted' signatures.
"
" If someone responds with an email that doesn't use '>' as the
" quote character this will try and take care of that:
"   | Yeah, I agree vim is cool.
"   |
"   | --
"   | Some power user
"
" If there is a signature inside a 'multi-quoted' email this will try and get
" rid of it:
"   > | No, I don't agree with you.
"   >
"   > Nonsense.  You are wrong.  Grow up.
"   >
"   > | I can't believe I'm even replying to this.
"   > | --
"   > | Some power user
"   >
"   > Yeah, believe it, brother.
"
function! s:QuoteEraseSig()
    let start_location = line (".")

    " TODO:
    "   modify this loop so that the cursor doesn't change
    "   delete blank quoted lines before the sig
    while 0 != search((s:quote_block_re . '\s*--\s*$'), 'w')
        let motion = s:QuoteMotion(line("."), "dec")
        exe "normal! d" . motion
    endwhile

    " restore starting position
    exe "normal! " . a:firstline . 'gg'
endfunction

" QuoteMangledMerge {{{2
" This routine will try and make sense out of 'Mangled' quoted paragraph.
" For example, it will try and turn
"
" > > starting to look like a distro problem... Anyone
" > else
" > > having this problem running a different distro
" > besides
" > > LinuxBlast 8? Anyone tried 8.1 yet?
"
" into:
"
" > > starting to look like a distro problem... Anyone else
" > > having this problem running a different distro besides
" > > LinuxBlast 8? Anyone tried 8.1 yet?
"
" NOTE: It does *not* reformat like 'gq'.  It only tries to merge a series of
" alternating quote levels.
"
" Definition:
" - Mangled line - It takes two lines to makeup one mangled line.  There will
"   be a quoting level difference between the two.  The second line must have
"   a smaller quoting level than the first to be considered mangled.
"
" Assumptions:
" - It will *always* be called on the line that we want to merge
"   onto.  E.g.:
"
"   > i eat   <<<<< called from here (i.e. a:firstline will be this line)
"   apples
"
" - The user will supply the range to operate over.
"
function! s:QuoteMangledMerge() range
    " make sure starting line is sensible
    if a:firstline == line("$")
        return
    endif
    if a:firstline == a:lastline
        return
    endif

    " make sure we have something to work with
    let qfirst = s:QuoteGetDpth(a:firstline)
    if 0 == qfirst
        return
    endif

    " This loop:
    " - assumes that the current line is what the lines below will merge onto
    let cur = a:firstline
    let next = cur + 1
    let lastline = a:lastline
    while cur < line("$") && cur < lastline
        let qlcur  = s:QuoteGetDpth(cur)
        let qlnext = s:QuoteGetDpth(next)

        " make sure our definition of mangled isn't invalidated
        if qlcur <= qlnext
            let cur  = cur + 1
            let next = cur + 1
            continue
        endif

        " remove the quotes on the merged line
        let newline = getline(next)
        let newline = substitute(newline, s:quote_block_re, '', '')

        " we only do *basic* extra formatting
        if -1 == match(newline, '^\s') && -1 == match(getline(cur), '\s$')
            let newline = " " . newline
        endif

        " merge the lines
        call setline(cur, (getline(cur) . newline))
        exe next . "," . next "normal! dd"

        " we don't increase cur here b/c there might be more lines to merge
        " into cur
        let lastline = lastline - 1
    endwhile
endfunction

" QuoteDelEmpty {{{2
" Replace empty quoted lines (e.g. "> ab% ") with empty lines (convenient to
" automatically reformat one paragraph).
"
" This routine is a bit more complicated than necessary.  This is so that the
" headers won't be deleted (if the user includes ':' in quote_chars).
"
" TODO: make this function to not move the cursor
"
function! s:QuoteDelEmpty() range
    let empty_quote  = s:quote_block_re . '\s*$'
    let whole_buffer = (1 == a:firstline) && (line("$") == a:lastline)

    "
    " make sure we never operate on headers
    "
    normal gg
    if 0 == search('^$', 'W')
        " if there are no headers, then they aren't really a problem...
        let end_headers = a:firstline
    else
        let end_headers = line(".")
    endif

    " this checks to see if we were called on the header portion of the email.
    " headers are a problem if the user has ':' in s:quote_chars.
    "
    " however, if the user wants the whole buffer to operate on we'll ignore
    " the starting position
    if a:firstline < end_headers && !whole_buffer
        " restore starting position
        exe "normal! " . a:firstline . 'gg'
        return
    endif

    " start search at most sensible place
    if whole_buffer
        exe "normal! " . end_headers . 'gg'
    else
        exe "normal! " . a:firstline . 'gg'
    endif

    let line = line(".")
    while line <= a:lastline
        if -1 != match (getline(line), empty_quote)
            let newline = substitute(getline(line), empty_quote, '', '')
            call setline(line, newline)
        endif
        let line = line + 1
    endwhile

    " restore starting position
    exe "normal! " . a:firstline . 'gg'
endfunction

" QuoteFixupSpaces {{{2
" This routine will turn all quotes that don't have spaces into ones that do.
"
" It is possible to specify when the quote fixation will stop.  This is
" possible in two ways.  The first is by using a visual range of 2 or more
" lines.  The second is by calling this routine with a range of 1 line (e.g.
" from normal mode) and passing in an argument for QuoteLenSgmt.
"
function! s:QuoteFixupSpaces(chg) range
    let line = a:firstline
    let first_quote = '^' . s:quote_mark_re

    " figure out our quote segment length
    if a:firstline == a:lastline
        let len = s:QuoteLenSgmt (line, a:chg)
        if 0 == len
            return
        endif
    else
        let len = a:lastline - a:firstline + 1
    endif

    while 0 < len
        let quote_block = matchstr(getline(line), s:quote_block_re)
        if "" == quote_block
            break
        endif

        " parse through all the quote_marks and add spaces as necessary
        let new_quote_block = ""
        let change = "no"
        while -1 != match(quote_block, first_quote)
            let quote_mark  = matchstr(quote_block, first_quote)
            let quote_block = substitute(quote_block, first_quote, '', '')
            if -1 != match(quote_mark, '\s$')
                let new_quote_block = new_quote_block . quote_mark
            else
                let new_quote_block = new_quote_block . quote_mark . " "
                let change = "yes"
            endif
        endwhile

        " put our new quote_block in
        if "yes" == change
            let newline = substitute(getline(line), s:quote_block_re, '', '')
            call setline (line, (new_quote_block . newline))
        endif

        let line = line + 1
        let len  = len  - 1
    endwhile
endfunction

" QuoteMotion {{{2
" This routine will output a motion command that operatates over a quote
" segment.  It is possible to dictate how the routine knows when a quote
" segment stops.  This is by passing in an argument suitable for use by
" s:QuoteGetDpth.
"
" This makes it possible to perform vi commands on quotes.
" E.g:
"   dq  => delete an entire quote section
"   gqq => format an entire quote section
"
function! s:QuoteMotion(line, chg)
    let len = s:QuoteLenSgmt(a:line, a:chg)
    if 0 == len
        return 0
    endif

    " the 'V' makes the motion linewise
    if 1 == len
        return "V" . line(".") . "G"
    else
        return "V" . (len - 1) . "j"
    endif
endfunction

" QuoteLenSgmt {{{2
" This tries to figure out how long a particular quote segment lasts.  It is
" possible to dictate how the routine knows when a quote segment stops.  This
" is done by passing in an argument suitable for use by s:QuoteGetDpth.
"
" E.g.:
"   % ab> apple        <<< called here
"   % ab> two
"   % ab> orange
"   % ab> > NO!
"   %
"   % yeah, I agree
"
"   will return 3 if passed
"
function! s:QuoteLenSgmt(start, chg)
    let depth = s:QuoteGetDpth(a:start)

    let i = a:start + 1
    let len = 1

    " find end of quote
    while i <= line('$')
        if "inc_or_dec" == a:chg
            if depth != s:QuoteGetDpth(i)
                break
            endif
        elseif "dec" == a:chg
            if depth > s:QuoteGetDpth(i)
                break
            endif
        endif

        let i   = i   + 1
        let len = len + 1
    endwhile

    return len
endfunction

" QuoteGetDpth {{{2
" This routine will try and return the quote depth for a particular line.
"
" e.g.: (the return value for this routine is in ())
" (3) > > ab% hi bob
" (3) > > ab% i hate you
" (2) > > :) I hate myself
"
function! s:QuoteGetDpth(line)
    let string = getline(a:line)

    if "" == string
        return 0
    endif

    let quote_depth = 0
    let quote = '^' . s:quote_mark_re
    while -1 != match(string, quote)
        let quote_depth = quote_depth + 1
        let string = substitute(string, quote, '', '')
    endwhile

    return quote_depth
endfunction

" Tofu {{{2
function! s:Tofu()
    call cursor(1,1)
    call search('^> ')
    if 1 < line(".")
        .,/\v(^$)|(%$)/!sed -e 's/^> //' | t-prot --body -ck --max-lines=250 -l -L$XDG_CONFIG_HOME/t-prot/footers -a -A$XDG_CONFIG_HOME/t-prot/ads | sed -e 's/^/> /'
    endif
endfunction

" FormatQuotes {{{2
function! s:FormatQuotes()
    call cursor(1, 1)
    call search('^> ')
    normal gqip
endfunction

" CursorStart {{{2
" Moves the cursor to a 'sensible' position.
function! s:CursorStart()
    call cursor(1, 1)

    " for 'autoedit'/'fast_reply'
    if search('^From: $', 'W')
    elseif search('^To: $', 'W')
    elseif search('^Subject: $', 'W')

    elseif search('^$', 'W')
    endif
endfunction

" Execute everything {{{1

setlocal tw=72
setlocal completefunc=LBDBCompleteFn

call s:QuoteEraseSig()

call s:Tofu()

" Replace trailing spaces except after mail headers (To:,
" etc.) or a signature delimiter (-- ).
silent! %s/\(^\([a-zA-z-]\+:\|--\)\)\@<!\s\+$//

" Remove spaces between quotes (> > to >>).
silent! %s/^\(>\+\) >/\1>/g
silent! %s/^\(>\+\) >/\1>/g

"call s:FormatQuotes() " doesn't work with pre-formatted text

"%call s:QuoteDelEmpty()

call s:CursorStart()

nohlsearch

" vim:tw=78 foldmethod=marker foldenable
