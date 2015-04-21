@echo off
if not "%~1"=="" call :Elevate %* 2>"%Temp%\%~n0.log" && exit /b || ( call :Error & exit /b )
call :IsAdmin && ( call :Futile & exit /b )
call :ElevateMe 2>"%Temp%\%~n0.log" || ( call :Error & exit /b )
exit
:Elevate <Executable> [Arguments]
setlocal DisableDelayedExpansion
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$0 = '%1'; $cl = '%*'; $ar = $cl.Substring($0.Length); if (![bool]$ar) {$ar = ' '}; start $0.Trim([char]0x22) -Verb runas -ArgumentList $ar -WorkingDirectory (cvpa .); exit(!$?);"
endlocal
exit /b
:ElevateMe
setlocal DisableDelayedExpansion
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "gwmi -Class Win32_Process -Filter ('ProcessId = ' + $pid) | foreach { $parent = gwmi -Class Win32_Process -Filter ('ProcessId = ' + $_.ParentProcessId)}; $gparent = gwmi -Class Win32_Process -Filter ('ProcessId = ' + $parent.ParentProcessId); $args = $gparent.CommandLine.Trim().Trim([char]0x22).Substring($gparent.ExecutablePath.Length) + ' '; start $gparent.ExecutablePath -Verb runas -ArgumentList $args -WorkingDirectory (cvpa .); exit(!$?);"
endlocal
exit /b
:Error
echo.Failed to elevate with Administrator privileges
echo.See "%Temp%\%~n0.log" for details.
exit /b
:Futile
echo.Session already has Administrator privileges
exit /b
:IsAdmin
setlocal DisableDelayedExpansion
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "exit(!(new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator));"
endlocal
exit /b
