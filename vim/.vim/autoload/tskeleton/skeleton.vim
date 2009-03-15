" skeleton.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-15.
" @Last Change: 2007-10-26.
" @Revision:    0.0.20

if &cp || exists("loaded_tskeleton_skeleton_autoload")
    finish
endif
let loaded_tskeleton_skeleton_autoload = 1


function! tskeleton#skeleton#Initialize() "{{{3
endf

function! tskeleton#skeleton#FiletypeBits(dict, type) "{{{3
    " TAssert IsDictionary(a:dict)
    " TAssert IsString(a:type)
    call tskeleton#FetchMiniBits(a:dict, g:tskelBitsDir . a:type .'.txt', 0)
    let bf = tskeleton#GlobBits(g:tskelBitsDir . a:type .'/', 2)
    " let cx = tskeleton#CursorMarker('rx')
    " let cm = tskeleton#CursorMarker()
    for f in bf
        " TLogVAR f
        if !isdirectory(f) && filereadable(f)
            let fname = fnamemodify(f, ":t")
            let [cname, mname] = tskeleton#PurifyBit(fname)
            let body = join(readfile(f), "\n")
            let [body, meta] = tskeleton#ExtractMeta(body)
            " if body !~ cx
            "     let body .= cm
            " endif
            if has_key(meta, 'menu') && !empty(meta.menu)
                let mname = meta.menu
            endif
            let a:dict[cname] = {'text': body, 'menu': mname, 'meta': meta, 'bitfile': f, 'type': 'tskeleton'}
        endif
    endfor
endf


