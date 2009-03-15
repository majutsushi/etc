" vikiLatex.vim -- viki add-on for LaTeX
" @Author:      Thomas Link (samul AT web.de)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     28-Jän-2004.
" @Last Change: 2007-06-07.
" @Revision:    0.178

if &cp || exists("s:loaded_vikiLatex")
    finish
endif
let s:loaded_vikiLatex = 1

fun! VikiSetupBufferLaTeX(state, ...)
    let noMatch = ""
    let b:vikiNameSuffix = '.tex'
    call VikiSetupBuffer(a:state, "sSic")
    let b:vikiAnchorRx   = '\\label{%{ANCHOR}}'
    let b:vikiNameTypes  = substitute(b:vikiNameTypes, '\C[Sicx]', "", "g")
    let b:vikiLaTeXCommands = 'viki\|include\|input\|usepackage\|psfig\|includegraphics\|bibliography\|ref'
    if exists("g:vikiLaTeXUserCommands")
        let b:vikiLaTeXCommands = b:vikiLaTeXCommands .'\|'. g:vikiLaTeXUserCommands
    endif
    if b:vikiNameTypes =~# "s"
        let b:vikiSimpleNameRx         = '\(\\\('. b:vikiLaTeXCommands .'\)\(\[\(.\{-}\)\]\)\?{\(.\{-}\)}\)'
        let b:vikiSimpleNameSimpleRx   = '\\\('. b:vikiLaTeXCommands .'\)\(\[.\{-}\]\)\?{.\{-}}'
        let b:vikiSimpleNameNameIdx    = 2
        let b:vikiSimpleNameDestIdx    = 5
        let b:vikiSimpleNameAnchorIdx  = 4
        let b:vikiSimpleNameCompound = 'let erx="'. escape(b:vikiSimpleNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiSimpleNameNameIdx
                    \ .' | let destIdx='. b:vikiSimpleNameDestIdx
                    \ .' | let anchorIdx='. b:vikiSimpleNameAnchorIdx
    else
        let b:vikiSimpleNameRx        = noMatch
        let b:vikiSimpleNameSimpleRx  = noMatch
        let b:vikiSimpleNameNameIdx   = 0
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 0
    endif
endf

fun! VikiLatexCheckFilename(filename, ...)
    if a:filename != ""
        """ search in the current directory
        let i = 1
        while i <= a:0
            let fn = a:filename .a:{i}
            " TLogVAR fn
            if filereadable(fn)
                return fn
            endif
            let i = i + 1
        endwh

        """ use kpsewhich
        let i = 1
        while i <= a:0
            let fn = a:filename .a:{i}
            let rv = system('kpsewhich '. string(fn))
            if rv != ""
                return substitute(rv, "\n", "", "g")
            endif
            let i = i + 1
        endwh
    endif
    return ""
endfun


fun! VikiCompleteSimpleNameDefLaTeX(def)
    exec VikiSplitDef(a:def)
    if v_name == g:vikiDefNil
        throw "Viki: Malformed command (no name): ". string(a:def)
    endif
    let opts = v_anchor
    let v_anchor  = g:vikiDefNil
    let useSuffix = g:vikiDefSep

    if v_name == "input"
        let v_dest = VikiLatexCheckFilename(v_dest, "", ".tex", ".sty")
    elseif v_name == "usepackage"
        let v_dest = VikiLatexCheckFilename(v_dest, ".sty")
    elseif v_name == "include"
        let v_dest = VikiLatexCheckFilename(v_dest, ".tex")
    elseif v_name == "viki"
        let v_dest = VikiLatexCheckFilename(v_dest, ".tex")
        let v_anchor = opts
    elseif v_name == "psfig"
        let f == matchstr(v_dest, "figure=\zs.\{-}\ze[,}]")
        let v_dest = VikiLatexCheckFilename(v_dest, "")
    elseif v_name == "includegraphics"
        let v_dest = VikiLatexCheckFilename(v_dest, "", 
                    \ ".eps", ".ps", ".pdf", ".png", ".jpeg", ".jpg", ".gif", ".wmf")
    elseif v_name == "bibliography"
        if !exists('b:vikiMarkingInexistent')
            let bibs = split(v_dest, ",")
            let n = tlib#InputList('si', "Select Bibliography", bibs)
            if n > 0
                let f      = bibs[n - 1]
                let v_dest = VikiLatexCheckFilename(f, ".bib")
            else
                let v_dest = ""
            endif
        endif
    elseif v_name == "ref"
        let v_anchor = v_dest
        let v_dest   = g:vikiSelfRef
    elseif exists("*VikiLaTeX_".v_name)
        exe VikiLaTeX_{v_name}(v_dest, opts)
    else
        throw "Viki LaTeX: unsupported command: ". v_name
    endif
    
    if v_dest == ""
        if !exists('b:vikiMarkingInexistent')
            throw "Viki LaTeX: can't find: ". v_name ." ". string(a:def)
        endif
    else
        return VikiMakeDef(v_name, v_dest, v_anchor, v_part, 'simple')
    endif
endfun

fun! VikiMinorModeLaTeX(state)
    let b:vikiFamily = "LaTeX"
    call VikiMinorMode(a:state)
endf

command! VikiMinorModeLaTeX call VikiMinorModeLaTeX(1)
" au FileType tex let b:vikiFamily="LaTeX"

" vim: ff=unix
