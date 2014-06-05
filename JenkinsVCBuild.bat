@echo off
rem Invoke Myself to Bypass Jenkins Script Interpreter Issues
if "%~1"=="self" goto Script
call "%~f0" self
exit /b %ErrorLevel%
:Script
setlocal EnableDelayedExpansion

rem Default PROJECT_NAME to JOB_NAME if not specified
call :Expand PROJECT_NAME %PROJECT_NAME% %JOB_NAME%

rem Default to x86, Visual Studio 2013, and no Klocwork
call :Expand VCARC %VCARC% x86
call :Expand VCVER %VCVER% 120
call :Expand KLOCWORK %KLOCWORK% NO

rem Setup the Visual Studio Environment
call :VCVars %VCVER% %VCARC% || goto End

rem Build Release and Debug
call :Build Release %VCVER% || goto End
call :Build Debug %VCVER% || goto End


rem Check for Klocwork Flag
if not defined Klocwork goto End
if /i not "%Klocwork:~0,1%"=="y" goto End
echo Running Klocwork Analysis...


rem Create Local Klocwork Project
kwcheck create --url http://ipklocworkdb:80/FrontEnd_VC 2>nul || kwcheck sync
kwcheck info

rem Run Klocwork Injector
call :Build Debug %VCVER% kwinject || goto End

rem Run the Analysis
if /i "%Klocwork:~-7%"=="rebuild" set "Rebuild=--rebuild"
kwcheck run %Rebuild% -b kwinject.out || goto End

rem Generate the Report
kwcheck list -F xml --report KlocworkReport.xml || goto End
echo Klockwork Analysis succeeded.
goto End


:End
echo.
echo Build Exit Code = %ErrorLevel%
@echo on & @endlocal & @exit /b %ErrorLevel%


:Build <Configuration> <Version> [Klocwork]
setlocal
if /i "%~1"=="Debug" set "Debug=YES"
call :BuildEnvironment %Debug%
call :TidyEnvironment
if "%~2"=="90" call :VCBuild %1 %3
if "%~2"=="100" call :MSBuild %1 %2 %3
if "%~2"=="110" call :MSBuild %1 %2 %3
if "%~2"=="120" call :MSBuild %1 %2 %3
endlocal & exit /b %ErrorLevel%


rem devenv /Build "%~1" /useenv
:MSBuild <Configuration> <Version> [Klocwork]
setlocal
if "%~2"=="100" set "ToolsVersion=4.0"
if "%~2"=="110" set "ToolsVersion=11.0"
if "%~2"=="120" set "ToolsVersion=12.0"
set "Command=MSBuild /ToolsVersion:%ToolsVersion% /p:PlatformToolset=v%~2 /p:Configuration=%~1 /p:OutDir=%~1\ /p:IntDir=%~1\ /p:IncludePath="%INCLUDE%" /p:LibraryPath="%LIB%" /p:ReferencePath="%LIBPATH%""
call :Defined %3 && set "Command=%Command:"=\"%"
@echo on
%~3 %Command%
@echo off
endlocal & exit /b %ErrorLevel%


rem devenv /Build "%~1" /useenv
:VCBuild <Configuration> [Klocwork]
@echo on
%~3 VCBuild /time /useenv "%~1"
@echo off
exit /b %ErrorLevel%


:BuildEnvironment [Debug Flag]
rem Update the Environment Variables
call :Expand INCLUDE "%VCINCLUDE%;%INCLUDE%;"
call :Expand LIB "%VCLIB%;%LIB%;"
call :Expand LIBPATH "%VCREFERENCE%;%LIBPATH%;"
call :Expand PATH "%VCPATH%;%PATH%;"
call :Expand DPATH "%PATH%;"
call :Defined %1 || exit /b 0
rem Using Debug Environment Variables
call :Expand INCLUDE "%VCINCLUDED%;%INCLUDE%;"
call :Expand LIB "%VCLIBD%;%LIB%;"
call :Expand LIBPATH "%VCREFERENCED%;%LIBPATH%;"
call :Expand PATH "%VCPATHD%;%PATH%;"
call :Expand DPATH "%PATH%;"
exit /b 0


:TidyEnvironment
rem Cleanup Environment Variables
call :TidyList INCLUDE
call :TidyList LIB
call :TidyList LIBPATH
call :TidyList PATH
call :TidyList DPATH
exit /b 0


:VCVars <Version> <Architecture>
call :Defined "%~1" || exit /b 1
call :Defined "%~2" || exit /b 2
rem Visual Studio Environment Setup Scripts
if "%~1"=="90" call "%ProgramFiles(x86)%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" %~2 && exit /b 0
if "%~1"=="100" call "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" %~2 && exit /b 0
if "%~1"=="110" call "%ProgramFiles(x86)%\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" %~2 && exit /b 0
if "%~1"=="120" call "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" %~2 && exit /b 0
echo Error: Unknown version of Visual Studio specified. Version=%~1
echo Supported versions include 90, 100, 110, and 120.
exit /b 3


rem Remove Excess Backslashes, Semicolons, and Duplicates
:TidyList <ListVar>
if not defined %~1 = exit /b 1
call :Expand "%~1" "%%%~1:;;=;%%"
call :Expand "%~1" "%%%~1:\\=\%%"
call :Expand "%~1" "%%%~1:\\=\%%"
call :Expand "%~1" "%%%~1:\;=;%%"
call :RemoveDuplicates %1
call :Expand "%~1" "%%%~1:;;=;%%"
call :CheckList %1
exit /b %ErrorLevel%


rem Remove Duplicate Entries from a List
:RemoveDuplicates <ListVar>
setlocal EnableDelayedExpansion
call :Expand List "%%%~1%%" || exit /b 1
set "Tsil="
for %%A in ("%List:;=" "%") do if not "%%~A"=="" set "Tsil=%%~A;!Tsil!"
for %%A in ("%Tsil:;=" "%") do if not "%%~A"=="" set "List=%%~A;!List:%%~A;=!"
endlocal & set "%~1=%List%"
exit /b 0


rem Check the List for Invalid Paths
:CheckList <ListVar>
setlocal
call :Expand List "%%%~1%%" || exit /b 1
for %%A in ("%List:;=" "%") do if not exist "%%~fA\" echo WARNING: "%%~A" not found.
endlocal & exit /b 0


rem Check for existence
:Defined <Input>
setlocal
set "Input=%~1"
if defined Input endlocal & exit /b 0
endlocal & exit /b 1


rem Variable Expansion and Validation Routine
:Expand <Var> [Value] [Default]
2>nul set "%~1=%~2"
if defined %~1 = exit /b 0
exit /b 1
