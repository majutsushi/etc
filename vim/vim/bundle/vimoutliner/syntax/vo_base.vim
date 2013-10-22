"#########################################################################
"# syntax/vo_base.vim: VimOutliner syntax highlighting
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
syntax match VOBody "^\t*:.*$"

" pre-formatted text
syntax match VOPre "^\t*;.*$"

" tables
syntax match VOTable "^\t*|.*$"

" wrapping user text
syntax match VOWrapping "^\t*>.*$"

" non-wrapping user text
syntax match VONonWrapping "^\t*<.*$"

" headings
syntax match VOHeading1 "^[^:;|><\t].*$"
syntax match VOHeading2 "^\t[^:;|><\t].*$"
syntax match VOHeading3 "^\t\{2}[^:;|><\t].*$"
syntax match VOHeading4 "^\t\{3}[^:;|><\t].*$"
syntax match VOHeading5 "^\t\{4}[^:;|><\t].*$"
syntax match VOHeading6 "^\t\{5}[^:;|><\t].*$"
syntax match VOHeading7 "^\t\{6}[^:;|><\t].*$"
syntax match VOHeading8 "^\t\{7}[^:;|><\t].*$"
syntax match VOHeading9 "^\t\{8}[^:;|><\t].*$"

highlight default link VOBody        Comment
highlight default link VOPre         PreProc
highlight default link VOTable       Function
highlight default link VOWrapping    Directory
highlight default link VONonWrapping LineNr

highlight default link VOHeading1 Normal
highlight default link VOHeading2 Identifier
highlight default link VOHeading3 Special
highlight default link VOHeading4 Constant
highlight default link VOHeading5 Normal
highlight default link VOHeading6 Identifier
highlight default link VOHeading7 Special
highlight default link VOHeading8 Constant
highlight default link VOHeading9 Normal

let b:current_syntax = "vo_base"
