" multiselect.vim: Please see plugin/multiselect.vim

" Initializations {{{

aug MultiSelect
  au!
  au BufLeave * :call <SID>_hideSelections()
  au BufEnter * :call <SID>DrawSelections()
  " WORKAROUND: The WinLeave event might have preceded by a BufLeave event
  "   that could have _hidden the selection, so as long as there is selection
  "   in the current buffer, just draw it again.
  au WinLeave * :call <SID>DrawSelections()
  au WinEnter * :call <SID>DrawSelections()
aug END

let s:inExecution = 0
" Initializations }}}

function! multiselect#AddSelection(fline, lline) " {{{
  call s:SetSelRanges(add(copy(MSGetSelections()), [a:fline, a:lline]))

  if g:multiselUseSynHi
    call s:HighlightRange(a:fline, a:lline)
  else
    call s:MatchRanges()
  endif
endfunction " }}}

function! multiselect#ClearSelection(fline, lline) " {{{
  if !MSSelectionExists()
    return
  endif

  " When the range refers to the entire file or when MSClear is executed with
  " '%' as range.
  if a:fline == 1 && a:lline == line('$')
    call s:_hideSelections()
    call s:SetSelRanges([])
  else
    let newSel = []
    for curSel in MSGetSelections()
      let fl = MSFL(curSel)
      let ll = MSLL(curSel)
      " Check if this selection intersects with what needs to be deleted.
      if      (fl >= a:fline) && (fl <= a:lline) ||
            \ (a:fline >= fl) && (a:fline <= ll)
        let pt1 = s:Min(fl, a:fline)
        let pt2 = s:Max(fl, a:fline)
        let pt3 = s:Min(ll, a:lline)
        let pt4 = s:Max(ll, a:lline)
        if pt1 != pt2 && fl == pt1
          call add(newSel, [pt1, (pt2 - 1)])
        endif
        if pt3 != pt4 && ll == pt4
          let fl = pt3 + 1
          let ll = pt4
        else
          continue
        endif
      endif
      call add(newSel, [fl, ll])
    endfor
    if len(newSel) == 0
      MSClear
    else
      call s:SetSelRanges(newSel)
      MSRefresh
    endif
  endif
endfunction " }}}

function! multiselect#ShowSelections() " {{{
  if MSSelectionExists()
    for sel in MSGetSelections()
      let nLines = ((MSLL(sel) - MSFL(sel)) + 1)
      echo MSFL(sel).','.MSLL(sel) '(' . nLines 'lines)'
    endfor
  endif
endfunction " }}}

function! multiselect#DeleteSelection() " {{{
  let selIdx = s:FindSelection(line('.'), 0)
  if (selIdx != -1)
    let newSel = copy(MSGetSelections())
    call remove(newSel, selIdx)
    if len(newSel) == 0
      MSClear
    else
      call s:SetSelRanges(newSel)
      MSRefresh
    endif
  endif
endfunction " }}}

function! multiselect#RestoreSelections()"{{{
  if exists('b:_multiselRanges')
    let b:multiselRanges = b:_multiselRanges
    MSRefresh
  endif
endfunction"}}}

function! s:IsSelectionHidden() " {{{
  if exists('b:multiselHidden') && b:multiselHidden
    return 1
  else
    return 0
  endif
endfunction " }}}

function! multiselect#HideSelections() " {{{
  if !MSSelectionExists() || s:IsSelectionHidden()
    return
  endif

  call s:_hideSelections()
  let b:multiselHidden = 1
endfunction " }}}

" I need a better name for this function.
function! s:_hideSelections() " {{{
  if s:IsSelectionHidden()
    return
  endif

  if g:multiselUseSynHi
    " Actually, should not be required.
    syn clear MultiSelections
  else
    match NONE
  endif
endfunction " }}}

function! multiselect#RefreshSelections() " {{{
  MSHide

  let b:multiselHidden = 0
  if !MSSelectionExists()
    return
  endif

  call s:DrawSelections()
endfunction }}}

function! s:DrawSelections() " {{{
  if !MSSelectionExists() || s:IsSelectionHidden()
    return
  endif

  call genutils#SaveHardPosition('RefreshSelections')

  if g:multiselUseSynHi
    for sel in MSGetSelections()
      call s:HighlightRange(MSFL(sel), MSLL(sel))
    endfor
  else
    call s:MatchRanges()
  endif

  call genutils#RestoreHardPosition('RefreshSelections')
  call genutils#ResetHardPosition('RefreshSelections')
endfunction " }}}

function! multiselect#InvertSelections(fline, lline) " {{{
  let nexSel = []
  let invSel = []
  let intersectedAny = 0
  " To track ranges that are across multiple selections, we need a dynamic
  " range.
  let fline = a:fline
  let lline = a:lline
  let nextfl = fline
  let nextll = lline
  let i = -1
  for curSel in MSGetSelections()
    let i = i + 1
    let selfl = MSFL(curSel)
    let selll = MSLL(curSel)
    if selll < fline || selfl > lline
      " No intersection.
      call add(invSel, curSel)
      continue
    endif
    " TODO: Check if the selections went beyond the range and skip this
    " (optimization).
    let intersectedAny = 1

    if ((len(b:multiselRanges)-1) > i)
      let nexSel = b:multiselRanges[i+1]
      " If the range spawns across multiple selections, we need to handle it.
      if lline >= MSFL(nexSel)
        let nextfl = MSFL(nexSel)
        let nextll = lline
        let lline = MSFL(nexSel) - 1
      endif
    endif

    let pt1 = s:Min(selfl, fline)
    let pt2 = s:Max(selfl, fline)
    let pt3 = s:Min(selll, lline)
    let pt4 = s:Max(selll, lline)
    if pt1 != pt2
      call add(invSel, [pt1, (pt2 - 1)])
    endif
    if pt3 != pt4
      call add(invSel, [(pt3 + 1), pt4])
    endif

    let fline = nextfl
    let lline = nextll
  endfor
  if !intersectedAny
    call add(invSel, [fline, lline])
  endif

  if len(invSel) == 0
    MSClear
  else
    call s:SetSelRanges(invSel)
    MSRefresh
  endif
endfunction " }}}

" Add selection ranges for the matched pattern.
function! multiselect#AddSelectionsByMatch(fline, lline, pat, negate) " {{{
  call multiselect#AddSelectionsByExpr(a:fline, a:lline,
        \ 'match(getline(line(".")), a:1) > -1',
        \ a:negate, a:pat)
endfunction " }}}

function! multiselect#AddSelectionsBySynGroup(fline, lline, group, negate) " {{{
  call multiselect#AddSelectionsByExpr(a:fline, a:lline,
        \ 'synIDtrans(synID(line("."), strlen(getline(line("."))) - 1, 0)) == hlID(a:1)',
        \ a:negate, a:group)
endfunction " }}}

function! multiselect#AddSelectionsByDiffHlGroup(fline, lline, group, negate) " {{{
  call multiselect#AddSelectionsByExpr(a:fline, a:lline,
        \ 'synIDtrans(diff_hlID(line("."), strlen(getline(line("."))) - 1)) == hlID(a:1)',
        \ a:negate, a:group)
endfunction " }}}

function! multiselect#AddSelectionsByExpr(fline, lline, expr, negate, ...) " {{{
  call genutils#SaveHardPosition('AddSelectionsByExpr')

  let i = a:fline
  let cnt = 0
  let newSel = []
  let fl = -1
  while 1
    exec i | " Position the cursor on the line.
    let result = eval(a:expr)
    let result = ((!a:negate && result) || (a:negate && !result))
    if result && (i <= a:lline) && i != line('$')
      if fl == -1
        let fl = i
      endif
    else
      if fl != -1
        " When last line also matches, we want to include it too.
        let ll = i - (result ? 0 : 1)
        call add(newSel, [fl, ll])
        let fl = -1
        let cnt = cnt + 1
      endif
    endif
    if i > a:lline
      break
    endif
    let i = i + 1
  endwhile
  if cnt > 0
    call s:SetSelRanges(newSel)
    MSRefresh
  endif

  call genutils#RestoreHardPosition('AddSelectionsByExpr')
  call genutils#ResetHardPosition('AddSelectionsByExpr')
  echo 'Total selections added: '.cnt
endfunction " }}}

function! multiselect#ExecCmdOnSelection(theCommand, normalMode) " {{{
  if !MSSelectionExists()
    return
  endif

  let offset = 0
  let bufNr = bufnr('%') + 0 
  let saveMarkPos = getpos("'t")
  try
    for curSel in MSGetSelections()
      let fl = MSFL(curSel) + offset
      let ll = MSLL(curSel) + offset
      if ll != line('$')
        exec (ll+1).'mark t'
      endif
      let v:errmsg = ''
      let s:inExecution = 1
      if a:normalMode
        execute 'normal! '.fl.'GV'.ll.'G'
        execute 'normal ' . a:theCommand
      else
        execute fl.','.ll.' '.a:theCommand
      endif
      if g:multiselAbortOnErrors && v:errmsg != ''
        echohl ERROR | echo "ABORTED due to errors" | echohl NONE
      endif

      " Make sure we are still in the right window. If not, we can still find
      " and move cursor to the right window. Not having the buffer open in any
      " window is considered an error condition.
      if bufnr('%') != bufNr
        let winNr = bufwinnr(bufNr)
        if winNr == -1
          echohl ERROR | echo 'Execution ABORTED because the original buffer'.
                \ ' is no longer visible' | echohl NONE
          return
        endif
        exec winNr'wincmd w'
      endif

      " Strictly speaking, this should be done only if ll was not the last line
      "   in the file, but there is no harm if done unconditionally.
      let offset = offset + line("'t") - (ll + 1)
    endfor
  finally
    let s:inExecution = 0
    call setpos("'t", saveMarkPos)
  endtry
endfunction " }}}

" Utilities {{{
function! s:SetSelRanges(newSel)
  if exists('b:multiselRanges')
    let b:_multiselRanges = b:multiselRanges
  endif
  let b:multiselRanges = a:newSel
  call s:ConsolidateSelections()
endfunction

function! s:ConsolidateSelections() " {{{
  call s:SortSelections()

  let numConsolidations = 0
  let prevSel = []
  let curSel = []
  let consoldSel = []
  for curSel in b:multiselRanges
    if len(prevSel) == 0
      let prevSel = curSel
      continue
    elseif curSel == prevSel
      continue " Ignore duplicate.
    endif

    if MSLL(prevSel) >= (MSFL(curSel) - 1)
      " Next selection is with in the current selection range, ignore.
      if MSLL(curSel) <= MSLL(prevSel)
        continue
      endif
      " echo "Consolidating " . prevSel . " and " . curSel
      let prevSel = [MSFL(prevSel), MSLL(curSel)]
      let numConsolidations += 1
    else
      call add(consoldSel, prevSel)
      let prevSel = curSel
    endif
  endfor
  if len(prevSel) != 0 " Avoid adding an empty selection.
    call add(consoldSel, prevSel)
  endif
  let b:multiselRanges = consoldSel
endfunction " }}}

function! s:HighlightRange(ffline, lline) " {{{
  if s:IsSelectionHidden()
    return
  endif

  execute "syn match MultiSelections '\\%" . a:fline .
        \ "l\\_.*\\%" . a:lline . "l' containedin=ALL"
  execute "syn match MultiSelections '\\%" . a:fline .
        \ "l\\_.*\\%" . a:lline . "l' contains=ALL"
endfunction " }}}

function! s:MatchRanges() " {{{
  if s:IsSelectionHidden()
    return
  endif

  " CUATION: This should typically be done only once, as part of the plugin
  "   startup, but some plugins like SpellChecker.vim when turned off, remove
  "   all highlighting groups, so it is better that we do this everytime.
  " The highlight scheme to show the selection.
  hi default MultiSelections gui=reverse term=reverse cterm=reverse

  let matchPat = join(map(copy(MSGetSelections()),
        \ '"\\%>".(v:val[0]-1)."l\\%<".(v:val[1]+1)."l"'), '\|')
  execute "match MultiSelections '".matchPat."'"
endfunction " }}}

function! s:SortSelections()
  call sort(b:multiselRanges, function('s:CompareSelection'))
endfunction

function! s:CompareSelection(sel1, sel2)
  if MSFL(a:sel1) < MSFL(a:sel2)
    return -1
  elseif MSFL(a:sel1) > MSFL(a:sel2)
    return 1
  else
    return 0
  endif
endfunction

" Return the index of the selection containing the line. For dir:
"   0 - Find the selection containing the line.
"   1 - Find the next selection.
"  -1 - Find the previous selection.
function! s:FindSelection(linenr, dir)
  if MSSelectionExists()
    let i = 0
    for sel in MSGetSelections()
      " Selection containing line.
      if a:dir == 0 && (MSFL(sel) <= a:linenr &&
            \ MSLL(sel) >= a:linenr)
        return i
      elseif a:dir == 1 && (MSFL(sel) > a:linenr)
        return i
      elseif a:dir == -1 && (MSLL(sel) >= a:linenr)
        " Inside selection
        if MSFL(sel) < a:linenr && MSLL(sel) >= a:linenr
          return i
        else
          return i - 1
        endif
      endif
      let i = i + 1
    endfor
    " After the last selection
    if a:dir == -1 && a:linenr > MSLL(
          \ b:multiselRanges[len(b:multiselRanges)-1])
      return len(b:multiselRanges)-1
    endif
  endif
  return -1
endfunction

function! multiselect#NextSelection(dir) " {{{
  let selIdx = s:FindSelection(line('.'), a:dir)
  if selIdx != -1
    exec MSFL(b:multiselRanges[selIdx])
  endif
endfunction " }}}

function! s:Min(num1, num2)
  return (a:num1 < a:num2) ? a:num1 : a:num2
endfunction

function! s:Max(num1, num2)
  return (a:num1 > a:num2) ? a:num1 : a:num2
endfunction

" Function to heuristically determine if the user meant the range as the whole
"   file, when the default range for the command is only the current line
"   (workaround to avoid the cursor getting reset to firstline).
" FIXME: Why is this not used anymore?
function! s:MayBeRangeIsWholeFile(fline, lline)
  if (a:fline == a:lline && a:fline == line('.') &&
        \  !(line("'<") == line("'>") && a:fline == line("'<")))
    return 1
  else
    return 0
  endif
endfunction
" Utilities }}}

" Public interface {{{
function! MSFindSelection(linenr, dir)
  return s:FindSelection(a:linenr, a:dir)
endfunction

function! MSGetSelections()
  if !exists('b:multiselRanges')
    let b:multiselRanges = []
  endif
  return b:multiselRanges
endfunction

function! MSSelectionExists()
  return MSNumberOfSelections() > 0
endfunction

function! MSNumberOfSelections()
  if exists('b:multiselRanges')
    return len(b:multiselRanges)
  else
    return 0
  endif
endfunction

function! MSFL(sel)
  return a:sel[0]
endfunction

function! MSLL(sel)
  return a:sel[1]
endfunction

function! MSIsExecuting()
  return s:inExecution
endfunction
" Public interface }}}

" vim6:fdm=marker et sw=2
