" Original sources:
" http://learnvimscriptthehardway.stevelosh.com/chapters/38.html
" https://github.com/jszakmeister/vimfiles/blob/master/vimrc

function! qftoggle#toggle() abort
    if qftoggle#islocwin()
        lclose
        return
    endif

    if qftoggle#islocwinopen()
        lclose
        if !s:quickfix_is_open
            return
        endif
    endif

    if s:quickfix_is_open
        cclose
        let s:quickfix_is_open = 0
        execute s:quickfix_return_to_window . "wincmd w"
    else
        call qftoggle#openqfwin()
    endif
endfunction

function! qftoggle#openqfwin() abort
    let s:quickfix_return_to_window = winnr()
    if &lines / 4 < 10
        botright copen 10
    else
        execute 'botright copen ' . &lines / 4
    endif
    let s:quickfix_is_open = 1
endfunction

function! qftoggle#isqfwin() abort
    if &buftype == 'quickfix'
        " This is either a QuickFix window or a Location List window.
        " Try to open a location list; if this window *is* a location list,
        " then this will succeed and the focus will stay on this window.
        " If this is a QuickFix window, there will be an exception and the
        " focus will stay on this window.
        try
            lopen
        catch /E776:/
            " This was a QuickFix window.
            return 1
        endtry
    endif
    return 0
endfunction

function! qftoggle#islocwin() abort
    return (&buftype == 'quickfix' && !qftoggle#isqfwin())
endfunction

" Return 1 if current window's location list window is open.
function! qftoggle#islocwinopen() abort
    let numOpenWindows = winnr("$")
    " Assume location list window is already open.
    let isOpen = 1
    try
        noautocmd lopen
    catch /E776:/
        " No location list available; nothing was changed.
        let isOpen = 0
    endtry
    if numOpenWindows != winnr("$")
        " We just opened a new location list window. Revert to original
        " window and close the newly opened window.
        noautocmd wincmd p
        noautocmd lclose
        let isOpen = 0
    endif
    return isOpen
endfunction

let s:quickfix_is_open = 0
