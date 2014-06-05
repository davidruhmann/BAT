@echo off
setlocal EnableDelayedExpansion

:: This script requires PROJECT_NAME
if not defined PROJECT_NAME echo ERROR: PROJECT_NAME not specified.& endlocal & exit /b 1

:: Default to x86, Visual Studio 2013, and no Klocwork
call :Expand VCARC !VCARC! x86
call :Expand VCVER !VCVER! 120
call :Expand KLOCWORK !KLOCWORK! NO

:: Setup the Visual Studio Environment
if "!VCVER!"=="90" call "%ProgramFiles(x86)%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" !VCARC! && goto Build
if "!VCVER!"=="100" call "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" !VCARC! && goto Build
::if "!VCVER!"=="110" call "%ProgramFiles(x86)%\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" !VCARC! && goto Build
if "!VCVER!"=="120" call "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" !VCARC! && goto Build
echo Error: Unknown version of Visual Studio specified. VCVER=!VCVER!
echo Supported versions include 90, 100, and 120.
endlocal & exit /b 1

:Build
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Setup Environment Variables
call :Expand INCLUDE "!VCINCLUDE!;!INCLUDE!;"
call :Expand LIB "!VCLIB!;!LIB!;"
call :Expand LIBPATH "!VCREFERENCE!;!LIBPATH!;"
call :Expand PATH "!VCPATH!;!PATH!;"
call :Expand DPATH "!PATH!;"
call :TidyList INCLUDE
call :TidyList LIB
call :TidyList LIBPATH
call :TidyList PATH
call :TidyList DPATH

:: Determine Tools Version
set "ToolsVersion="
if "!VCVER!"=="90" goto VCPROJ
if "!VCVER!"=="100" call :Expand ToolsVersion 4.0
if "!VCVER!"=="110" call :Expand ToolsVersion 11.0
if "!VCVER!"=="120" call :Expand ToolsVersion 12.0
goto VCXPROJ

:VCXPROJ
@echo on
MSBuild "%PROJECT_NAME%.vcxproj" /ToolsVersion:%ToolsVersion% /p:PlatformToolset=v%VCVER% /p:Configuration=Release /p:OutDir=Release\ /p:IntDir=Release\ /p:IncludePath=\"%INCLUDE%;\" /p:LibraryPath=\"%LIB%;\" /p:ReferencePath=\"%LIBPATH%;\" || @goto End
@echo off
goto BuildDebug

:VCPROJ
@echo on
VCBuild /time /useenv "%PROJECT_NAME%.vcproj" "Release" || @goto End
@echo off
goto BuildDebug


:BuildDebug
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Setup Debug Environment Variables
call :Expand INCLUDE "!VCINCLUDED!;!INCLUDE!;"
call :Expand LIB "!VCLIBD!;!LIB!;"
call :Expand LIBPATH "!VCREFERENCED!;!LIBPATH!;"
call :Expand PATH "!VCPATHD!;!PATH!;"
call :Expand DPATH "!PATH!;"
call :TidyList INCLUDE
call :TidyList LIB
call :TidyList LIBPATH
call :TidyList PATH
call :TidyList DPATH

:: Determine Tools Version
if "!VCVER!"=="90" goto VCPROJD
goto VCXPROJD

:VCXPROJD
@echo on
MSBuild "%PROJECT_NAME%.vcxproj" /ToolsVersion:%ToolsVersion% /p:PlatformToolset=v%VCVER% /p:Configuration=Debug /p:OutDir=Debug\ /p:IntDir=Debug\ /p:IncludePath=\"%INCLUDE%;\" /p:LibraryPath=\"%LIB%;\" /p:ReferencePath=\"%LIBPATH%;\" || @goto End
@echo off
goto BuildKlocwork

:VCPROJD
@echo on
VCBuild /time /useenv "%PROJECT_NAME%.vcproj" "Debug" || @goto End
@echo off
goto BuildKlocwork


:BuildKlocwork
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check for Klocwork Flag
if not defined Klocwork goto End
if /i not "%Klocwork:~0,1%"=="y" goto End
echo Running Klocwork Analysis...

:: Setup Klocwork Environment
set "Path=C:\Klocwork\Insight 10.0 Command Line\bin;%Path%"
set "Rebuild="

:: Create Local Klocwork Project
kwcheck create --url http://ipklocworkdb:80/FrontEnd_VC 2>nul
::kwcheck create --license-host ipvmfactorylic4 --license-port 27000

:: Sync Server Project
::kwcheck sync

:: Display Configuration
kwcheck info

:: Checkout Nursing's Klocwork Rule Set
::svn checkout http://scm.nursing.cerner.corp/svn/vcdev/trunk/tools/Klocwork Klocwork

:: Import Nursing's Klocwork Rule Set
::kwcheck import Klocwork\generated.kb
::kwcheck import Klocwork\statNPD.kb
::kwcheck import Klocwork\metrics_default.mconf
::kwcheck import Klocwork\analysis_profile.pconf
::kwcheck import Klocwork\Stability_taxonomy.tconf
::echo f|xcopy Klocwork\configuration.txt .kwlp\configuration.txt /R /Y

:: Determine Tools Version
if "!VCVER!"=="90" goto VCPROJK
goto VCXPROJK

:VCXPROJK
@echo on
kwinject MSBuild "%PROJECT_NAME%.vcxproj" /nr:false /ToolsVersion:%ToolsVersion% /t:Rebuild /p:PlatformToolset=v%VCVER% /p:Configuration=Debug /p:OutDir=Debug\ /p:IntDir=Debug\ /p:IncludePath=\"%INCLUDE%;\" /p:LibraryPath=\"%LIB%;\" /p:ReferencePath=\"%LIBPATH%;\" || @goto End
@echo off
goto RunKlocwork

:VCPROJK
@echo on
kwinject VCBuild /time /useenv "%PROJECT_NAME%.vcproj" "Debug" || @goto End
@echo off
goto RunKlocwork


:RunKlocwork
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Run the Analysis
if /i "%Klocwork:~-7%"=="rebuild" set "Rebuild=--rebuild"
kwcheck run %Rebuild% -b kwinject.out || goto End

:: Generate the Report
kwcheck list -F xml --report KlocworkReport.xml || goto End
echo Klockwork Analysis succeeded.
goto End


:End
echo.
echo Build Exit Code = %ErrorLevel%
@echo on & @endlocal & @exit /b %ErrorLevel%


::: Alternative Build Commands
:: 90
:: devenv "%PROJECT_NAME%.vcproj" /Build "Release" /useenv
:: 100+
:: devenv "%PROJECT_NAME%.vcxproj" /Build "Release" /useenv
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Routines

:: Remove Excess Backslashes, Semicolons, and Duplicates
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


:: Remove Duplicate Entries from a List
:RemoveDuplicates <ListVar>
setlocal EnableDelayedExpansion
call :Expand List "%%%~1%%" || exit /b 1
set "Tsil="
for %%A in ("%List:;=" "%") do if not "%%~A"=="" set "Tsil=%%~A;!Tsil!"
for %%A in ("%Tsil:;=" "%") do if not "%%~A"=="" set "List=%%~A;!List:%%~A;=!"
endlocal & set "%~1=%List%"
exit /b 0


:: Check the List for Invalid Paths
:CheckList <ListVar>
setlocal EnableDelayedExpansion
call :Expand List "%%%~1%%" || exit /b 1
for %%A in ("%List:;=" "%") do if not exist "%%~fA\" echo WARNING: "%%~A" not found.
endlocal & exit /b 0


:: Variable Expansion and Validation Routine
:Expand <Var> [Value] [Default]
2>nul set "%~1=%~2"
if defined %~1 = exit /b 0
exit /b 1
