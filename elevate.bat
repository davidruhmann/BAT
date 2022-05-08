@echo off
if not "%~1"=="" call :Elevate %* 2>"%Temp%\%~n0.log" && exit /b || ( call :Error & exit /b )
call :IsAdmin && ( call :Futile & exit /b )
call :ElevateMe 2>"%Temp%\%~n0.log" || ( call :Error & exit /b )
exit /b
:Elevate <Executable> [Arguments]
setlocal DisableDelayedExpansion
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$0 = '%1'; $cl = '%*'; $ar = $cl.Substring($0.Length); if (![bool]$ar) {$ar = ' '}; start $0.Trim([char]0x22) -Verb runas -ArgumentList $ar -WorkingDirectory (cvpa .); exit(!$?);"
endlocal
exit /b
:ElevateMe
:: ElevateMe does not work from inside cmd.exe due to batch files running in the same process, causing the grand parent (e.g. explorer.exe) to be elevated.  It could work for cmd at the expense of other uses by adding: if ( $parent.ExecutablePath -like '*cmd.exe' ) { $gparent = $parent } else { ... }.  However, default is to support everything but cmd.
:: TODO possibly update detection logic to check great grandparent if WindowsTerminal.
setlocal DisableDelayedExpansion
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "Get-CimInstance -ClassName Win32_Process -Filter ('ProcessId = ' + $pid) | foreach { $parent = Get-CimInstance -ClassName Win32_Process -Filter ('ProcessId = ' + $_.ParentProcessId)}; $gparent = Get-CimInstance -ClassName Win32_Process -Filter ('ProcessId = ' + $parent.ParentProcessId); if ( $gparent.CommandLine.Length -gt $gparent.ExecutablePath.Length ) { $args = ($gparent.CommandLine.Trim().Trim([char]0x22)).Substring($gparent.ExecutablePath.Length) }; if ( $var -eq $null ) { $args = ' ' }; $target=$gparent.ExecutablePath; if ($target -like '*WindowsTerminal.exe') {echo here;$target=($target.Replace('WindowsTerminal.exe', 'wt.exe')); $args=new-tab;}; echo $target; Start-Process -FilePath \"$target\" -Verb runas -ArgumentList $args -WorkingDirectory (cvpa .); exit(!$?);"
:: TODO if failed, Attempt elevate with execution path
endlocal
exit /b
:Error
echo.Failed to elevate with Administrator privileges
echo.See "%Temp%\%~n0.log" for details.
echo.If attempting to elevate cmd.exe, use: 'elevate cmd'
exit /b
:Futile
echo.Session already has Administrator privileges
exit /b
:IsAdmin
setlocal DisableDelayedExpansion
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "exit(!(new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator));"
endlocal
exit /b
