" multiselect.vim: multiple persistent selections
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 24-May-2006 @ 15:32
" Created: 08-Sep-2006 @ 22:17
" Requires: Vim-7.0, genutils.vim(2.0)
" Version: 2.2.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=953
" Acknowledgements:
"     See :help multiselect-acknowledgements
" Description:
"     See doc/multiselect.txt

if exists('loaded_multiselect')
  finish
endif
if v:version < 700
  echomsg 'multiselect: You need at least Vim 7.0'
  finish
endif

" Dependency checks.
if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 200
  echomsg "multiselect: You need a newer version of genutils.vim plugin"
  finish
endif
let loaded_multiselect = 202

" Initializations {{{

if !exists('g:multiselQuickSelAdds')
  let g:multiselQuickSelAdds = 0
endif

if !exists('g:multiselUseSynHi')
  let g:multiselUseSynHi = 0
endif

if !exists('g:multiselAbortOnErrors')
  let g:multiselAbortOnErrors = 1
endif

if !exists('g:multiselMouseSelAddMod')
  let g:multiselMouseSelAddMod = 'C-'
endif

if !exists('g:multiselMouseSelAddKey')
  let g:multiselMouseSelAddKey = 'Left'
endif

command! -range MSAdd :call multiselect#AddSelection(<line1>, <line2>)
command! MSDelete :call multiselect#DeleteSelection()
command! -range=% MSClear :call multiselect#ClearSelection(<line1>, <line2>)
command! MSRestore :call multiselect#RestoreSelections()
command! MSRefresh :call multiselect#RefreshSelections()
command! -range MSInvert :call multiselect#InvertSelections(<line1>, <line2>)
command! MSHide :call multiselect#HideSelections()
command! -nargs=1 -complete=command MSExecCmd
      \ :call multiselect#ExecCmdOnSelection(<q-args>, 0)
command! -nargs=1 -complete=command MSExecNormalCmd
      \ :call multiselect#ExecCmdOnSelection(<q-args>, 1)
command! MSShow :call multiselect#ShowSelections()
command! MSNext :call multiselect#NextSelection(1)
command! MSPrev :call multiselect#NextSelection(-1)
command! -range=% -nargs=1 MSMatchAdd :call multiselect#AddSelectionsByMatch(<line1>,
      \ <line2>, <q-args>, 0)
command! -range=% -nargs=1 MSVMatchAdd :call multiselect#AddSelectionsByMatch(<line1>,
      \ <line2>, <q-args>, 1)
command! -range=% -nargs=1 MSMatchAddBySynGroup :call
      \ multiselect#AddSelectionsBySynGroup(<line1>, <line2>, <q-args>, 0)
command! -range=% -nargs=1 MSVMatchAddBySynGroup :call
      \ multiselect#AddSelectionsBySynGroup(<line1>, <line2>, <q-args>, 1)
command! -range=% -nargs=1 MSMatchAddByDiffHlGroup :call
      \ multiselect#AddSelectionsByDiffHlGroup(<line1>, <line2>, <q-args>, 0)
command! -range=% -nargs=1 MSVMatchAddByDiffHlGroup :call
      \ multiselect#AddSelectionsByDiffHlGroup(<line1>, <line2>, <q-args>, 1)

if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_multiselect_maps") || ! no_multiselect_maps) " [-2f]

if (! exists("no_multiselect_mousemaps") || ! no_multiselect_mousemaps)
  " NOTE: The conditional <Esc> is because sometimes for a single line
  " selection, Vim doesn't seem to start the visual mode, so an unconditional
  " <Esc> will generate 'eb's.
  exec 'noremap <expr> <silent> <'.g:multiselMouseSelAddMod.
        \ g:multiselMouseSelAddKey.'Mouse> '.
        \ '"\<'.g:multiselMouseSelAddKey.'Mouse>".'.
        \ '(mode()=~"[vV\<C-V>]"?"\<Esc>":"")."V"'
  exec 'noremap <silent> <'.g:multiselMouseSelAddMod.
        \ g:multiselMouseSelAddKey.'Drag> <'.g:multiselMouseSelAddKey.'Drag>'
  exec 'noremap <silent> <'.g:multiselMouseSelAddMod.
        \ g:multiselMouseSelAddKey.'Release> '.
        \ (g:multiselQuickSelAdds ? ':MSAdd' : ':MSInvert').
        \ '<CR><'.g:multiselMouseSelAddKey.'Release>'
endif

if maparg('<Enter>', 'v') == ''
  vnoremap <Enter> m`:MSInvert<Enter>``
endif

function! s:AddMap(name, map, cmd, mode, silent)
  if (!hasmapto('<Plug>MS'.a:name, a:mode))
    exec a:mode.'map <unique> <Leader>'.a:map.' <Plug>MS'.a:name
  endif
  exec a:mode.'map '.(a:silent?'<silent> ':'').'<script> <Plug>MS'.a:name.
        \ ' '.a:cmd
endfunction

call s:AddMap('AddSelection', 'msa', 'm`:MSAdd<CR>``', 'v', 1)
call s:AddMap('AddSelection', 'msa', ':MSAdd<CR>', 'n', 1)
call s:AddMap('DeleteSelection', 'msd', ':MSDelete<CR>', 'n', 1)
call s:AddMap('ClearSelection', 'msc', ':MSClear<CR>', 'v', 1)
call s:AddMap('ClearSelection', 'msc', ':MSClear<CR>', 'n', 1)
call s:AddMap('RestoreSelections', 'msr', ':MSRestore<CR>', 'n', 1)
call s:AddMap('RefreshSelections', 'msf', ':MSRefresh<CR>', 'n', 1)
call s:AddMap('HideSelections', 'msh', ':MSHide<CR>', 'n', 1)
call s:AddMap('InvertSelections', 'msi', ':MSInvert<CR>', 'n', 1)
call s:AddMap('InvertSelections', 'msi', ':MSInvert<CR>', 'v', 1)
call s:AddMap('ShowSelections', 'mss', ':MSShow<CR>', 'n', 1)
call s:AddMap('NextSelection', 'ms]', ':MSNext<CR>', 'n', 1)
call s:AddMap('PrevSelection', 'ms[', ':MSPrev<CR>', 'n', 1)
call s:AddMap('ExecCmdOnSelection', 'ms:', ':MSExecCmd<Space>', 'n', 0)
call s:AddMap('ExecNormalCmdOnSelection', 'msn', ':MSExecNormalCmd<Space>', 'n',
      \ 0)
call s:AddMap('MatchAddSelection', 'msm', ':MSMatchAdd<Space>', 'v', 0)
call s:AddMap('MatchAddSelection', 'msm', ':MSMatchAdd<Space>', 'n', 0)
call s:AddMap('VMatchAddSelection', 'msv', ':MSVMatchAdd<Space>', 'v', 0)
call s:AddMap('VMatchAddSelection', 'msv', ':MSVMatchAdd<Space>', 'n', 0)

delf s:AddMap
endif

" Initializations }}}


" vim6:fdm=marker et sw=2
