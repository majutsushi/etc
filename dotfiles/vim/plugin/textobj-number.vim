" From https://github.com/sjl/dotfiles/blob/master/vim/vimrc#L1415-1583
" Numbers {{{

" Motion for numbers.  Great for CSS.  Lets you do things like this:
"
" margin-top: 200px; -> daN -> margin-top: px;
"              ^                          ^
" TODO: Handle floats.

onoremap N :<c-u>call <SID>NumberTextObject(0)<cr>
xnoremap N :<c-u>call <SID>NumberTextObject(0)<cr>
onoremap aN :<c-u>call <SID>NumberTextObject(1)<cr>
xnoremap aN :<c-u>call <SID>NumberTextObject(1)<cr>
onoremap iN :<c-u>call <SID>NumberTextObject(1)<cr>
xnoremap iN :<c-u>call <SID>NumberTextObject(1)<cr>

function! s:NumberTextObject(whole)
    let num = '\v[0-9]'

    echomsg getline('.')[col('.') - 1]
    " If the current char isn't a number, walk forward.
    while getline('.')[col('.') - 1] !~# num
        normal! l
    endwhile

    " Now that we're on a number, start selecting it.
    normal! v

    " If the char after the cursor is a number, select it.
    while getline('.')[col('.')] =~# num
        normal! l
    endwhile

    " If we want an entire word, flip the select point and walk.
    if a:whole
        normal! o

        while col('.') > 1 && getline('.')[col('.') - 2] =~# num
            normal! h
        endwhile
    endif
endfunction

" }}}
