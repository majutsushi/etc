" selectbuf.vim
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 28-May-2007 @ 19:51
" Created: Before 20-Jul-1999
"          (Ref: http://groups.yahoo.com/group/vim/message/6409
"                mailto:vim-thread.1235@vim.org)
" Requires: Vim-7.0, genutils.vim(2.4)
" Depends On: multiselect.vim(2.1)
" Version: 4.3.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=107
" Usage: 
"   PLEASE READ THE INSTALL SECTION COMPLETELY.
"   
"   SelectBuf is a buffer explorer similar to the file explorer plugin that
"   comes with Vim, the difference being that file explorer allows you to view
"   the files on the file system, where as buffer explorer limits the view to
"   only the files that are already opened in the current Vim session. It is
"   even possible and easy to extend the plugin with new commands.
"   
"   Since the first time I released it in Jul '99 (try sending an email to 
"   vim-thread.1235@vim.org if you are curious), the script has gone many
"   revisions and enhancements both technologiclly and feature wise, taking
"   advantage of all the niceties that the new version of Vim has to offer.
"   
"   For detailed help, see ":help selectbuf" or read doc/selectbuf.txt. 
"   
"   - Install the plugin, restart vim and press <F3> (the default key binding)
"     to get the list of buffers.
"   - Move the cursor on to the buffer that you need to select and press <CR> or
"     double click with the left-mouse button.
"   - If you want to close the window without making a selection, press <F3>
"     again.
"   - You can also press ^W<CR> or O to open the file in a new or previous
"     window.  You can use d to delete or D to wipeout the buffer. Use d again
"     to undelete a previously deleted buffer (you need to first view the
"     deleted buffers using u command).
"   
"   You can change the default key mapping to open browser window by setting 
"   
"         nmap <unique> <silent> <YourKey> <Plug>SelectBuf
"   
"   Almost everything is configurable, including all the key mappings that are
"   available. E.g., you can change the help key to <C-H> instead of the
"   default ?, so you can free it to do backward searches in the file list,
"   using the following mapping:
"   
"         noremap <silent> <Plug>SelBufHelpKey <C-H> 
"   
"   Some highlights of the features are:
"   
"   - It is super fast as the buffer list is cached and incrementally built as
"     new files are added and the old ones are deleted.
"   - Hide buffer numbers to save on real estate (goes well with "Always On"
"     mode or when used with WinManager).
"   - Opens a new window to avoid disturbing your existing windows. But you can
"     change the behavior to reuse the current window or even to permanently
"     keep it open.
"   - You can select block of buffers and delete or wipeout all the buffers at
"     once.
"   - You can toggle various settings on and off while you are in the browser.
"     You can e.g., toggle showing the buffer indicators by pressing i.
"   - Goes very well with WinManager.
"   - There are different sorting keys available. You can sort by buffer number,
"     name, type (extension), path, indicators and MRU order. You can even
"     select a default sort order
"   - If you use multiple windows, then the browser restores the window sizes
"     after closing it.
"   - Syntax coloring makes it easy to find the buffer you are looking to
"     switch to.
"   - Full configurability.
"   - Extensibility.
"   - Support for WinManager and multiselect plugins.
"   - and many more.
"   
"   For more information, read the vim help on seletbuf.
"
" TODO:
"   - It is useful to have space for additional indicators. Useful to show
"     perforce status.
"   - Is sort by path working correctly?
"   - When entering any of the plugin window's WinManager does something that
"     makes Vim ignore quick mouse-double-clicks. This is a WinManager issue,
"     as I verified this problem with other plugins also and SelectBuf in
"     stand-alone "keep" mode works fine.

if exists('loaded_selectbuf')
  finish
endif
if v:version < 700
  echomsg 'SelectBuf: You need at least Vim 7.0'
  finish
endif

" Dependency checks.
if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 204
  echomsg 'SelectBuf: You need a newer version of genutils.vim plugin'
  finish
endif
if !exists('loaded_multiselect')
  runtime plugin/multiselect.vim
endif
if exists('loaded_multiselect') && loaded_multiselect < 202
  echomsg 'SelectBuf: You need a newer version of multiselect.vim plugin'
endif
let loaded_selectbuf=403

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim
                      
"
" Define a default mapping if the user hasn't defined a map.
"
if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_selectbuf_maps") || ! no_selectbuf_maps)
  if !hasmapto('<Plug>SelectBuf', 'n')
    nmap <unique> <silent> <F3> <Plug>SelectBuf
  endif
  if !hasmapto('<ESC><Plug>SelectBuf', 'i')
    imap <unique> <silent> <F3> <ESC><Plug>SelectBuf
  endif
  if !hasmapto('<Plug>SelBufLaunchCmd', 'n')
    nmap <unique> <Leader>sbl <Plug>SelBufLaunchCmd
  endif
endif

" User option initialization {{{
function! s:CondDefSetting(settingName, def)
  if !exists(a:settingName)
    let {a:settingName} = a:def
  endif
endfunction

call s:CondDefSetting('g:selBufDisableSummary', 1)
call s:CondDefSetting('g:selBufRestoreWindowSizes', 1)
call s:CondDefSetting('g:selBufDefaultSortOrder', 'mru')
call s:CondDefSetting('g:selBufDefaultSortDirection', 1)
call s:CondDefSetting('g:selBufIgnoreNonFileBufs', 1)
call s:CondDefSetting('g:selBufAlwaysShowHelp', 0)
call s:CondDefSetting('g:selBufAlwaysShowHidden', 0)
call s:CondDefSetting('g:selBufAlwaysShowDetails', 0)
call s:CondDefSetting('g:selBufAlwaysShowPaths', 2)
if exists('g:selBufAlwaysHideBufNums')
  let selectbuf#userDefinedHideBufNums = 1
endif
call s:CondDefSetting('g:selBufAlwaysHideBufNums', 0)
call s:CondDefSetting('g:selBufBrowserMode', 'split')
call s:CondDefSetting('g:selBufUseVerticalSplit', 0)
call s:CondDefSetting('g:selBufSplitType', '')
call s:CondDefSetting('g:selBufDisableMRUlisting', 0)
call s:CondDefSetting('g:selBufEnableDynUpdate', 1)
call s:CondDefSetting('g:selBufDelayedDynUpdate', 0)
call s:CondDefSetting('g:selBufDoFileOnClose', 1)
call s:CondDefSetting('g:selBufIgnoreCaseInSort', 0)
call s:CondDefSetting('g:selBufDisplayMaxPath', -1)
call s:CondDefSetting('g:selBufLauncher', '')
call s:CondDefSetting('g:selBufRestoreSearchString', 1)
call s:CondDefSetting('g:selBufShowRelativePath', 0)
" }}}
                      
" Call this any time to reconfigure the environment. This re-performs the same
"   initializations that the script does during the vim startup, without
"   loosing what is already configured.
command! -nargs=0 SBInitialize :call selectbuf#Initialize()

"
" Define a command too (easy for debugging).
"
command! -nargs=0 SelectBuf :call selectbuf#ListBufs()
" commands to manipulate the MRU list.
command! -nargs=1 SBBufToHead :call selectbuf#PushToFrontInMRU(
      \ (<f-args> !~ '^\d\+$') ? bufnr(<f-args>) : <f-args>, 1)
command! -nargs=1 SBBufToTail :call selectbuf#PushToBackInMRU(
      \ (<f-args> !~ '^\d\+$') ? bufnr(<f-args>) : <f-args>, 1)
" Command to change settings interactively.
command! -nargs=* -complete=custom,selectbuf#SettingsComplete SBSettings
      \ :call selectbuf#SBSettings(<f-args>)
command! -complete=file -nargs=* SBLaunch :call selectbuf#LaunchBuffer(<f-args>)

" The main plug-in mapping.
noremap <script> <silent> <Plug>SelectBuf :call selectbuf#ListBufs()<CR>
nnoremap <script> <Plug>SelBufLaunchCmd :SBLaunch<Space>

" This is the list maintaining the MRU order of buffers.
let g:SB_MRUlist = []

" We delay the autocommand creation until VimEnter is triggered. This avoids
" selectbuf reacting to the initial buffers that are created during the startup,
" helping to avoid triggering the autoload.
function! s:VimEnter()
  aug SelectBuf
    " Deleting autocommands first is a good idea especially if we want to reload
    "   the script without restarting vim.
    au!
    au BufWinEnter * :call selectbuf#BufWinEnter()
    au BufWinLeave * :call selectbuf#BufWinLeave()
    au BufWipeout * :call selectbuf#BufWipeout()
    au BufDelete * :call selectbuf#BufDelete()
    au BufAdd * :call selectbuf#BufAdd()
    au BufNew * :call selectbuf#BufNew()
  aug END
  aug SelectBufVimEnter
    au!
  aug END
endfunction

aug SelectBufVimEnter
  au!
  au VimEnter * call <SID>VimEnter()
aug END
 

""" START: WinManager hooks. {{{

function! SelectBuf_Start()
  call selectbuf#SelectBuf_Start()
endfunction


" Called by WinManager for BufEnter event.
" Return invalid only when there are pending updates.
function! SelectBuf_IsValid()
  return selectbuf#SelectBuf_IsValid()
endfunction


function! SelectBuf_Refresh()
  call selectbuf#SelectBuf_Refresh()
endfunction


function! SelectBuf_ReSize()
  call selectbuf#SelectBuf_ReSize()
endfunction

""" END: WinManager hooks. }}}

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2
