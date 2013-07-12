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
syntax match Comment "^\t*:.*$"

" pre-formatted text
syntax match PreProc "^\t*;.*$"

" tables
syntax match Function "^\t*|.*$"

" wrapping user text
syntax match Directory "^\t*>.*$"

" non-wrapping user text
syntax match LineNr "^\t*<.*$"

" headings
syntax match Normal     "^[^:;|><\t].*$"
syntax match Identifier "^\t[^:;|><\t].*$"
syntax match Special    "^\t\{2}[^:;|><\t].*$"
syntax match Constant   "^\t\{3}[^:;|><\t].*$"
syntax match Normal     "^\t\{4}[^:;|><\t].*$"
syntax match Identifier "^\t\{5}[^:;|><\t].*$"
syntax match Special    "^\t\{6}[^:;|><\t].*$"
syntax match Constant   "^\t\{7}[^:;|><\t].*$"
syntax match Normal     "^\t\{8}[^:;|><\t].*$"

let b:current_syntax = "vo_base"
