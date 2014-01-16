@echo off
setlocal EnableExtensions
echo Registry Backup In Progress...
for /f "skip=1 tokens=2 delims==" %%A in ('"WMIC OS Get LocalDateTime /Value 2>nul"') do set "DT=%%A"
set "DT=%DT:~0,4%-%DT:~4,2%-%DT:~6,2%-%DT:~8,4%_%ComputerName%"
pushd "%~dp0"
call :BackupRegistry HKEY_CLASSES_ROOT   "%DT%_HKCR.reg" "%DT%_HKCR.cab"
call :BackupRegistry HKEY_CURRENT_USER   "%DT%_HKCU.reg" "%DT%_HKCU.cab"
call :BackupRegistry HKEY_LOCAL_MACHINE  "%DT%_HKLM.reg" "%DT%_HKLM.cab"
call :BackupRegistry HKEY_USERS          "%DT%_HKU.reg"  "%DT%_HKU.cab"
call :BackupRegistry HKEY_CURRENT_CONFIG "%DT%_HKCC.reg" "%DT%_HKCC.cab"
:: Depreciated: HKEY_DYN_DATA is for Windows 95, 98, and NT.
call :BackupRegistry HKEY_DYN_DATA       "%DT%_HKDD.reg" "%DT%_HKDD.cab"
popd
echo Done.
endlocal
pause>nul
exit /b 0


:BackupRegistry <Key> <Target> [Compress]
reg export %1 "%~2" >nul 2>&1 && call :Compress %2 %3 || echo ERROR: %1 Failed.
exit /b %ErrorLevel%


:: Max Cab size is 1.99 GB
:Compress <File> [Target]
makecab %1 %2 >nul 2>&1 && del /F /Q %1 && echo SUCCESS: %~n1 || ISSUE: %~n1
exit /b %ErrorLevel%
