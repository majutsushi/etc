" functions.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-15.
" @Last Change: 2007-09-15.
" @Revision:    0.0.4

if &cp || exists("loaded_tskeleton_functions_autoload")
    finish
endif
let loaded_tskeleton_functions_autoload = 1


function! tskeleton#functions#Initialize() "{{{3
endf


function! tskeleton#functions#FiletypeBits_vim(dict, filetype) "{{{3
    " TAssert IsDictionary(a:dict)
    " TAssert IsString(a:filetype)
    let fnl = tlib#cmd#OutputAsList('fun')
    call map(fnl, 'matchstr(v:val, ''^\S\+\s\+\zs.\+$'')')
    call filter(fnl, 'v:val[0:4] != ''<SNR>''')
    for f in sort(fnl)
        let fn = matchstr(f, '^.\{-}\ze(')
        let fr = substitute(f, '(\(.\{-}\))$', '\=tskeleton#ReplacePrototypeArgs(submatch(1), ''\V...'')', "g")
        " TLogDBG fn ." -> ". fr
        let a:dict[fn] = {'text': fr, 'menu': 'Function.'. fn, 'type': 'tskeleton'}
    endfor
endf


