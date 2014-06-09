@echo off
setlocal EnableDelayedExpansion

rem TODO
rem Add support to check in XML reports [Klocwork, MSBuild, Doxygen] to the repo.

rem Find the Project
call :FindProject "*.csproj *.vcxproj *.vcproj" || goto End

rem Default to x86, Visual Studio 2013, and no Klocwork
call :Expand VCARC %VCARC% x86
call :Expand VCVER %VCVER% 120
call :Expand VCLOG %VCLOG% d
call :Expand KLOCWORK %KLOCWORK% NO
call :Expand KWIMPORT %KWIMPORT% http://scm.domain.com/svn/trunk/tools/Klocwork

rem Adjust Defaults based on Project Type
if /i "%PROJECT_EXT%"==".vcproj" set "VCVER=90"

rem Setup the Visual Studio Environment
call :VCVars %VCVER% %VCARC% || goto End

rem Build Release and Debug
call :Build Release %VCVER% %VCLOG% || goto End
call :Build Debug %VCVER% %VCLOG% || goto End

rem Run Klocwork Analysis
call :Klocwork Debug %VCVER% %VCLOG% %PROJECT% %KWIMPORT% || goto End

rem Save Generated Reports
rem call :CommitReports || goto End

:End
echo.
echo Exit Code = %ErrorLevel%
@echo on & @endlocal & @exit /b %ErrorLevel%


:CommitReports
call :SVNCommit KlocworkReport.xml MSBuildRelease.log MSBuildDebug.log
exit /b %ErrorLevel%


:SVNCommit <File[s]>
@svn ci -q -N -m "[Jenkins] @%SVN_REVISION% Build logs invoked by %BUILD_USER_ID%" --username "User" --password "%User%" %*
exit /b %ErrorLevel%


:Klocwork <Configuration> <Version> <Verbosity> <Project> [Import URL]
rem Check for Klocwork Flag
if not defined Klocwork exit /b 0
if /i not "%Klocwork:~0,1%"=="y" exit /b 0
rem Clean standalone caches
if not exist .kwlp rd /S /Q .kwps 2>nul
if not exist .kwps rd /S /Q .kwlp 2>nul
rem Create Local Klocwork Project
rem kwcheck create --url http://ipklocworkdb:80/FrontEnd_VC
rem kwcheck create --license-host ipvmfactorylic4 --license-port 27000
rem call :KlocworkImportSVN "%~5" Klocwork
rem Create Hybrid Klocwork Project
call :KlocworkHybrid
kwcheck info
rem Run Klocwork Build Injector
echo Running Klocwork Analysis...
call :IsSharp %4 && ( call :KlocworkSharpInject %1 %2 %4 || exit /b 5 )
call :IsSharp %4 || ( call :Build %1 %2 %3 kwinject || exit /b 1 )
rem Run Klocwork Analysis, and Report Generators
kwcheck run -b kwinject.out || exit /b 2
kwcheck list -F xml --report KlocworkReport.xml || exit /b 3
kwcheck list -F detailed --report KlocworkTraceReport.txt || exit /b 4
echo Klockwork Analysis succeeded.
exit /b %ErrorLevel%


rem The Hybrid project is a workaround for the failure of the --url create method.
rem This allows for the server configuration to be downloaded onto a local project.
:KlocworkHybrid [Import URL]
rem Create Local Klocwork Project
echo Creating Local Project...
kwcheck create --license-host machinename --license-port 27000
rem Download Server Klocwork Project
md Klocwork || exit /b 1
pushd Klocwork || exit /b 2
echo Downloading Klocwork Server Configuration...
kwcheck create --url http://ipklocworkdb:80/Project
popd
rem Import Server Configuration and Cleanup
call :KlocworkImport Klocwork\.kwps\servercache
rd /Q /S Klocwork
rem Import Custom Configuration
call :KlocworkImportSVN "%~1" Klocwork "*.mconf *.pconf *.tconf"
exit /b 0


:KlocworkImport <Source> [Configurations]
setlocal
call :Expand Filters %2 "*.kb *.mconf *.pconf *.tconf"
echo Importing Klocwork Rules...
for /f "delims=" %%A in ('"pushd %1 && dir /a-d /b %Filters% & popd"') do kwcheck import "%~1\%%~A" && echo Imported %%~nxA || Skipped %%~nxA
endlocal & exit /b 0


:KlocworkImportSVN <SVN URL> <Target> [Configurations]
call :Defined %1 || exit /b 1
svn co %1 %2 || exit /b 2
call :KlocworkImport %2 %3
rd /Q /S %2 || exit /b 4
exit /b 0


:KlocworkSharpInject <Configuration> <Version> <Project>
setlocal
rem C# Configuration Detection
call :FindProject "*.csproj" || exit /b 2
set "CONFIG=" &for /f "delims=" %%A in ('kwcsprojparser "%~3" --list-configs^|findstr /i "^%~1|"') do if not defined CONFIG set "CONFIG=%%~A"
if not defined CONFIG endlocal & exit /b 1
:: Create C# Klocwork Build Configuration
set "TFV="
if "%~2"=="100" set "TFV=TargetFrameworkVersion=v3.5"
@echo on
kwcsprojparser "%~3" -p %TFV% -c "%CONFIG%" -o kwinject.out
@echo off
endlocal & exit /b %ErrorLevel%


:IsSharp <Project>
setlocal
call :Expand PROJECT %1 || endlocal & exit /b 1
if /i "%PROJECT:~-6%"==".csproj" endlocal & exit /b 0
endlocal & exit /b 2


:FindProject <Filters>
set "PROJECT="
set "PROJECT_EXT="
set "PROJECT_NAME="
for /f "delims=" %%A in ('dir /b /a-d %~1 2^>nul') do if not defined PROJECT set "PROJECT=%%~nxA" &set "PROJECT_EXT=%%~xA" &set "PROJECT_NAME=%%~nA"
if defined PROJECT exit /b 0
echo ERROR: No project file found. Supported Types = %~1
exit /b 1


:Build <Configuration> <Version> <Verbosity> [Klocwork]
setlocal
if /i "%~1"=="Debug" set "Debug=YES"
call :BuildEnvironment %Debug%
call :TidyEnvironment
if "%~2"=="90" call :VCBuild %1 %4
if "%~2"=="100" call :MSBuild %1 %2 %3 %4
if "%~2"=="110" call :MSBuild %1 %2 %3 %4
if "%~2"=="120" call :MSBuild %1 %2 %3 %4
endlocal & exit /b %ErrorLevel%


rem devenv /Build "%~1" /useenv
:MSBuild <Configuration> <Version> <Verbosity> [Klocwork]
setlocal
set "ToolsVersion="
if "%~2"=="100" set "ToolsVersion=4.0 /p:TargetFrameworkVersion=v3.5"
if "%~2"=="120" set "ToolsVersion=12.0"
set "Dbg=" & rem if /i "%~1"=="Debug" set "Dbg=/p:WarningLevel=4"
set "Command=MSBuild /tv:%ToolsVersion% /p:PlatformToolset=v%~2 /p:Configuration=%~1 /p:OutDir=%~1\ /p:IntDir=%~1\ /p:IncludePath="%INCLUDE%" /p:LibraryPath="%LIB%" /p:ReferencePath="%LIBPATH%"" %Dbg% /m /v:%~3 /ignore:.sln
call :Defined %4 && set "Command=%Command:"=\"% /nr:false /t:Rebuild" || set "Command=%Command% /flp:LogFile="MSBuild%~1.log";Encoding=UTF-8"
@echo on
%~4 %Command%
@echo off
endlocal & exit /b %ErrorLevel%


rem devenv /Build "%~1" /useenv
:VCBuild <Configuration> [Klocwork]
setlocal
set "Command=VCBuild /logfile:"MSBuild%~1.log" /M /time /useenv "%~1""
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
