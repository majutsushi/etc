"#########################################################################
"# syntax/otl.vim: VimOutliner syntax highlighting
"# version 0.3.0
"#   Copyright (C) 2001,2003 by Steve Litt (slitt@troubleshooters.com)
"#
"#   This program is free software; you can redistribute it and/or modify
"#   it under the terms of the GNU General Public License as published by
"#   the Free Software Foundation; either version 2 of the License, or
"#   (at your option) any later version.
"#
"#   This program is distributed in the hope that it will be useful,
"#   but WITHOUT ANY WARRANTY; without even the implied warranty of
"#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"#   GNU General Public License for more details.
"#
"#   You should have received a copy of the GNU General Public License
"#   along with this program; if not, write to the Free Software
"#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
"#
"# Steve Litt, slitt@troubleshooters.com, http://www.troubleshooters.com
"#########################################################################

if exists("b:current_syntax")
    finish
endif

" body text
syntax match OTLBody "^\t*:.*$"

" pre-formatted text
syntax match OTLPre "^\t*;.*$"

" tables
syntax match OTLTable "^\t*|.*$"

" wrapping user text
syntax match OTLWrapping "^\t*>.*$"

" non-wrapping user text
syntax match OTLNonWrapping "^\t*<.*$"

" headings
syntax match OTLHeading1 "^[^:;|><\t].*$"
syntax match OTLHeading2 "^\t[^:;|><\t].*$"
syntax match OTLHeading3 "^\t\{2}[^:;|><\t].*$"
syntax match OTLHeading4 "^\t\{3}[^:;|><\t].*$"
syntax match OTLHeading5 "^\t\{4}[^:;|><\t].*$"
syntax match OTLHeading6 "^\t\{5}[^:;|><\t].*$"
syntax match OTLHeading7 "^\t\{6}[^:;|><\t].*$"
syntax match OTLHeading8 "^\t\{7}[^:;|><\t].*$"
syntax match OTLHeading9 "^\t\{8}[^:;|><\t].*$"

highlight default link OTLBody        Comment
highlight default link OTLPre         PreProc
highlight default link OTLTable       Function
highlight default link OTLWrapping    Directory
highlight default link OTLNonWrapping LineNr

highlight default link OTLHeading1 Normal
highlight default link OTLHeading2 Identifier
highlight default link OTLHeading3 Special
highlight default link OTLHeading4 Constant
highlight default link OTLHeading5 Normal
highlight default link OTLHeading6 Identifier
highlight default link OTLHeading7 Special
highlight default link OTLHeading8 Constant
highlight default link OTLHeading9 Normal

let b:current_syntax = "otl"
