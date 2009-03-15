" mail FTplugin
"
" Requires vim 6.x.
" To install place in ~/.vim/after/ftplugin/mail.vim
"
" Author: Brian Medley
" Email:  freesoftware@4321.tv
"
" Version:
"   $Revision: 1.9 $
"   $Date: 2003/11/06 04:18:00 $
"   $Source: /Users/bpm/.vim/after/ftplugin/RCS/mail.vim,v $
"
" This file was modified from Cedric Duval's version.
" http://cedricduval.free.fr/download/vimrc/mail
"

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin_after")
  finish
endif
let b:did_ftplugin_after = 1

" ====================================================================
"                               Globals
" ====================================================================

if exists ("g:mail_alias_source")
    let s:alias_source = g:mail_alias_source
else
    let s:alias_source = "MuttAlias"
endif

if exists ("g:mail_mutt_alias_file")
    let s:mutt_alias_file = g:mail_mutt_alias_file
else
    let s:mutt_alias_file = "~/.mutt/aliases"
endif

if exists ("g:mail_mutt_query_command")
    let s:mail_mutt_query_command = g:mail_mutt_query_command
else
    let s:mail_mutt_query_command = "mutt_ldap_query.pl"
endif

if exists ("g:mail_quote_chars")
    let s:quote_chars = g:mail_quote_chars
else
    let s:quote_chars = '|>}#%'
endif

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

" For debugging:
" let b:quote_chars = s:quote_chars
" let b:quote_mark_re = s:quote_mark_re
" let b:quote_block_re = s:quote_block_re

"
" Allow the user to specify how their quote motions operate
"
if exists ("g:mail_quote_motion1")
    let s:quote_motion1 = g:mail_quote_motion1
else
    let s:quote_motion1 = "inc_or_dec"
endif

if exists ("g:mail_quote_motion2")
    let s:quote_motion2 = g:mail_quote_motion2
else
    let s:quote_motion2 = "dec"
endif

if exists ("g:mail_quote_motion3")
    let s:quote_motion3 = g:mail_quote_motion3
else
    let s:quote_motion3 = "inc"
endif

"
" Variable that allows us to keep track of where each module is located
"
let s:ModuleSids = ""

" ====================================================================
"                               Mappings
" ====================================================================

if !exists("no_plugin_maps") && !exists("no_mail_after_maps")

    "
    " get alias list mappings
    "
    if !hasmapto('<Plug>MailAliasList', 'n')
        nmap <buffer> <unique> <LocalLeader>al  <Plug>MailAliasList
    endif
    if !hasmapto('<Plug>MailAliasList', 'i')
        imap <buffer> <unique> <LocalLeader>al  <Plug>MailAliasList
    endif

    nnoremap <buffer> <unique> <script> <Plug>MailAliasList <SID>AliasList
    inoremap <buffer> <unique> <script> <Plug>MailAliasList <SID>AliasList

    " Redraw is there b/c my screen was messed up after abook finished.
    " The 'set paste' is in the function b/c I couldn't figure out how to put it in
    "   the mapping.
    " The 'set nopaste' is in the mapping b/c it didn't work for me in the script.
    nnoremap <buffer> <SID>AliasList i<c-r>=<SID>AliasList()<cr><c-o>:set nopaste<cr><c-o>:redraw!<cr><c-o>:echo b:AliasListMsg<cr><esc>
    inoremap <buffer> <SID>AliasList  <c-r>=<SID>AliasList()<cr><c-o>:set nopaste<cr><c-o>:redraw!<cr><c-o>:echo b:AliasListMsg<cr>

    "
    " get alias query mappings
    "
    if !hasmapto('<Plug>MailAliasQuery', 'n')
        nmap <buffer> <unique> <LocalLeader>aq  <Plug>MailAliasQuery
    endif
    if !hasmapto('<Plug>MailAliasQuery', 'i')
        imap <buffer> <unique> <LocalLeader>aq  <Plug>MailAliasQuery
    endif

    nnoremap <buffer> <unique> <script> <Plug>MailAliasQuery <SID>AliasQuery
    inoremap <buffer> <unique> <script> <Plug>MailAliasQuery <SID>AliasQuery

    nnoremap <buffer> <SID>AliasQuery      :call <SID>AliasQuery()<cr>:echo b:AliasQueryMsg<cr>
    inoremap <buffer> <SID>AliasQuery <c-o>:call <SID>AliasQuery()<cr><c-o>:echo b:AliasQueryMsg<cr><right>

    "
    " mail formatting mappings
    "

    " The user provides the actual mappings for these.

    nnoremap <buffer> <unique> <script> <Plug>MailFormatQuote     <SID>FormatQuote
    nnoremap <buffer> <unique> <script> <Plug>MailFormatLine      <SID>FormatLine
    nnoremap <buffer> <unique> <script> <Plug>MailFormatMerge     <SID>FormatMerge
    nnoremap <buffer> <unique> <script> <Plug>MailFormatParagraph <SID>FormatParagraph
    inoremap <buffer> <unique> <script> <Plug>MailFormatQuote     <SID>FormatQuote
    inoremap <buffer> <unique> <script> <Plug>MailFormatLine      <SID>FormatLine
    inoremap <buffer> <unique> <script> <Plug>MailFormatMerge     <SID>FormatMerge
    inoremap <buffer> <unique> <script> <Plug>MailFormatParagraph <SID>FormatParagraph

    nnoremap <buffer> <script> <SID>FormatQuote     gq<SID>QuoteMotion1j
    nnoremap <buffer>          <SID>FormatLine      gqqj
    nnoremap <buffer>          <SID>FormatMerge     kgqj
    nnoremap <buffer>          <SID>FormatParagraph gqap
    inoremap <buffer> <script> <SID>FormatQuote     <ESC>gq<SID>QuoteMotion1ji
    inoremap <buffer>          <SID>FormatLine      <ESC>gqqji
    inoremap <buffer>          <SID>FormatMerge     <ESC>kgqji
    inoremap <buffer>          <SID>FormatParagraph <ESC>gqapi

    "
    " Quote Function Mappings
    "
    if !hasmapto('<Plug>MailQuoteEraseSig', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qes <Plug>MailQuoteEraseSig
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteEraseSig <SID>QuoteEraseSig
    nnoremap <buffer> <SID>QuoteEraseSig :call <SID>QuoteEraseSig()<CR>

    "                           -----------------

    if !hasmapto('<Plug>MailQuoteFixupSpaces', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qfs <Plug>MailQuoteFixupSpaces
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteFixupSpaces <SID>QuoteFixupSpaces
    nnoremap <buffer> <SID>QuoteFixupSpaces :call <SID>QuoteFixupSpaces("quote_motion1")<cr>

    if !hasmapto('<Plug>MailQuoteFixupSpaces', 'v')
        vmap <silent> <buffer> <unique> <LocalLeader>qfs <Plug>MailQuoteFixupSpaces
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteFixupSpaces <SID>QuoteFixupSpaces
    vnoremap <buffer> <SID>QuoteFixupSpaces :call <SID>QuoteFixupSpaces("visual")<cr>

    "                           -----------------

    if !hasmapto('<Plug>MailQuoteMangledMerge', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qmm <Plug>MailQuoteMangledMerge
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteMangledMerge <SID>QuoteMangledMerge
    nnoremap <buffer> <SID>QuoteMangledMerge :.,.+1call <SID>QuoteMangledMerge()<cr>

    if !hasmapto('<Plug>MailQuoteMangledMerge', 'v')
        vmap <silent> <buffer> <unique> <LocalLeader>qmm <Plug>MailQuoteMangledMerge
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteMangledMerge <SID>QuoteMangledMerge
    vnoremap <buffer> <SID>QuoteMangledMerge :call <SID>QuoteMangledMerge()<cr>

    "                           -----------------

    if !hasmapto('<Plug>MailQuoteDelEmpty', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qde <Plug>MailQuoteDelEmpty
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteDelEmpty <SID>QuoteDelEmpty
    nnoremap <buffer> <SID>QuoteDelEmpty :%call <SID>QuoteDelEmpty()<cr>

    if !hasmapto('<Plug>MailQuoteDelEmpty', 'v')
        vmap <silent> <buffer> <unique> <LocalLeader>qde <Plug>MailQuoteDelEmpty
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteDelEmpty <SID>QuoteDelEmpty
    vnoremap <buffer> <SID>QuoteDelEmpty :call <SID>QuoteDelEmpty()<CR>

    "                           -----------------

    if !hasmapto('<Plug>MailQuoteRemoveDpth', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>qrd <Plug>MailQuoteRemoveDpth
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailQuoteRemoveDpth <SID>QuoteRemoveDpth
    nnoremap <buffer> <SID>QuoteRemoveDpth :call <SID>QuoteRemoveDpth("quote_motion1")<cr>

    if !hasmapto('<Plug>MailQuoteRemoveDpth', 'v')
        vmap <silent> <buffer> <unique> <LocalLeader>qrd <Plug>MailQuoteRemoveDpth
    endif
    vnoremap <buffer> <unique> <script> <Plug>MailQuoteRemoveDpth <SID>QuoteRemoveDpth
    vnoremap <buffer> <SID>QuoteRemoveDpth :call <SID>QuoteRemoveDpth("visual")<cr>

    "                           -----------------

    "
    " Provide a motion operator for commands (so you can delete a quote
    " segment, or format quoted segment)
    "
    if !hasmapto('<Plug>MailQuoteMotion1', 'o')
        omap <silent> <buffer> <unique> q <Plug>MailQuoteMotion1
    endif
    onoremap <buffer> <unique> <script> <Plug>MailQuoteMotion1 <SID>QuoteMotion1
    onoremap <buffer> <script> <SID>QuoteMotion1 :execute "normal!" . <SID>QuoteMotion(line("."), "quote_motion1")<cr>

    if hasmapto('<Plug>MailQuoteMotion2', 'o')
        " ounmap Q
        " omap <silent> <unique> Q <Plug>MailQuoteMotion2
        onoremap <buffer> <unique> <script> <Plug>MailQuoteMotion2 <SID>QuoteMotion2
        onoremap <buffer> <script> <SID>QuoteMotion2 :execute "normal!" . <SID>QuoteMotion(line("."), "quote_motion2")<cr>
    endif

    if hasmapto('<Plug>MailQuoteMotion3', 'o')
        " omap <silent> <unique> x <Plug>MailQuoteMotion3
        onoremap <buffer> <unique> <script> <Plug>MailQuoteMotion3 <SID>QuoteMotion3
        onoremap <buffer> <script> <SID>QuoteMotion3 :execute "normal!" . <SID>QuoteMotion(line("."), "quote_motion3")<cr>
    endif

    " Debugging:
    nnoremap <buffer> <script> <LocalLeader>d :call <SID>EchoDebug("<SID>")<cr>

endif

if !exists ("*s:EchoDebug")
function s:EchoDebug(sid)
    echo "<SID>: " . a:sid
    echo "\n"

    echo "user vars:"
    if exists("g:mail_quote_chars")
        echo "g:mail_quote_chars (user): " . g:mail_quote_chars
    else
        echo "g:mail_quote_chars (not set)"
    endif

    if exists("g:mail_quote_mark_re")
        echo "g:mail_quote_mark_re (user): " . g:mail_quote_mark_re
    else
        echo "g:mail_quote_mark_re (not set)"
    endif

    if exists("g:mail_alias_source")
        echo "g:mail_alias_source (user): " . g:mail_alias_source
    else
        echo "g:mail_alias_source (not set)"
    endif

    if exists("g:mail_mutt_alias_file")
        echo "g:mail_mutt_alias_file (user): " . g:mail_mutt_alias_file
    else
        echo "g:mail_mutt_alias_file (not set)"
    endif

    if exists("g:mail_quote_motion1")
        echo "g:mail_quote_motion1 (user): " . g:mail_quote_motion1
    else
        echo "g:mail_quote_motion1 (not set)"
    endif

    if exists("g:mail_quote_motion2")
        echo "g:mail_quote_motion2 (user): " . g:mail_quote_motion2
    else
        echo "g:mail_quote_motion2 (not set)"
    endif

    if exists("g:mail_quote_motion3")
        echo "g:mail_quote_motion3 (user): " . g:mail_quote_motion3
    else
        echo "g:mail_quote_motion3 (not set)"
    endif

    if exists("g:mail_erase_quoted_sig")
        echo "g:mail_erase_quoted_sig (set): " . g:mail_erase_quoted_sig
    else
        echo "g:mail_erase_quoted_sig (not set)"
    endif

    if exists("g:mail_delete_empty_quoted")
        echo "g:mail_delete_empty_quoted (set): " . g:mail_delete_empty_quoted
    else
        echo "g:mail_delete_empty_quoted (not set)"
    endif

    if exists("g:mail_generate_abbrev")
        echo "g:mail_generate_abbrev (set): " . g:mail_generate_abbrev
    else
        echo "g:mail_generate_abbrev (not set)"
    endif

    if exists("g:mail_cursor_start")
        echo "g:mail_cursor_start (set): " . g:mail_cursor_start
    else
        echo "g:mail_cursor_start (not set)"
    endif

    echo "\n"

    echo "script vars:"
    echo "s:alias_source: "          . s:alias_source
    echo "s:mutt_alias_file: "       . s:mutt_alias_file
    echo "s:mail_mutt_query_command" . s:mail_mutt_query_command
    echo "s:quote_chars: "           . s:quote_chars
    echo "s:quote_mark_re: "         . s:quote_mark_re
    echo "s:quote_block_re: "        . s:quote_block_re
    echo "s:quote_motion1: "         . s:quote_motion1
    echo "s:quote_motion2: "         . s:quote_motion2
    echo "s:quote_motion3: "         . s:quote_motion3
endfunction
endif

" ====================================================================
"                     Mail Manipulation Functions
" ====================================================================

" --------------------------------------------------------------------
"                          Manipulate Quotes
" --------------------------------------------------------------------

"
" Description:
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
if !exists("*s:QuoteEraseSig")
function s:QuoteEraseSig()
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
endif

"
" Description:
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
if !exists("*s:QuoteMangledMerge")
function s:QuoteMangledMerge() range
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
endif

"
" Description:
" Replace empty quoted lines (e.g. "> ab% ") with empty lines (convenient to
" automatically reformat one paragraph).
"
" This routine is a bit more complicated than necessary.  This is so that the
" headers won't be deleted (if the user includes ':' in quote_chars).
"
" TODO: make this function to not move the cursor
"
if !exists("*s:QuoteDelEmpty")
function s:QuoteDelEmpty() range
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
endif

"
" Description:
" This routine will try and decrease the quote depth of a quote segment by
" one.  However, it will remove the *last* layer of quoting.  This is b/c it
" is assumed that the user wants the *oldest* quote to be gone.
"
" It is possible to specify when the quote removal will stop.  This is
" possible in two ways.  The first is by using a visual range of 2 or more
" lines.  The second is by calling this routine with a range of 1 line (e.g.
" from normal mode) and passing in an argument for QuoteLenSgmt.
"
" e.g. (if we were passed "inc_or_dec" in chg):
"
"   ab> % > I really
"   ab> % > like
"   ab> % > apples
"   ab> % > > yup
"   ab> % hello
"
"   ab> % lala
"
" will become
"
"   ab> % I really
"   ab> % like
"   ab> % apples
"   ab> % > > yup
"   ab> % hello
"
"   ab> % lala
"
if !exists("*s:QuoteRemoveDpth")
function s:QuoteRemoveDpth(chg) range
    let line         = a:firstline
    let remove_quote = s:quote_mark_re . '$'

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
        " first we whip of the oldest quote_mark from the quote_block
        let newquote = matchstr(getline(line), s:quote_block_re)
        let newquote = substitute(newquote, remove_quote, '', '')

        " then we remove the old quote_block and add on the new one
        let newline = substitute(getline(line), s:quote_block_re, '', '')
        let newline = newquote . newline
        call setline(line, newline)

        let line = line + 1
        let len  = len  - 1
    endwhile
endfunction
endif

"
" Description:
" This routine will turn all quotes that don't have spaces into ones that do.
"
" It is possible to specify when the quote fixation will stop.  This is
" possible in two ways.  The first is by using a visual range of 2 or more
" lines.  The second is by calling this routine with a range of 1 line (e.g.
" from normal mode) and passing in an argument for QuoteLenSgmt.
"
if !exists("*s:QuoteFixupSpaces")
function s:QuoteFixupSpaces(chg) range
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
endif

"
" Description:
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
if !exists("*s:QuoteMotion")
function s:QuoteMotion(line, chg)
    if "dec" != a:chg && "inc_or_dec" != a:chg && "inc" != a:chg
        exe "let chg = s:" . a:chg
    else
        let chg = a:chg
    endif
        
    let len = s:QuoteLenSgmt(a:line, chg)
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
endif

"
" Description:
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
if !exists("*s:QuoteLenSgmt")
function s:QuoteLenSgmt(start, chg)
    let depth = s:QuoteGetDpth(a:start)

    let i = a:start + 1
    let len = 1

    " find end of quote
    while i <= line('$')
        if "inc_or_dec" == a:chg
            if depth != s:QuoteGetDpth(i)
                break
            endif
        elseif "inc" == a:chg
            if depth < s:QuoteGetDpth(i)
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
endif

"
" Description:
" This routine will try and return the quote depth for a particular line.
"
" e.g.: (the return value for this routine is in ())
" (3) > > ab% hi bob
" (3) > > ab% i hate you
" (2) > > :) I hate myself
"
if !exists("*s:QuoteGetDpth")
function s:QuoteGetDpth(line)
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
endif

" --------------------------------------------------------------------
"                    Location Manipulator Functions
" --------------------------------------------------------------------

"
" Description:
" Moves the cursor to a 'sensible' position.
"
if !exists("*s:CursorStart")
function s:CursorStart()
    " put cursor in known position
    silent normal gg

    if search('^From: $', 'W')
        silent startinsert!
    elseif search('^To: $', 'W')
        silent startinsert!
    elseif search('^Subject: $', 'W')
        silent startinsert!

    " check if we are editing a reply
    " TODO: let use specify their salutation
    elseif search('^On.*wrote:', 'W')
        normal 2j

    elseif search('^$', 'W')
        normal j
        silent startinsert!
    endif
endfunction
endif

" ================================================
"               Process Mutt Aliases
" ================================================

" ------------------------------------------------
"                  Get Email List
" ------------------------------------------------

"
" Description:
" This is a wrapper routine to be conistent with the way queries work.
"
if !exists("*s:AliasList")
function s:AliasList()
    let func = s:FindFunction("AliasList" . s:alias_source)

    " Debugging
    let b:AliasList = "func: " . func

    if "" == func
        let b:AliasListMsg = "Function not found: AliasList" . s:alias_source
        return ""
    endif

    exe "return " . func . '()'
endfunction
endif

" ------------------------------------------------
"                 Get Email Query
" ------------------------------------------------

"
" Description:
" This is a wrapper routine to make sure that 'iskeyword' has "-" in it.
"
if !exists("*s:AliasQuery")
function s:AliasQuery()
    let func = s:FindFunction("AliasQuery" . s:alias_source)

    " Debugging
    let b:AliasQuery = "func: " . func

    if "" == func
        let b:AliasQueryMsg = "Function not found: AliasQuery" . s:alias_source
        return ""
    endif

    let userisk = &iskeyword
    set iskeyword+=-
    exe "return " . func . '()'
    let &iskeyword = userisk
endfunction
endif

" --------------------------------------------------------------------
"                          Utility Functions
" --------------------------------------------------------------------

" 
" Description:
" This routine allows loaded modules to access our script variables.
" 
if !exists("*s:ScriptVar")
function s:ScriptVar(var)
    let var = "s:" . a:var

    exe "return " . var
endfunction
endif

" 
" Description:
" This routine allows modules to register so that they can be called in a
" general fashion.
"
if !exists("*s:RegisterModule")
function s:RegisterModule(sid)
    if "" == s:ModuleSids
        let s:ModuleSids = a:sid
    else
        let s:ModuleSids = s:ModuleSids . '¬' . a:sid
    endif

    " Debugging
    " echo s:ModuleSids
endfunction
endif

"
" Description:
" This routine will find a function registered with us.
"
if !exists("*s:FindFunction")
function s:FindFunction(name)
    " Debugging
    " echo a:name
    " let b = input ("a")
    return matchstr(s:ModuleSids, '\(<SNR>\d\+_\)' . a:name . '\(¬\|$\)\@=')
endfunction
endif


"
" Description:
" This routine will replace the word under the cursor.
"
" paste is set/unset so that the email addresses aren't "mangled" by the
" user's formating options
"
if !exists("*s:ReplaceWord")
function s:ReplaceWord(replacement)
    set paste
    exe "normal! ciw" . a:replacement . "\<Esc>"
    set nopaste
endfunction
endif

"
" Description:
" This routine will take the output of a "mutt query" (as defined by the mutt
" documenation) and parses it.
"
" It returns the email addresses formatted as follows:
" - each address is on a line
"
if !exists("*s:ParseMuttQuery")
function s:ParseMuttQuery(aliases)
    " remove first informational line
    let aliases   = substitute (a:aliases, ".\\{-}\n", "", "")
    let expansion = ""

    while 1
        " whip off the name and address
        let line    = matchstr(aliases, ".\\{-}\n")
        let address = matchstr(line, ".\\{-}\t")
        let address = substitute(address, "\t", "", "g")
        if "" == address
            let b:ParseMuttQueryErr = "Unable to parse address from ouput"
            return ""
        endif

        let name = matchstr(line, "\t.*\t")
        let name = substitute(name, "\t", "", "g")
        if "" == name
            let b:ParseMuttQueryErr = "Unable to parse name from ouput"
            return ""
        endif

        " debugging:
        " echo "line: " . line . "|"
        " echo "address: " . address . "|"
        " echo "name: " . name . "|"
        " let a=input("hit enter")

        " make into valid email address
        let needquote = match (name, '"')
        if (-1 == needquote)
            let name = '"' . name    . '" '
        endif

        let needquote = match (address, '<')
        if (-1 == needquote)
            let address = '<' . address . '>'
        endif

        " add email address to list
        let expansion = expansion . name
        let expansion = expansion . address

        " debugging:
        " echo "address: " . address . "|"
        " echo "name: " . name . "|"
        " let a=input("hit enter")

        " process next line (if there is one)
        let aliases = substitute(aliases, ".\\{-}\n", "", "")
        if "" == aliases
            let b:ParseMuttQueryErr = ""
            return expansion
        endif

        let expansion = expansion . "\n"
    endwhile
endfunction
endif

" --------------------------------------------------------------------
"                      Abbreviation Manipulation
" --------------------------------------------------------------------

"
" Description:
" This will generate vi abbreviations from your mutt alias file.
"
" Note:
" However, remember that the abbreviation will be replaced *everywhere*.  For
" example, if you have the alias 'Mary', then if you try and type "Hi, Mary
" vim is cool", then it won't work.  This is because the 'Mary' will be
" expanded as an alias.
"
if !exists("*s:MakeAliasAbbrev")
function s:MakeAliasAbbrev()
    let aliasfile = tempname()
    " get rid of comments (which could be confused w/ cpp directives) and run
    " thourgh cpp to take care of line continuation
    let cmd = "!sed 's/\\#.*//' " . s:mutt_alias_file . " | cpp | "
    " get rid of 'stuff' added on by cpp
    let cmd = cmd . "sed -e 's/\\#.*//' "
    
    " this next part takes care of potentionally invalid abbrevation
    " characters.  by default '.' and '-' are not a vim keyword (:help 'isk'),
    " so they need to be removed from the alias file so that errros are not
    " generated.  however, if the user has included them in modified 'isk',
    " then appropriate abbrevations should be generated.
    let invld = "\\("
    if -1 == match(&iskeyword, "\\(,\\|^\\)\\.")
        let invld = invld . "\\."
    endif
    if -1 == match(&iskeyword, "\\(,\\|^\\)-")
        if "\\(" != invld
            let invld = invld . "\\|"
        endif
        let invld = invld . "-"
    endif
    let invld = invld . "\\)"
    if "\\(\\)" != invld
        let cmd = cmd . "-e 's/alias[\t ]*[a-zA-Z0-9]*" . invld . "[a-zA-Z0-9]*[\t ].*//' "
    endif

    " generate the vim cmds
    let cmd = cmd . "-e 's/alias/iab/' > " . aliasfile
    silent exe cmd
    exe "source " . aliasfile
endfunction
endif


" ====================================================================
"                           Initializations
" ====================================================================

" load the modules
let modules = glob(expand("<sfile>:p:h") . "/mail*.mod")
"let modules = glob(expand("%:p:h") . "/mail*.mod")
let modules = substitute(modules, "\\(^\\|\n\\)", "\\1source ", "g") "syntax highlight bug
exe modules
unlet modules

if exists ("g:mail_erase_quoted_sig")
    call s:QuoteEraseSig()
endif

if exists ("g:mail_delete_empty_quoted")
    %call s:QuoteDelEmpty()
endif

if exists ("g:mail_generate_abbrev")
    call s:MakeAliasAbbrev()
endif

if exists ("g:mail_cursor_start")
    call s:CursorStart()
endif

" vim:ts=4:et:sw=4:sts=4
