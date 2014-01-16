@echo off
setlocal EnableExtensions
echo Registry Backup In Progress ^(6 Operations^)...
pushd "%~dp0"
for /f "skip=1 tokens=2 delims==" %%A in ('"WMIC OS Get LocalDateTime /Value 2>nul"') do set "DT=%%A"
set "DT=%DT:~0,4%-%DT:~4,2%-%DT:~6,2%-%DT:~8,2%-%DT:~10,2%"
reg export HKEY_CLASSES_ROOT   "%DT%_HKCR.reg" 2>nul || echo ERROR: HKCR Failed.
makecab "%DT%_HKCR.reg" "%DT%_HKCR.cab" 2>nul
reg export HKEY_CURRENT_USER   "%DT%_HKCU.reg" 2>nul || echo ERROR: HKCU Failed.
makecab "%DT%_HKCU.reg" "%DT%_HKCU.cab" 2>nul
reg export HKEY_LOCAL_MACHINE  "%DT%_HKLM.reg" 2>nul || echo ERROR: HKLM Failed.
makecab "%DT%_HKLM.reg" "%DT%_HKLM.cab" 2>nul
reg export HKEY_USERS          "%DT%_HKU.reg"  2>nul || echo ERROR: HKU  Failed.
makecab "%DT%_HKU.reg" "%DT%_HKU.cab" 2>nul
reg export HKEY_CURRENT_CONFIG "%DT%_HKCC.reg" 2>nul || echo ERROR: HKCC Failed.
makecab "%DT%_HKCC.reg" "%DT%_HKCC.cab" 2>nul
:: HKEY_DYN_DATA is from Windows 95, 98, and NT.  Does not exist for latest versions of Windows.
reg export HKEY_DYN_DATA       "%DT%_HKDD.reg" 2>nul || echo ERROR: HKDD Failed. ^(Deprecated^)
makecab "%DT%_HKDD.reg" "%DT%_HKDD.cab" 2>nul
echo Done.
popd
endlocal
pause>nul
exit /b 0


:BackupRegistry <Key> <Target> [Compress]
reg export %1 "%~2" >nul 2>&1 && call :Compress %2 %3 || echo ERROR: %1 Failed.
exit /b %ErrorLevel%


:Compress <File> [Target]
makecab %1 %2 2>nul | set /p "=" && echo SUCCESS: %1
exit /b %ErrorLevel%
