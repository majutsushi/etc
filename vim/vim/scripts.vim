if did_filetype()
    finish
endif

let s:line1 = getline(1)

if s:line1 =~ '^\d\{4}-\d\{2}-\d\{2} \+\d\{2}:\d\{2}:\d\{2}\.\d\{3} \+\w\+ \+\[[^]]\+\]'
    setfiletype rhinolog
elseif s:line1 =~ '^\d\{4}-\d\{2}-\d\{2} \+\d\{2}:\d\{2}:\d\{2},\d\{3} \+\[[^]]\+\]\+ \+\w\+ \+\S\+ \+-'
    setfiletype scenlog
endif
