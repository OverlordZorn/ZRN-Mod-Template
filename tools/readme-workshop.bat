@echo off
rem Converts README.md into README_workshop.txt (Steam Workshop description) - double-click this file, or run tools\readme-workshop.bat from the repo root
rem Any arguments are passed on to readme-workshop.ps1, e.g. tools\readme-workshop.bat -KeepLineBreaks

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0readme-workshop.ps1" %*
set "EXITCODE=%ERRORLEVEL%"

rem Keep the window open when started by double-click, so the result can be read
rem A double-click runs: cmd.exe /c ""<path>\readme-workshop.bat" "   - the trailing space is what sets it apart from a terminal
set "LAUNCHER=%CMDCMDLINE:"=%"
if /i "%LAUNCHER:~-5%"==".bat " pause

exit /b %EXITCODE%
