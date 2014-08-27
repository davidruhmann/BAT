@echo off
setlocal EnableDelayedExpansion
rem Visual C++ and C# Jenkins Builder Script with Klocwork support
rem Requires Klocwork and an SVN client be in the PATH environment variable.
rem Version: 2014-08-27
rem TODO VCRegister
rem TODO Add branch detection to other scripts
call :GitAdjust
call :LoadProject || goto End
call :DetectBranch
call :ParseLabels
call :DefaultValues
call :Execute || goto End
:End
call :LogErrorLevel
@echo on & @endlocal & @exit /b %ErrorLevel%

:DefaultValues {VCVER} {VCCAR} {VCARC} {VCLOG} {VCCAN} {VCCON} {KLOCWORK} {KWIMPORT} {INPUT} {OUTPUT} {LABEL_*}
rem Adjust Defaults based on Project Type
if /i "%PROJECT_EXT%"==".vcproj" call :Expand VCVER %VCVER% 90
if /i "%PROJECT_EXT%"==".csproj" call :Expand VCCAR %VCCAR% MinimumRecommendedRules.ruleset
rem Default to x86, Visual Studio 2013, and no Klocwork
call :Expand VCARC %VCARC% x86
call :Expand VCVER %VCVER% %LABEL_VS2013% %LABEL_VS2010% %LABEL_VS2008% 120
call :Expand VCLOG %VCLOG% n
call :Expand VCCAN %VCCAN% NO
call :Expand VCCAR %VCCAR% NativeRecommendedRules.ruleset
if not defined VCCON set "VCCON=Release;Debug"
call :Expand KLOCWORK %KLOCWORK% %LABEL_KLOCWORK% NO
call :Expand KWIMPORT %KWIMPORT%
rem Update the INPUT and OUTPUT paths with the VCVER value
call :Expand INPUT "%VCINPUT%"
call :Expand OUTPUT "%VCOUTPUT%"
exit /b 0 : {VCVER} {VCCAR} {VCARC} {VCLOG} {VCCAN} {VCCON} {KLOCWORK} {KWIMPORT} {INPUT} {OUTPUT}

:DetectBranch {SVN_URL}
echo %SVN_URL% |findstr /i "branches" 2>nul && call :ParseBranch "%SVN_URL:branches= %" && exit /b 0
echo %SVN_URL% |findstr /i "tags" 2>nul && call :ParseBranch "%SVN_URL:tags= %" && exit /b 0
echo %SVN_URL% |findstr /i "sandbox" 2>nul && call :ParseBranch "%SVN_URL:sandbox= %" && exit /b 0
exit /b 1

:ParseBranch <tag branch> {BRANCH} ~UI
for /f "tokens=1,*" %%A in ("%~1") do for /f "delims=\/" %%C in ("%%~B") do if not defined BRANCH set "BRANCH=%%~C"
echo [INFO] Branch = %BRANCH%
exit /b 0

:: Requires custom Jenkins joblabel-environment plugin
:: Does not currently handle complex expressions, but just parses the labels.
:: Supported Labels: VS2013 VS2010 VS2008 KLOCWORK
:ParseLabels {JOB_LABELS}
set "JOB_LABELS_=%JOB_LABELS:(= %"
set "JOB_LABELS_=%JOB_LABELS_:)= %"
set "JOB_LABELS_=%JOB_LABELS_:&= %"
set "JOB_LABELS_=%JOB_LABELS_:|= %"
for %%A in ("%JOB_LABELS_: =" "%") do set "LABEL_%%~A=%%~A"
for /f "tokens=1,* delims==" %%A in ('set LABEL_') do call :ReplaceLabels "%%~A"
exit /b 0 : {JOB_LABELS_} {LABEL_*}

:ReplaceLabels {LABEL_*}
call :Expand %~1 %%%~1:VS2013=120%%
call :Expand %~1 %%%~1:VS2010=100%%
call :Expand %~1 %%%~1:VS2008=90%%
call :Expand %~1 %%%~1:KLOCWORK=YES%%
exit /b 0

:GitAdjust ~IO
call :GitSparse || exit /b 1
pushd "%GIT_SPARSE%" && set "WORKSPACE=%CD%"
exit /b %ErrorLevel% : {WORKSPACE} {GIT_SPARSE}

:GitSparse {GIT_BRANCH} ~IO/UI
if not defined GIT_BRANCH exit /b 0
for /f "delims=" %%A in ('type ".git\info\sparse-checkout"') do set "GIT_SPARSE=%%A"
if not defined GIT_SPARSE exit /b 1
set "GIT_SPARSE=%GIT_SPARSE:/=\%"
echo [INFO] Git sparse point found
exit /b 0 : {GIT_SPARSE}

:Execute {VCCON} {VCVER} {VCARC} {VCLOG} {VCCAN} {VCCAR} {PROJECT} {KWIMPORT}
call :VCVars %VCVER% %VCARC% || goto _Execute
for %%A in ("%VCCON:;=" "%") do call :Build %%A %VCVER% %VCLOG% %VCCAN% %VCCAR% || goto _Execute
call :Klocwork Debug %VCVER% %VCLOG% %PROJECT% %KWIMPORT% || goto _Execute
:_Execute
exit /b %ErrorLevel%

:LogErrorLevel {ErrorLevel} ~UI
echo.
if %ErrorLevel% equ 0 echo [INFO] Status Code = %ErrorLevel%
if %ErrorLevel% neq 0 echo [ERROR] Status Code = %ErrorLevel%
exit /b %ErrorLevel%

:Klocwork <Configuration> <Version> <Verbosity> <Project> [Import URL] ~IO/UI
rem Clean Existing Reports
del /F /Q KlocworkReport.xml 2>nul
del /F /Q KlocworkTraceReport.txt 2>nul
rem Check for Klocwork Flag
call :IsTrue Klocwork || exit /b 0
rem Clean standalone caches
if not exist .kwlp rd /S /Q .kwps 2>nul
if not exist .kwps rd /S /Q .kwlp 2>nul
rem Create Local Klocwork Project
echo [INFO] Connecting to Klocwork Server...
kwcheck create --url http://ipklocworkdb:80/FrontEnd_VC || kwcheck sync
rem call :KlocworkImportSVN "%~5" Klocwork
kwcheck info
rem Run Klocwork Build Injector
echo [INFO] Running Klocwork Build Injection...
call :IsSharp %4 && ( call :KlocworkSharpInject %1 %2 %4 || exit /b 5 )
call :IsSharp %4 || ( call :Build %1 %2 %3 NO null kwinject || exit /b 1 )
rem Run Klocwork Analysis, and Report Generators
echo [INFO] Running Klocwork Analysis...
kwcheck run -y -b kwinject.out || exit /b 2
kwcheck list -y -F xml --report KlocworkReport.xml || exit /b 3
kwcheck list -y -F detailed --report KlocworkTraceReport.txt || exit /b 4
kwcheck sync
echo [INFO] Klockwork Analysis succeeded.
rem Cleanup cache since slaves have very limited space
rd /S /Q .kwps 2>nul
rd /S /Q .kwlp 2>nul
exit /b %ErrorLevel%

:KlocworkImport <Source> [Configurations] ~IO/UI
setlocal
call :Expand Filters %2 "*.kb *.mconf *.pconf *.tconf"
echo [INFO] Importing Klocwork Rules...
for /f "delims=" %%A in ('"pushd %1 && dir /a-d /b %Filters% & popd"') do kwcheck import "%~1\%%~A" && echo Imported %%~nxA || Skipped %%~nxA
endlocal & exit /b 0

:KlocworkImportSVN <SVN URL> <Target> [Configurations] ~IO
call :Defined %1 || exit /b 1
svn co %1 %2 || exit /b 2
call :KlocworkImport %2 %3
rd /Q /S %2 || exit /b 4
exit /b 0

:KlocworkSharpInject <Configuration> <Version> <Project> ~IO/UI
setlocal
echo [INFO] Injecting into C# Project...
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
call :Expand PROJECT %1 || ( endlocal & exit /b 1 )
if /i "%PROJECT:~-7%"==".csproj" ( endlocal & exit /b 0 )
endlocal & exit /b 2

:LoadProject ~UI
call :FindProject "*.csproj *.vcxproj *.vcproj" || exit /b 1
call :IsSharp %PROJECT% && echo [INFO] Project Type = C# || echo [INFO] Project Type = C++
echo [INFO] Project = %PROJECT%
exit /b 0

:FindProject <Filters> ~IO/UI
set "PROJECT="
set "PROJECT_EXT="
set "PROJECT_NAME="
for /f "delims=" %%A in ('dir /b /a-d %~1 2^>nul') do if not defined PROJECT set "PROJECT=%%~nxA" &set "PROJECT_EXT=%%~xA" &set "PROJECT_NAME=%%~nA"
if defined PROJECT exit /b 0
echo [ERROR] No project file found. Supported Types = %~1
exit /b 1 : {PROJECT} {PROJECT_EXT} {PROJECT_NAME}

:Build <Configuration> <Version> <Verbosity> <Code Analysis> <Rule Set> [Klocwork] {KLOCWORK}
setlocal
call :Expand VCBIN %1
set "Debug=" & if /i "%~1"=="Debug" set "Debug=YES"
:: If Klocwork enabled, but just building Debug regular, exit to prevent building Debug twice.
call :IsTrue Debug && call :IsTrue Klocwork && call :Not :Defined %6 && (endlocal & exit /b 0)
call :BuildEnvironment %Debug%
call :TidyEnvironment
if "%~2"=="90" call :VCBuild %1 %6
if "%~2"=="100" call :MSBuild %1 %2 %3 %4 %5 %6
if "%~2"=="110" call :MSBuild %1 %2 %3 %4 %5 %6
if "%~2"=="120" call :MSBuild %1 %2 %3 %4 %5 %6
endlocal & exit /b %ErrorLevel%

rem devenv /Build "%~1" /useenv
:MSBuild <Configuration> <Version> <Verbosity> <Code Analysis> <Rule Set> [Klocwork] ~IO/UI
setlocal
rem HACK: To fix the issue with deprecated regsvr32 post/custom build parameters.
md %1 2>nul
@echo off > "%~1\regsvr32.trg"
rem Specify Special Version Specific Options
set "ToolsVersion="
if "%~2"=="120" set "ToolsVersion=/m /ignore:.sln /nr:false /tv:12.0 /flp:LogFile="MSBuild%~1%~6.log""
if "%~2"=="100" set "ToolsVersion=/m /ignore:.sln /nr:false /tv:4.0 /p:TargetFrameworkVersion=v3.5"
if "%~2"=="90"  set "ToolsVersion="
rem Enable Debug Build Code Analysis but not on Klocwork Debug Builds
set "CodeAna="
if "%~2"=="120" if /i "%~1"=="Debug" set "CodeAna=/p:RunCodeAnalysis=true /p:CodeAnalysisRuleSet="%~5""
if /i not "%~4"=="YES" set "CodeAna=/p:RunCodeAnalysis=false"
call :Defined %6 && set "CodeAna=/p:RunCodeAnalysis=false"
rem Build the Command
set "Command=MSBuild %ToolsVersion% /p:PlatformToolset=v%~2 /p:Configuration=%~1 /p:OutDir=%~1\ /p:IntDir=%~1\ /p:OutputPath=%~1\ /p:IncludePath="%INCLUDE%" /p:LibraryPath="%LIB%" /p:ReferencePath="%LIBPATH%" /p:PreBuildEvent="" /p:PostBuildEvent="" /p:CustomBuildStep="" /p:ImportLibrary="$(OutDir)$(TargetName).lib" /p:OutputFile="$(OutDir)$(TargetName)$(TargetExt)" /p:TypeLibraryName="$(OutDir)$(TargetName).tlb" /p:ProgramDatabaseFile="$(OutDir)$(TargetName).pdb" %CodeAna% /v:%~3"
rem Update the Command for Klocwork
call :Defined %6 && set "Command=%Command:"=\"% /t:Rebuild"
rem Execute the Command
@echo on
%~6 %Command%
@echo off
endlocal & exit /b %ErrorLevel%

rem devenv /Build "%~1" /useenv
:VCBuild <Configuration> [Klocwork] ~IO/UI
setlocal
set "Command=VCBuild /logfile:"MSBuild%~1.log" /M /time /u "%~1""
call :Defined %3 && set "Command=%Command:"=\"% /rebuild"
@echo on
%~3 %Command%
@echo off
endlocal & exit /b %ErrorLevel%

:: setup the build environment list variables from the system
:BuildEnvironment [Debug Flag] {INCLUDE} {LIB} {LIBPATH} {PATH} {DPATH} {VCINCLUDE} {VCINCLUDED} {VCLIB} {VCLIBD} {VCREFERENCE} {VCREFERENCED} {VCPATH} {VCPATHD}
:: Update the Environment Variables
call :Expand INCLUDE "%VCINCLUDE%;%INCLUDE%;"
call :Expand LIB "%VCLIB%;%LIB%;"
call :Expand LIBPATH "%VCREFERENCE%;%LIBPATH%;"
call :Expand PATH "%VCPATH%;%PATH%;"
call :Expand DPATH "%PATH%;"
call :Defined %1 || exit /b 0
:: Using Debug Environment Variables
call :Expand INCLUDE "%VCINCLUDED%;%INCLUDE%;"
call :Expand LIB "%VCLIBD%;%LIB%;"
call :Expand LIBPATH "%VCREFERENCED%;%LIBPATH%;"
call :Expand PATH "%VCPATHD%;%PATH%;"
call :Expand DPATH "%PATH%;"
exit /b 0 : {INCLUDE} {LIB} {LIBPATH} {PATH} {DPATH}

:: tidy the build environment list variables
:TidyEnvironment {INCLUDE} {LIB} {LIBPATH} {PATH} {DPATH}
call :TidyList INCLUDE
call :TidyList LIB
call :TidyList LIBPATH
call :TidyList PATH
call :TidyList DPATH
exit /b 0 : {INCLUDE} {LIB} {LIBPATH} {PATH} {DPATH}

:: initialize the visual studio environment
:VCVars <Version> <Architecture> ~IO/UI
call :Defined "%~1" || exit /b 1
call :Defined "%~2" || exit /b 2
if "%~1"=="90" call :ProgramFiles32 "Microsoft Visual Studio 9.0\VC\vcvarsall.bat" %~2 && exit /b 0
if "%~1"=="100" call :ProgramFiles32 "Microsoft Visual Studio 10.0\VC\vcvarsall.bat" %~2 && exit /b 0
if "%~1"=="120" call :ProgramFiles32 "Microsoft Visual Studio 12.0\VC\vcvarsall.bat" %~2 && exit /b 0
echo [ERROR] Unknown version of Visual Studio specified. Version=%~1
echo [INFO] Supported versions include 90, 100, and 120, but not all slaves support all versions.
exit /b 3

:: remove excess backslashes, semicolons, and duplicate entries
:TidyList <ListVar>
if not defined %~1 = exit /b 1
call :Expand "%~1" "%%%~1:;;=;%%"
call :Expand "%~1" "%%%~1:\\=\%%"
call :Expand "%~1" "%%%~1:\\=\%%"
call :Expand "%~1" "%%%~1:\;=;%%"
call :RemoveDuplicates %1
:: remove any new excess and fix network paths
call :Expand "%~1" ";%%%~1:\\=\%%"
call :Expand "%~1" "%%%~1:;;=;%%"
call :Expand "%~1" "%%%~1:;\=;\\%%"
call :Expand "%~1" "%%%~1:~1%%"
call :CheckList %1
exit /b %ErrorLevel%

:: remove duplicate entries from list
:RemoveDuplicates <ListVar>
setlocal EnableDelayedExpansion
call :Expand List "%%%~1%%" || ( endlocal & exit /b 1 )
set "Tsil="
for %%A in ("%List:;=" "%") do if not "%%~A"=="" set "Tsil=%%~A;!Tsil!"
for %%A in ("%Tsil:;=" "%") do if not "%%~A"=="" set "List=%%~A;!List:%%~A;=!"
endlocal & set "%~1=%List%"
exit /b 0

:: check list for non-existent paths
:CheckList <ListVar> ~UI
setlocal
call :Expand List "%%%~1%%" || ( endlocal & exit /b 1 )
for %%A in ("%List:;=" "%") do if not exist "%%~fA\" echo [INFO] "%%~A" not found.
endlocal & exit /b 0

:: use 32-bit program files
:ProgramFiles32 <SubPath> [Vars...9] {ProgramFiles(x86)} {ProgramFiles} ~IO
if exist "%ProgramFiles(x86)%" call "%ProgramFiles(x86)%\%~1" %2 %3 %4 %5 %6 %7 %8 %9
if not exist "%ProgramFiles(x86)%" call "%ProgramFiles%\%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ErrorLevel%

:: check for existence of variable
:Defined <Input>
setlocal
set "Input=%~1"
if defined Input endlocal & exit /b 0
endlocal & exit /b 1

:: variable expansion and validation
:Expand <Var> [Value] [Default]
2>nul set "%~1=%~2"
if defined %~1 = exit /b 0
exit /b 1

:IsTrue <Var>
setlocal
call :Expand Var %%%1%% || exit /b 1
if /i "%Var:0,1%"=="y" exit /b 0
if /i "%Var:0,3%"=="yes" exit /b 0
if /i "%Var:0,4%"=="true" exit /b 0
endlocal & exit /b 2

:!
:Not
call %* || exit /b 0
exit /b 1
