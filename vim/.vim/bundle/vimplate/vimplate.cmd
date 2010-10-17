@echo off

rem Windows Script to run vimplate
rem please see: http://www.vim.org/scripts/scripts.php?script_id=1311
rem or :help vimplate

if %HOME%x == x goto nohome

perl %HOME%\vimplate\vimplate %1 %2 %3 %4 %5 %6 %7 %8 %9
goto end

:nohome
  echo Variable HOME isn't set!
  echo Please read the documentation.
  pause
  goto end

:end
