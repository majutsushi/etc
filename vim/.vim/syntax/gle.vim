"TITLE=GLE
"
" This file is provided as a default syntax file for gle

syntax clear
syntax case ignore

"#DELIMITER=,(){}[]-+*%/="'~!&|\<>?:;.
"#QUOTATION1='
"#QUOTATION2="
"#CONTINUE_QUOTE=n
"#LINECOMMENT=!
"#ESCAPE=\
"#KEYWORD=reserved words
"syn keyword gleText text contained
"syn match gleString /text .*/ms=s+5 contains=gleText
syn region gleString matchgroup=gleText start="text " end="$" keepend
"contains=Text
"/^[ \t]*text .*/ms=s+5
syn match Comment /!.*/
syn keyword gleStatement add aline amove arc arcto asetpos arrow both arrow end arrow start bar begin bevel
syn keyword gleStatement bezier bigfile bigfile box butt cap center circle clip closepath color color
syn keyword gleStatement col command curve dashlen data define dist dpoints dsubticks dticks ellipse
syn keyword gleStatement elliptical_arc elliptical_narc else end if err errdown errright errup errwidth
syn keyword gleStatement fill fill font font fontlwidth for from fullsize grestore grid gsave hei
syn keyword gleStatement herr herrleft herrwidth hscale if include join just justify left let line
syn keyword gleStatement log lstyle lstyle lwidth lwidth marker marker max mdata min mitre msize
syn keyword gleStatement name narc next nobox nobox nofirst nolast nomiss nticks off offset origin
syn keyword gleStatement path pos postscript psbbtweak pscomment rad radius rbezier restoredefaults return reverse
syn keyword gleStatement right rline rmove rotate round save scale sep set shift size smooth
syn keyword gleStatement smoothm square step step stroke svg_smooth table then tiff title tl
syn keyword gleStatement to to translate vscale width width write xg xmax xmin xpos yg ymax ymin
syn keyword gleStatement ypos d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19
syn keyword gleStatement d20 d21 d22 d23 d24 d25 d26 d27 d28 d29 d30 d31 d32 d33 d34 d35 d36 d37
syn keyword gleStatement d38 d39 d40 d41 d42 d43 d44 d45 d46 d47 d48 d49 d50 d51 d52 d53 d54 d55
syn keyword gleStatement d56 d57 d58 d59 d60 d61 d62 d63 d64 d65 d66 d67 d68 d69 d70 d71 d72 d73
syn keyword gleStatement d74 d75 d76 d77 d78 d79 d80 d81 d82 d83 d84 d85 d86 d87 d88 d89 d90 d91
syn keyword gleStatement d92 d93 d94 d95 d96 d97 d98 d99 xaxis xlabels xnames xplaces xside
syn keyword gleStatement xsubticks xticks xtitle x2axis x2labels x2names x2places x2side x2subticks
syn keyword gleStatement x2ticks x2title yaxis ylabels ynames yplaces yside ysubticks yticks ytitle
syn keyword gleStatement graph key rotate sub y2axis y2labels y2names y2places y2side y2subticks
syn keyword gleStatement y2ticks y2title

hi link gleStatement Statement
hi link gleString String
hi link gleText Statement
