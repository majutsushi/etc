set laststatus=0
set foldcolumn=0
set showtabline=0
set nolist
set nonumber
" set noruler

set clipboard+=unnamedplus
set scrollback=100000
set termguicolors
set virtualedit=all

set ignorecase
set smartcase

function! s:stdin_terminal() abort
    let tmpfile = trim(system(["mktemp", "-t", "kitty-nvim-pager.XXXXXX"]))
    execute "silent write! " .. tmpfile
    execute "terminal cat " .. tmpfile .. "; rm " .. tmpfile .. "; cat"
endfunction
autocmd StdinReadPost * call s:stdin_terminal()

autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
autocmd TermEnter * stopinsert
" autocmd VimEnter * normal G

nmap q :qa!<CR>
nmap i <Nop>

highlight CurSearch ctermfg=0 ctermbg=2 guifg=Black guibg=LightGreen

augroup quickfix
    autocmd BufReadPost quickfix syntax match ConcealedDetails /\v^[^|]*\|[^|]*\| / conceal
    autocmd FileType qf setlocal conceallevel=2
    autocmd FileType qf setlocal concealcursor=nvic
    autocmd FileType qf setlocal nowrap
    autocmd FileType qf nmap <buffer> q :cclose<CR>
augroup END

" Populate the quickfix window with the last search
nnoremap <silent> g/ :execute 'vimgrep /' . @/ . '/j %'<CR>:copen<CR>
