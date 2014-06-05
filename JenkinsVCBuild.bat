@echo off
setlocal EnableDelayedExpansion

rem Find the Project
call :FindProject "*.csproj *.vcxproj *.vcproj" || goto End

rem Default to x86, Visual Studio 2013, and no Klocwork
call :Expand VCARC %VCARC% x86
call :Expand VCVER %VCVER% 120
call :Expand KLOCWORK %KLOCWORK% NO

rem Adjust Defaults based on Project Type
if /i "%PROJECT_EXT%"==".vcproj" set "VCVER=90"

rem Setup the Visual Studio Environment
call :VCVars %VCVER% %VCARC% || goto End

rem Build Release and Debug
call :Build Release %VCVER% || goto End
call :Build Debug %VCVER% || goto End

rem Run Klocwork Analysis
call :Klocwork Debug %VCVER% %PROJECT% || goto End

:End
echo.
echo Exit Code = %ErrorLevel%
@echo on & @endlocal & @exit /b %ErrorLevel%


:Klocwork <Configuration> <Version> {Project}
rem Check for Klocwork Flag
if not defined Klocwork exit /b 0
if /i not "%Klocwork:~0,1%"=="y" exit /b 0
echo Running Klocwork Analysis...
rem Clean standalone caches
if not exist .kwlp rd /S /Q .kwps 2>nul
if not exist .kwps rd /S /Q .kwlp 2>nul
rem Create Local Klocwork Project
kwcheck create --url http://ipklocworkdb:80/FrontEnd_VC 2>nul || kwcheck sync
kwcheck info
rem Run Klocwork Build Injector
if /i "%PROJECT:~-6%"==".csproj" call :KlocworkSharpInject %1 %2 %PROJECT% || exit /b 5
if /i not "%PROJECT:~-6%"==".csproj" call :Build %1 %2 kwinject || exit /b 1
rem Run Klocwork Analysis, and Report Generators
kwcheck run -b kwinject.out || exit /b 2
kwcheck list -F xml --report KlocworkReport.xml || exit /b 3
kwcheck list -F detailed --report KlocworkTraceReport.txt || exit /b 4
echo Klockwork Analysis succeeded.
exit /b %ErrorLevel%


:KlocworkSharpInject <Configuration> <Version> <Project>
setlocal
rem C# Configuration Detection
call :FindProject "*.csproj" || exit /b 2
set "CONFIG=" &for /f "delims=" %%A in ('kwcsprojparser "%PROJECT%" --list-configs^|findstr /i "^%~1|"') do if not defined CONFIG set "CONFIG=%%~A"
if not defined CONFIG endlocal & exit /b 1
:: Create C# Klocwork Build Configuration
set "TFV="
if "%~2"=="100" set "TFV=TargetFrameworkVersion=v3.5"
@echo on
kwcsprojparser "%PROJECT%" -p %TFV% -c "%CONFIG%" -o kwinject.out
@echo off
endlocal & exit /b %ErrorLevel%


:FindProject <Filters>
set "PROJECT="
set "PROJECT_EXT="
set "PROJECT_NAME="
for /f "delims=" %%A in ('dir /b /a-d %~1 2^>nul') do if not defined PROJECT set "PROJECT=%%~nxA" &set "PROJECT_EXT=%%~xA" &set "PROJECT_NAME=%%~nA"
if defined PROJECT exit /b 0
echo ERROR: No project file found. Supported Types = %~1
exit /b 1


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
if "%~2"=="100" set "ToolsVersion=4.0 /p:TargetFrameworkVersion=v3.5"
if "%~2"=="120" set "ToolsVersion=12.0"
set "Command=MSBuild /ToolsVersion:%ToolsVersion% /p:PlatformToolset=v%~2 /p:Configuration=%~1 /p:OutDir=%~1\ /p:IntDir=%~1\ /p:IncludePath="%INCLUDE%" /p:LibraryPath="%LIB%" /p:ReferencePath="%LIBPATH%""
call :Defined %3 && set "Command=%Command:"=\"% /nr:false /t:Rebuild"
@echo on
%~3 %Command%
@echo off
endlocal & exit /b %ErrorLevel%


rem devenv /Build "%~1" /useenv
:VCBuild <Configuration> [Klocwork]
setlocal
set "Command=VCBuild /time /useenv "%~1""
call :Defined %3 && set "Command=%Command:"=\"% /rebuild"
@echo on
%~3 %Command%
@echo off
endlocal & exit /b %ErrorLevel%


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
if "%~1"=="120" call "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" %~2 && exit /b 0
echo Error: Unknown version of Visual Studio specified. Version=%~1
echo Supported versions include 90, 100, and 120.
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
rem call :CheckList %1
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
