@echo off
call :Main
exit /b 0


:Main {REGISTER}
setlocal
call :Setup
:_MainRegister
if not defined REGISTER goto _MainEnd
call :Expand :Register REGISTER
:_MainEnd
endlocal & exit /b %ErrorLevel%


:Setup
for %%A in ("%SystemRoot%\System32\regsvr32.exe") do if exist "%%~fA" ( set "RegSvr32=%%~fA" )
for %%A in ("%SystemRoot%\RegTLib.exe" "%SystemRoot%\SysWOW64\URTTEMP\RegTLib.exe" "%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\RegTLibv12.exe" "%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\RegTLibv12.exe") do if exist "%%~fA" ( set "RegTLib=%%~fA" )
for %%A in ("%ProgramFiles%\Microsoft SDKs\Windows" "%ProgramFiles(x86)%\Microsoft SDKs\Windows") do if exist "%%~A" for %%B in ("v7.0A\Bin" "v7.1\Bin" "v7.0A\Bin\NETFX 4.0 Tools" "v7.1\Bin\NETFX 4.0 Tools" "v8.0A\bin\NETFX 4.0 Tools" "v8.1A\bin\NETFX 4.5.1 Tools") if exist "%%~A\%%~B\TlbImp.exe" ( set "TlbImp=%%~A\%%~B\TlbImp.exe" )
for %%A in ("%SystemRoot%\Microsoft.NET\Framework\v1.1.4322" "%SystemRoot%\Microsoft.NET\Framework\v2.0.50727" "%SystemRoot%\Microsoft.NET\Framework\v4.0.30319") do if exist "%%~fA\" ( set "RegAsm=%%~fA\RegAsm.exe" & set "RegSvcs=%%~dpA\RegSvcs.exe" )
if not defined RegSvr32 echo [WARNING] Unable to find RegSvr32
if not defined RegTLib echo [WARNING] Unable to find RegTLib
if not defined TLibImp echo [WARNING] Unable to find TLibImp
if not defined RegAsm echo [WARNING] Unable to find RegAsm
if not defined RegSvcs echo [WARNING] Unable to find RegSvcs
exit /b 0 {RegTLib} {TlbImp} {RegAsm} {RegSvcs} {RegSvr32}


:Register [Directory;File;List=%CD%]
setlocal
call :Define List "%*" "%CD%"
for %%A in ("%List:;=" "%") do if exist "%%~fA\" ( call :RegisterDirectory "%%~fA" ) else if exist "%%~fA" ( call :RegisterFile "%%~fA" ) else echo [INVALID] %%~nA
endlocal & exit /b %ErrorLevel%


:RegisterDirectory [Directory=%CD%]
setlocal & echo.
call :Define Location %1 "%CD%"
pushd %Location% 2>nul && for /f "delims=" %%A in ('dir a-d /b *.dll *.ocx *.tlb') do call :RegisterFile "%%~fA"
echo [REGISTERED DIRECTORY] %~nx1
popd & endlocal & exit /b %ErrorLevel%


:UnRegisterDirectory [Directory=%CD%]
setlocal & echo.
call :Define Location %1 "%CD%"
pushd %Location% 2>nul && for /f "delims=" %%A in ('dir a-d /b *.dll *.ocx *.tlb') do call :UnRegisterFile "%%~fA"
echo [UNREGISTERED DIRECTORY] %~nx1
popd & endlocal & exit /b %ErrorLevel%


:RegisterFile <File>
call :UnRegisterFile %1 >nul
if /i "%~x1"==".tlb" call :RegisterTLB
if /i not "%~x1"==".tlb" call :RegisterDLL
exit /b


:RegisterTLB {RegTLib} {TlbImp}
@"%RegTLib%" "%~1" 2>nul && echo [REGISTERED TLB] %~n1 || echo [SKIPPED] %~n1
@"%TlbImp%" "%~1" /silent 2>nul && echo [IMPORTED TLB] %~n1
exit /b


:RegisterDLL {RegAsm} {RegSvcs} {RegSvr32}
@"%RegSvr32%" /s "%~f1" && echo [REGISTERED SVR] %~n1 || @"%RegAsm%" /nologo /silent "%~f1" /tlb:"%~dpn1.tlb" /codebase 2>nul && echo [REGISTERED ASM W/TLB] %~n1 || @"%RegAsm%" /nologo /silent "%~f1" /codebase 2>nul && echo [REGISTERED ASM] %~n1 || @"%RegSvcs%" /quiet "%~f1" 2>nul && echo [REGISTERED SVCS] %~n1 || echo [SKIPPED] %~n1
if exist "%~dpn1.tlb" call :RegisterTLB "%~dpn1.tlb"
exit /b


:UnRegisterFile <File>
if /i "%~x1"==".tlb" @"%RegTLib%" -u "%~1" 2>nul && echo %%~nA TLB UnRegistered || echo %%~nA Skipped
if /i not "%~x1"==".tlb" @"%RegSvr32%" /u /s "%~f1" && echo %~n1 SVR UnRegistered || @"%RegAsm%" /unregister /nologo /silent "%~f1" 2>nul && echo %~n1 ASM UnRegistered || @"%RegSvcs%" /u /quiet "%~f1" 2>nul && echo %~n1 SVCS UnRegistered || echo %~n1 Skipped
exit /b


:UnRegisterFile <File>
if /i "%~x1"==".tlb" call :UnRegisterTLB
if /i not "%~x1"==".tlb" call :UnRegisterDLL
exit /b


:UnRegisterTLB {RegTLib}
@"%RegTLib%" -u "%~1" 2>nul && echo [UNREGISTERED TLB] %~n1 || echo [SKIPPED] %~n1
exit /b


:UnRegisterDLL {RegAsm} {RegSvcs} {RegSvr32}
@"%RegSvr32%" /u /s "%~f1" && echo [UNREGISTERED SVR] %~n1 || @"%RegAsm%" /unregister /nologo /silent "%~f1" 2>nul && echo [UNREGISTERED ASM] %~n1 || @"%RegSvcs%" /u /quiet "%~f1" 2>nul && echo [UNREGISTERED SVCS] %~n1 || echo [SKIPPED] %~n1
if exist "%~dpn1.tlb" call :UnRegisterTLB "%~dpn1.tlb"
exit /b


:Define <=Var> [Value] [Default]
2>nul set "%~1=%~2"
if defined %~1 = exit /b 0
exit /b 1


:Defined <Input>
setlocal
set "Input=%~1"
if defined Input endlocal & exit /b 0
endlocal & exit /b 1


:: TODO support all parameters
:Expand <Command> <Var>
call :Defined %1 || exit /b 1
setlocal
if defined %2 = call :Define Var "%%%~2:"=%%"
call %1 "%Var%"
endlocal & exit /b %ErrorLevel%


:ProgramFiles32
set "ProgramFiles32=%ProgramFiles%"
if defined ProgramFiles(x86) set "ProgramFiles32=%ProgramFiles(x86)%"
exit /b 0
