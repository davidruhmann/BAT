@if (@CodeSection == @Batch) @then

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::LICENSE
:: Batch Framework for Windows
:: Copyright (c) 2013 David Ruhmann
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
:: THE SOFTWARE.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::NOTES
:: The first line in the script is...
:: in Batch, a valid IF command that does nothing.
:: in JScript, a conditional compilation IF statement that is false.
::             So the following section is omitted until the next "[at]end".
:: Note: the "[at]then" is required for Batch to prevent a syntax error.
:: If the task cannot be done in batch, use PowerShell with fallback J/WScript.
::
:: This framework only attempts to support versions of Windows still in support
:: by Microsoft.  However, most techniques utilized should work on any NT based
:: versions of Windows.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::CHANGELOG
:: TODO
::   Import Date Time Routines
::   See TODOs in this script.
::   Add Dave Benham's JScript Hybrid REPL.BAT
::   net user /domain %username%
:: 2014-01-10
::   Added IsFull Routine
::   Updated ColorIO to Version 21+
:: 2013-09-25
::   Worked on Timer Routines
::   Added SearchPath Routine
::   Added Installed Routine
:: 2013-08-28
::   Adjusted Detect Routines
::   Added Version 19 of Carlos' Color Routine "ColorIO"
::     - Enhanced to Version 19+ by David Ruhmann
::   Added EnvironmentVariablePS Routine
:: 2013-08-23
::   Added Not Routine
::   Finished MsgBox Routines
::     - MsgBox, MsgBoxJS, MsgBoxVB, and MsgBoxPS Routines
::   Added DelayedExpansion Routine
:: 2013-08-22
::   Added JScript VBScript Interface
::   Added VBScript InputBox
::   Added VBScript MsgBox
::   Added PowerShell MsgBox Routine
:: 2013-08-13
::   Added Chocolatey Routine
::   Added Firewall Routine WIP
::   Added NetworkCategory Routine
::   Added GUID Routine
::   Added Match Routine
:: 2013-07-31
::   Fixed Clean Routine, was not defaulting previous value.
::   Enhanced Elevate Routines to allow calling of any program.
::   Added ElevateMe Routine
:: 2013-07-26
::   Added Bounded Routine
::   Added Timer Routine
::   Added TimeStamp Routine
::   Added TimeTravel Routine
:: 2013-07-25
::   Added Params Routine
::   Added Append Routine
::   Changed Bounds Routine
::   Added BoundTo Routine
::   Added Path Routine
::   Added PathVerbose Routine
::   Added Exists Routine
::   Added ExistsVerbose Routine
::   Added Directory Routine
::   Added Detect Routine
::   Added DetectVerbose Routine
:: 2013-07-24
::   Added Typing Routine
::   Added Wait Routine
::   Added Bypass Routine
:: 2013-07-23
::   Added Bounds Routine
:: 2013-07-15
::   Added Expand safeguard and explanation.
::     - Changed Input Requirements to make Value optional.
::     - Added exit variable nullifier to safeguard defined command.
::   Added Prompt Routine
::   Added Abort Routine
::   Added empty var safeguard to Clean routine.
:: 2013-07-11
::   Begin Merging of MillenniumSetup.bat into this template.
::   Improved Elevate Routines
::     - Added ElevateOnce Routine
::     - Fixed Quotation Escaping
::   Added Prep Routine
:: 2013-06
::   Initial Assembly of this file (See David Ruhmann's Gist history)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Batch Section

@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Batch Framework (Alpha)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::SETTINGS
:: SET "KEY=VALUE", When the value is set = ENABLED, blank = DISABLED
set "LOG=Framework.log"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::MAIN
::DO NOT EDIT THIS SCRIPT BELOW THIS LINE:::::::::::::::::::::::::::::::::::::::

call :Tester

CScript //E:JScript //Nologo "%~f0" FolderBox "Hello Temp" "%Temp%"
pause
call :ColorIO 0C "Hello"
call :ColorIO 0A " World" \n
call :ColorLine red "Hello" green " World"
pause
call :ElevateMe %* ",./;[]{}\:?~-=_+!@#$*"
call :BoundTo 200 40 200 100
call :Info
echo Done
pause>nul
endlocal
call :Reset
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::ROUTINES

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Halt the script by invoking a syntax error and suppress the error message.
:Abort
call :__Abort 2>nul
exit /b 1
:: The following routine generates a syntax error.
:__Abort
()


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check for Administrator privileges
:: ErrorLevel 0 = Admin, 1 = Not Admin
:Admin
"%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system" >nul 2>&1
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Display the results to the Admin query.
:AdminVerbose
call :Admin && call :Void TeaLine gray "Admin: " green "Yes" || call :Void TeaLine gray "Admin: " red "No"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Append <Var> <Value>
call :Expand %1 "%%%~1%%%~2"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check the process architecture.  Return 1 if 64 bit.
:: TODO Improve detection method.
:Architecture
if "%Processor_Architecture%"=="AMD64" exit /b 1
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Display the results of the Architecture query.
:ArchitectureVerbose
call :Architecture && call :Void TeaLine gray "Architecture: " blue "32" ||	call :Void TeaLine gray "Architecture: " blue "64"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Base64Decode <Input> <OutputVar>
call :Base64DecodePS %1 %2
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Base64DecodePS <Input> <OutputVar>
PowerShell [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%~1'))
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Base64Encode <Input> <OutputVar>
call :Base64EncodePS %1 %2
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Base64EncodePS <Input> <OutputVar>
PowerShell [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('%~1'))
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Bounded <Var>
call :Defined %1 && if defined %1 exit /b 0
exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get the Bounds of the current Window stored into a variable.
:Bounds <Var>
for /f %%A in (
	'PowerShell -Command "&{$H=Get-Host; $C=$H.UI.RawUI; $B=$C.BufferSize; $W=$C.WindowSize; Write-Output $W.Width $W.Height $B.Width $B.Height;}" 2^>nul'
) do call :Append %1 "%%A "
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: Adjust the Console Size and Buffer Size.  Sizing is by Rows and Columns.
:: A backup of the BOUNDS is stored in an environment variable OLDBOUNDS.
:: Make sure if this fails to properly utilize the MORE command when needed.
:BoundTo <Console Width> <Console Height> <Buffer Width> <Buffer Height>
call :Bounds BOUNDSOLD
mode con: cols=%1 lines=%2
2>nul PowerShell -Command "&{$H=Get-Host; $C=$H.UI.RawUI; $B=$C.BufferSize; $B.Width=%3; $B.Height=%4; $C.BufferSize=$B;}"
call :Void Bounds BOUNDS
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:Bypass [Message]
setlocal
call :Expand Message %1 "Bypass? (y or n): "
:BypassLoop
call :Prompt Input %Message% True
endlocal & if /i "%Input:~0,1%"=="y" exit /b 0
exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Install Chocolatey and Update the PATH for this session.
:Chocolatey
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
set "PATH=%PATH%;%SystemDrive%\Chocolatey\bin"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Remove troublesome quotation marks. Uses existing value if value not defined.
:Clean <Var> [Value]
call :Expand %1 %2 "%%%~1%%"
if defined %1 call :Expand %1 "%%%~1:"=%%"
exit /b %ErrorLevel%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI/IO
:: Version 21 Plus
:: Works in Windows 7, 8. Need to re-validate XP
:: In XP, extended ASCII characters are displayed as dots.
:: To print a double quote, pass in an empty string.
:ColorIO <HexColor> [String=" [\n]] ...
setlocal DisableDelayedExpansion
subst `: /d >nul &subst `: "%Temp%" >nul &`: &pushd \
for /f "delims=;" %%A in ('"prompt $H;&for %%B in (_) do rem"') do (
	set "B3=%%A%%A%%A"
	set "B5=%%A%%A%%A%%A%%A"
	set "B7=%%A%%A%%A%%A%%A%%A%%A")
echo.|(pause >nul &findstr "^") >N
set /p "=." <nul >>N
set /p "LF=" <N
:__Color
set "Text=%~2"
if not defined Text set "Text=""
setlocal EnableDelayedExpansion
for %%A in ("!LF:~0,1!") do for %%B in (\ / :) do set "Text=!Text:%%B=%%~A%%B%%~A!"
for /f delims^=^ eol^= %%A in ("!Text!") do (
	if #==#! endlocal
	if \==%%A (
		findstr /A:%~1 . \N nul
		set /p "=%B3%" <nul
	) else if /==%%A (
		findstr /A:%~1 . /.\N nul
		set /p "=%B5%" <nul
	) else (
		echo %%A\..\N>_
		findstr /F:_ /A:%~1 .
		set /p "=%B7%" <nul)
)
if /i "\n"=="%~3" shift & echo.
shift & shift
set "1=%~1"
if defined 1 goto :__Color
popd & subst `: /d >nul & endlocal & exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: NOTE: Calling PowerShell repeatedly like this is slow.
:: Recursive Write function which continues for each color and text pair.
:: Single and Double Quotations and Percent Signs may cause Text to not display.
:: Invalid colors cause a regular write.
:Color <Color> <Text> ...
PowerShell Write-Host '"%~2"' -nonewline -foregroundcolor %~1 2>nul || call :Write %2
shift & shift
call :Defined %1 && goto Color || verify >nul
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:ColorLine <Color> <Text> ...
call :Color %1 %2
shift & shift
call :Defined %1 && goto ColorLine || verify >nul
call :Void NewLine
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Defined <Input>
setlocal
set "Input=%~1"
if defined Input endlocal & exit /b 0
endlocal & exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check for Delayed Expansion
::  If on, the exclamation mark ! will be evaluated into nothing, therefore,
::  causing the expression to be true.
:DelayedExpansion
if `==`! exit /b 1
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check if a command exists in protected environment.
:: Return 0 = Found, 9009 = Not Found
:: SIDE NOTE: The order of the stream redirects is important.
:: CMD parses the redirects from left to right.
:: >nul 2>&1 will output stdout to nul and stderr to stdout which is nul.
:: 2>&1 >nul will output the stderr to stdout and stdout to nul. Stderr will
::  be output to the console since it was parsed first and is using the old
::  value of stdout.
:: 2>&1 1>con: will output stderr to stdout (screen and stream) while stdout
::  will only be sent to the screen.
:: 3>&2 2>&1 1>&3 will swap the outputs.
:Detect <Command>
setlocal
%* >nul 2>&1
endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DetectHelp <Command>
call :Detect %1 /?
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:DetectVerbose <Command> [Label]
setlocal
call :Expand Label %2 %1
call :Tee "%Label%: "
endlocal
call :Detect %1 && call :Void Tea green "Found" || call :Void Tea red "Not Found"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: example: java -version
:DetectVersion <Command>
call :Detect %1 -version
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check if the path is a directory.
:Directory <Path>
if exist "%1\~" exit /b 0
exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Download <URL> <Target>
call :DownloadPS %1 %2 || call :DownloadJS %1 %2
exit /b %ErrorLevel%


::TODO Look into BitsAdmin (Believed to be deprecated and not in Win 7+)
:: C:\Users\DR022174>bitsadmin /transfer TempJob /download /priority normal "http://www.google.com" "%Temp%\Temp"
:: bitsadmin /info TempJob /verbose
:: 


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DownloadJS <URL> <Target>
if not exist "%~dp2" md "%~dp2"
CScript //E:JScript //Nologo "%~f0" Download "%~1" "%~f2"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DownloadPS <URL> <Target>
if not exist "%~dp2" md "%~dp2"
PowerShell (New-Object System.Net.WebClient).DownloadFile('%~1', '%~2')
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Echo <Message>
echo(%~1
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Elevate Privileges
:: NOTE: Make sure not to get your script in an infinite elevation loop when
::   admin privileges cannot be obtained. JScript cannot elevate reason unknown.
:: To elevate this script pass this script's full path as the first parameter.
::  "%~s0" or "%~f0"
:Elevate [Params...]
call :ElevatePS %* || call :ElevateVB %*
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ElevateMe [Params...]
call :ElevateOnce "%~f0" %*
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Attempt to Elevate Privileges only once.
:: Errorlevel 0 = No Issue, 2 = Already Invoked
:ElevateOnce [Params...]
call :Clean Note
if /i "%Note%"=="Elevate" exit /b 2
call :Elevate %*
exit /b %ErrorLevel%


:: TODO Flex for whether to keep /k or close /c the command window.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE "runas" is an undocumented verb for the ShellExecute function.
:: NOTE Parameters may not contain any batch or powershell special characters.
:: OK = ,./;[]{}\:?~-=_+!@#$*  BAD = `'|&^<>()  PAIR = "%
:: ErrorLevel 0 = Success
:: TODO look at Start-Process
:ElevatePS [Params...]
setlocal

:: Get Command Line and Escape Quotations
set "Args=%*"
set "Args=%Args:"=""%"

:: Execute PowerShell Command
PowerShell -Command $env:Note = 'Elevate'; (New-Object -com 'Shell.Application').ShellExecute('cmd.exe', '/k %Args%', '', 'runas') 2>nul
endlocal & ( exit /b %ErrorLevel% )


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE: "runas" is an undocumented verb for the ShellExecute function.
:: NOTE Parameters may not contain any batch or vbscript special characters.
:: OK = ,./;[]{}\:?~-=_+!@#$*  BAD = `'|&^<>()  PAIR = "%
:: ErrorLevel 0 = Success, 1 = File Error, 2 = Elevate Error
:ElevateVB [Params...]
setlocal

:: Get Command Line and Escape Quotations
set "Args=%*"
set "Args=%Args:"=""%"

:: Generate VBScript
set "VB=%Temp%\Admin.vbs"
> "%VB%" echo Set UAC = CreateObject^("Shell.Application"^)
>> "%VB%" echo UAC.ShellExecute "cmd.exe", "/k set ""Note=Elevate"" & %Args%", "", "runas"

:: Execute VBScript
if not exist "%VB%" ( exit /b 1 )
"%VB%"
endlocal & ( exit /b %ErrorLevel% )


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Target = Machine, Process, User (Default)
:: Variables may not contain = equal signs.
:: If the Value is not set they just retrieve the Value into the Variable.
:: If no option has been specified then a Replace will be performed.
:: The delimiter is only used for append or prepend, default ; semi-colon.
:: TODO Determine if when the Target is Process if this should be a set command.
:: Should we update this session's environment variables?
:: Maybe store the values into a Target::Variable name.
:: TODO Determine if there is any way to allow Target to be optional without
:: limiting the Var. "or be the same as a Target"
:EnvironmentVariablePS <Target=User(Default)|Process|Machine> <Variable> [Value [[A]ppend|[P]repend|[R]eplace(Default)] [Delim=;]]
setlocal
call :Expand Target %1 User
call :Match %Target% User Process Machine && shift || ( endlocal & exit /b 1 )
call :Expand Var %1 %Target% || ( endlocal & exit /b 2 )
call :Expand Value %2 || goto EnvironmentVariablePSGet
call :Expand Delim %4 ;
call :Expand Option %3
call :Match %Option% A Append && goto EnvironmentVariablePSAppend
call :Match %Option% P Prepend && goto EnvironmentVariablePSPrepend
call :Match %Option% R Replace && goto EnvironmentVariablePSReplace
goto EnvironmentVariablePSSet
:EnvironmentVariablePSGet
for /f "delims=" %%A in ('"PowerShell [Environment]::GetEnvironmentVariable('%Var%', '%Target%') 2>nul"') do set "Value=%%A"
endlocal & (set "%Var%=%Value%") & exit /b %ErrorLevel%
:EnvironmentVariablePSSet
:EnvironmentVariablePSReplace
PowerShell [Environment]::SetEnvironmentVariable('%Var%', '%Value%', '%Target%') 2>nul
endlocal & exit /b %ErrorLevel%
:EnvironmentVariablePSAppend
PowerShell [Environment]::SetEnvironmentVariable('%Var%', [Environment]::GetEnvironmentVariable('%Var%', '%Target%') + '%Delim%%Value%', '%Target%') 2>nul
endlocal & exit /b %ErrorLevel%
:EnvironmentVariablePSPrepend
PowerShell [Environment]::SetEnvironmentVariable('%Var%', '%Value%%Delim%' + [Environment]::GetEnvironmentVariable('%Var%', '%Target%'), '%Target%') 2>nul
endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EscapePS <Var> [Value]
call :Expand %1 "%~2"
call :Expand %1 "%%%1:"=\"%%"
call :Expand %1 "%%%1:'=\'%%"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Exists <Path>
if exist "%~1" exit /b 0
exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ExistsVerbose <Path> [Label]
setlocal
call :Expand Label %2 %1
call :Tee "%Label%: "
endlocal
call :Exists %1 && call :Void Tea green "Found at %~1" || call :Void Tea red "Missing from %~1"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: This works by exploiting the defined command.  If the Var is null, then the
:: set command will fail, the error message is caught, and the defined command
:: will fail because there should NEVER exist a variable called exit.
:Expand <Var> [Value] [Default]
set "exit="
2>nul set "%~1=%~2"
if defined %~1 exit /b 0
exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ExtractJS <Zip> <Destination>
CScript //E:JScript //Nologo "%~f0" Extract "%~f1" "%~f2"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: http://msdn.microsoft.com/en-us/library/windows/desktop/bb787866.aspx
:: TODO Add in Options paramter for CopyHere vOptions.
:ExtractPS <Zip> <Destination>
PowerShell (New-Object -COM Shell.Application).NameSpace('"%~2"').CopyHere((New-Object -COM Shell.Application).NameSpace('"%~1"').Items(), 16); 2>nul
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Toggle the Windows Firewall.  ErrorLevel 0 = ON, 1 = OFF
:: http://support.microsoft.com/kb/947709
:: TODO Finish
:Firewall <Toggle=ON>
setlocal
call :Expand Toggle %~1 "ON"
call :Match "%Toggle%" "ON" "ENABLE" && rem perform task here
call :Match "%Toggle%" "OFF" "DISABLE" && rem perform task here
::Old netsh firewall set opmode mode enable
::New netsh advfirewall set currentprofile state on
call :Void Tea red "Under Construction"
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Generate a GUID with delayed expansion.
:::: Generate Random Hexidecimal GUID
:: Loop Once for each GUID Value = 32
:: 1. Check if Hyphen Insert Needed
:: 2. Generate Random Number = 0-15
:: 3. Convert Number to Hexidecimal
:: 4. Append to GUID
:GUID <Var>
setlocal EnableDelayedExpansion
set "GUID="
for /L %%n in (1,1,32) do (
if "%%~n"=="9" set "GUID=!GUID!-"
if "%%~n"=="13" set "GUID=!GUID!-"
if "%%~n"=="17" set "GUID=!GUID!-"
if "%%~n"=="21" set "GUID=!GUID!-"
set /a "Value=!Random! %% 16"
if "!Value!"=="10" set "Value=A"
if "!Value!"=="11" set "Value=B"
if "!Value!"=="12" set "Value=C"
if "!Value!"=="13" set "Value=D"
if "!Value!"=="14" set "Value=E"
if "!Value!"=="15" set "Value=F"
set "GUID=!GUID!!Value!"
)
endlocal & call :Expand %1 "%GUID%"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Info
call :LogLine "%Date% %Time%"
call :AdminVerbose
call :ArchitectureVerbose
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: TODO REFACTOR
:Installed <Name> [Var]
setlocal EnableExtensions
set "Code=0"
set "Name=%~1"
if defined Name set "Name=%Name:"=%"
if not defined Name set "Code=1"
:: Search for the program name in the registry uninstall keys.
set "Key=HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"
for /f "tokens=2*" %%A in ('reg query "%Key%" /s /v DisplayName 2^>nul ^| find /i "%Name%" ^| sort') do set "Found=%%B"
set "Key=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
for /f "tokens=2*" %%A in ('reg query "%Key%" /s /v DisplayName 2^>nul ^| find /i "%Name%" ^| sort') do set "Found=%%B"
if not defined Found set "Code=1"
call :DebugMessage "Program = %Found%"
call :DebugCode "IsInstalled" || set "Found="
endlocal & ( set "%~2=%Found%" & exit /b %Code% )


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: TODO Fix Full Detection
:: Check if a Variable is full.  Batch variables can hold more than can be
:: entered on the command line.  Check to make sure that we do not truncate
:: our existing value.  Very useful in conjunction with setx.
:: Delayed Expansion will expand to an empty string when longer than allowed.
:IsFull <Var>
call :Defined %~1 || exit /b 1
if not defined %~1 exit /b 2
setlocal EnableDelayedExpansion
for /f "usebackq delims=" %%A in ('!%~1!') do if "%%~A"=="!%~1!" echo Different
endlocal
:: Method 2 Failed
::setlocal EnableDelayedExpansion
::set "%1=!%1!"
::set "ErrorLevel=0"
::if defined %1 set "ErrorLevel=3"
::endlocal & exit /b %ErrorLevel%
:: Method 1 Failed
::set "Var=!%1!;;"
::set "ErrorLevel=0"
::if /i ";;"=="%Var:~-2%" set "ErrorLevel=3"
::endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO
:: Write the Message to a Log file.  Uses the LOG global variable.
:Log <Message>
if not defined LOG exit /b 1
::if defined LOGTIME >> %LOG% call :Write "%Date% %Time%:"
>> %LOG% call :Write %1
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO
:LogLine <Message>
if not defined LOG exit /b 1
>> %LOG% call :WriteLine %1
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Match <String> <String> ...
setlocal
call :Expand Source %1 ""
call :Expand Target %2
:MatchLoop
if /i "%Source%"=="%Target%" endlocal & exit /b 0
shift
call :Expand Target %2 && goto MatchLoop
endlocal
exit /b 1


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Match a single character to a list of possible characters.
:MatchOneOf <Char> <Chars>
for /f "delims=%~2" %%A in ("%~1") do exit /b 1
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: Buttons
:: 0:	OK	(vbOKOnly)
:: 1:	OK Cancel	(vbOKCancel)
:: 2:	Abort Retry Ignore	(vbAbortRetryIgnore)
:: 3:	Yes No Cancel	(vbYesNoCancel)
:: 4:	Yes No	(vbYesNo)
:: 5:	Retry Cancel	(vbRetryCancel)
:: 6:	Cancel Try Continue
:: 16384:	Help
::
:: Icons
:: 0:	None
:: 16:	Error / Hand / Stop / Critical	(vbCritical)
:: 32:	Question	(vbQuestion)
:: 48:	Exclamation / Warning	(vbExclamation)
:: 64:	Asterisk / Information	(vbInformation)
::
:: DefaultButton
:: 0:	First	(vbDefaultButton1)
:: 256:	Second	(vbDefaultButton2)
:: 512:	Third	(vbDefaultButton3)
:: 768:	Fourth	(vbDefaultButton4)
::
:: Options
:: 0:	Application Modal	(vbApplicationModal) - Freeze application till response given.
:: 4096:	System Modal	(vbSystemModal) - Freeze entire system till response given.
:: 8192:	Task Modal
:: 65536:	SetForeground
:: 131072:	DefaultDesktopOnly
:: 262144:	TopMost
:: 524288:	RightAlign
:: 1048576:	RtlReading
:: 2097152:	ServiceNotification
::
:: Return Values
:: 0:	Error
:: 1:	OK	(vbOK)
:: 2:	Cancel	(vbCancel)
:: 3:	Abort	(vbAbort)
:: 4:	Retry	(vbRetry)
:: 5:	Ignore	(vbIgnore)
:: 6:	Yes	(vbYes)
:: 7:	No	(vbNo)
:: 10:	TryAgain
:: 11:	Continue
:MsgBox <Message> [Title] [Buttons] [Icon] [DefaultButton] [Options]
call :MsgBoxPS %1 %2 %3 %4 %5 %6 && call :MsgBoxJS %1 %2 %3 %4 %5 %6
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: Converts PS to VB parameters
:MsgBoxJS <Message> [Title] [Buttons] [Icon] [DefaultButton] [Options]
setlocal
call :Expand Buttons %3 0
call :Expand Icon %4 0
call :Expand Default %5 0
call :Expand Options %6 0
call :MsgBoxVB %1 "%Buttons% + %Icon% + %Default% + %Options%" %2
endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: CONSIDER Should I allow full enum values like this?
:: [Windows.Forms.MessageBoxButtons]::OK
:: [System.Windows.Forms.MessageBoxIcon]::Information
:: [System.Windows.Forms.MessageBoxDefaultButton]::Button1
:: [System.Windows.Forms.MessageBoxOptions]::DefaultDesktopOnly
:MsgBoxPS <Message> [Title=""] [Buttons=0] [Icon=0] [DefaultButton=0] [Options=0]
setlocal
call :Expand Message %1
call :Expand Title %2
call :Expand Buttons %3 0
call :Expand Icon %4 0
call :Expand Default %5 0
call :Expand Options %6 0
call :Match "%Buttons%" 0 1 2 3 4 5 6 16384 || ( endlocal & exit /b 0 )
call :Match "%Icon%" 0 16 32 48 64 || ( endlocal & exit /b 0 )
call :Match "%Default%" 0 256 512 768 || ( endlocal & exit /b 0 )
:: TODO Validate Options
:: Options can be multiple values added together. Some are mutually exclusive.
PowerShell [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') ^| Out-Null; exit [System.Windows.Forms.MessageBox]::Show('"%Message%"', '"%Title%"', %Buttons%, %Icon%, %Default%, %Options%);
endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: Note that ScriptControl Only works with the x86 version of cscript.
:MsgBoxVB <Message> [Buttons+Icon+Default+Options=0] [Title=""]
setlocal
call :Expand Message %1
call :Expand Options %2 0
call :Expand Title %3
:: TODO Validate Options
if exist "%SystemRoot%\SysWoW64\cmd.exe" (
	"%SystemRoot%\SysWoW64\cmd.exe" /c CScript //E:JScript //Nologo "%~f0" MsgBox "%Message%" "%Options%" "%Title%"
) else (
	CScript //E:JScript //Nologo "%~f0" MsgBox "%Message%" "%Options%" "%Title%"
)
endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Change the Network Connection Category
:: 0 = Public, 1 = Home/Work/Private, 2 = Domain
:: http://msdn.microsoft.com/en-us/library/windows/desktop/aa370800.aspx
:: Defaults are Category = 0, Filter = 0, aka no change.
:NetworkCategoryPS <Category=0> [Filter=0]
setlocal
call :Expand Filter %~2 0
call :Expand Category %~1 0
PowerShell -Command "&{$nlm = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')); $connections = $nlm.getnetworkconnections(); $connections | foreach { if ($_.GetNetwork().GetCategory() -eq %Filter%) { $_.GetNetwork().SetCategory(%Category%); } }; }"
endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:NewLine
echo.
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:NewLineTee
call :LogLine ""
call :NewLine
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Boolean reversal of the routine result. Useful for testing && || expressions.
:Not <Routine> [Params...]
call :%* && exit /b 1 || exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Parse parameters in "flag:value" format.
:Params [Param:Value] ...
for /f "tokens=1,* delims=:" %%A in ('%~1:') do call :Expand "%%~A" "%%~B"
call :Defined %2 || exit /b 0
shift
goto Params


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Search the Path environment variable for a specified entry.
:: TODO Flex on PowerShell failure to use batch method.
:PathFind <Path>
setlocal
set "Code=1"
call :Expand Input %1
:: PowerShell Method
for /f "delims=" %%A in ('"PowerShell $ENV:Path.Split(';') 2>nul"') do (
	if not exist "%%~A" call :Color red "WARNING: " white "The invalid location %%~A is listed in your system PATH."
	if /i "%%~A"=="%Input%" (
		set "Code=0"
	)
)
:: Batch Method
for %%A in ("%Path:;=" "%") do (
	if not exist "%%~A" call :Color red "WARNING: " white "The invalid location %%~A is listed in your system PATH."
	if /i "%%~A"=="%Input%" (
		set "Code=0"
	)
)
endlocal & ( exit /b %Code% )


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PathFindVerbose <Path> [Label]
setlocal
call :Expand Label %2 %1
call :Tee "%Label%: "
endlocal
call :PathFind %1 && call :Void TeaLine green "Found in PATH" || call :Void TeaLine red "Missing from PATH"
exit /b %ErrorLevel%

::::
C:\Windows\System32;C:\Windows;C:\Windows\System32\wbem;C:\Windows\System32\windowspowershell\v1.0\;C:\Windows\SysWOW64\;C:\Users\DR022174\AppData\Roaming\Sysinternals Suite;C:\Users\DR022174\AppData\Roaming\NirSoft Utilities;C:\Program Files (x86)\Common Files\NetSarang;C:\Program Files\Common Files\microsoft shared\windows live;C:\Program Files (x86)\Common Files\microsoft shared\windows live;C:\Program Files (x86)\Windows Live\Shared;C:\Program Files\Microsoft Windows Performance Toolkit\;C:\Program Files (x86)\Windows Kits\8.0\Windows Performance Toolkit\;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\;C:\Program Files\Cerner;C:\PROGRA~1\Cerner;C:\Klocwork\User 9.6\bin;C:\Program Files (x86)\GtkSharp\2.12\bin;C:\Program Files (x86)\IBM\WebSphere MQ\bin64;C:\Program Files (x86)\IBM\WebSphere MQ\bin;C:\Program Files (x86)\IBM\WebSphere MQ\tools\c\samples\bin;C:\Program Files (x86)\IBM\WebSphere MQ\Java\lib;C:\Program Files (x86)\Intel\OpenCL SDK\2.0\bin\x86;C:\Program Files (x86)\Intel\OpenCL SDK\2.0\bin\x64;C:\Program Files\TortoiseSVN\bin;C:\Program Files\Zero Install
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PathAdd <Path> [To Front]
:: To preserve variables in the path use four percent signs %%%%Var%%%%.
call :Defined %1 || exit /b 1
setlocal
call :Expand Var %1
if not exist %Var% call :Color red "WARNING: " white "%1 does not exist."
call :IsFull Path && call :Color red "ERROR: " white "Batch length limits exceeded."
call :Defined %2 && (
	PowerShell [Environment]::SetEnvironmentVariable('PATH', '"%~1;"' + [Environment]::GetEnvironmentVariable('PATH', 'Machine'), 'Machine') 2>nul
	rem setx Path "%~1;%Path%" /m
	set "Path=%~1;%Path%"
) || (
	PowerShell [Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'Machine') + '";%~1"', 'Machine') 2>nul
	rem setx Path "%Path%;%~1" /m
	set "Path=%Path%;%~1"
)
endlocal & exit /b %ErrorLevel%


setlocal
:PromptSetSystem32
set "Input="
set /p "Input=> May I add 'System32' to the 'Path' environment variable? (Y or N): "
if not defined Input goto PromptSetSystem32
set "Input=%Input:"=%"
verify >nul
if /i "%Input%"=="y" PowerShell [Environment]::SetEnvironmentVariable('PATH', '^%SystemRoot^%\System32;' + [Environment]::GetEnvironmentVariable('PATH', 'Machine'), 'Machine') 2>nul
if not "%ErrorLevel%"=="0" call :Color red "ERROR: Failed to change the PATH" 1
if /i not "%Input%"=="y" if /i not "%Input%"=="n" goto PromptSetSystem32
call :IsSystem32InPath
set "Code=%ErrorLevel%"
endlocal & ( exit /b %Code% )


%SystemRoot%\System32


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::OP
:: Perform some Script prep work.
:: ErrorLevel 0 = Success, All Else = Failure
:Prep [Params...]
call :IsAdminVerbose || ElevateOnce %* || exit /b 1
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:: Prompt the user for input.  Return 0 if input received, else 1 for no input.
:: TODO Add Color Version
:Prompt [Var] [Message] [Req]
setlocal
call :Expand Required %3
:PromptLoop
set "Input="
set /p "Input=> %~2"
if defined Required if not defined Input goto PromptLoop
endlocal & call :Expand %1 %Input%
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Reset
title %~dp0
cls
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO
:: Search through each PATH location with each PATHEXT for the search term.
:: This will search through the working directory first and without extension.
:: TODO REFACTOR: ADD RETURN VALUE SUPPORT AND FIRST MATCH ONLY OPTION
:SearchPath <Term>
for %%A in ("%CD%" "%path:;=" "%") do for %%B in ("" "%pathext:;=" "%") do if exist "%%~fA\%~1%%~B" echo "%%~fA\%~1%%~B"
exit /b 0


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO/UI
:Tea <Color> <Text> ...
call :Color %1 %2 && call :Log %2
shift & shift
call :Defined %1 && goto Tea || verify >nul
exit /b %ErrorLevel%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO/UI
:TeaLine <Color> <Text> ...
call :Color %1 %2 && call :Log %2
shift & shift
call :Defined %1 && goto TeaLine || verify >nul
call :Void NewLineTee
exit /b %ErrorLevel%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO/UI
:Tee <Message>
call :Write %1 && call :Log %1
exit /b %ErrorLevel%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO/UI
:TeeLine <Message>
call :WriteLine %1 && call :LogLine %1
exit /b %ErrorLevel%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO/UI
:: Tests for the Framework Routines
:Tester <echo>
setlocal EnableExtensions EnableDelayedExpansion
echo Testing...
echo.

:: set
echo Set + Expansion
set "Variable=Value"
if "%Variable%"=="Value" echo   - PASS
if not "%Variable%"=="Value" echo   - FAIL

:: Extensions
echo Extensions
setlocal DisableExtensions DisableDelayedExpansion
verify other 2>nul
setlocal EnableExtensions
if "%ErrorLevel%"=="0" echo   - PASS
if not "%ErrorLevel%"=="0" echo   - FAIL
endlocal

:: DelayedExpansion
echo DelayedExpansion
setlocal EnableDelayedExpansion
if "!Variable!"=="Value" echo   - PASS
if not "!Variable!"=="Value" echo   - FAIL
endlocal
endlocal

:: Expand
echo Expand
setlocal
:: A
call :Expand Var A B
if "%Var%"=="A" echo   - PASS A
if not "%Var%"=="A" echo   - FAIL A
:: Null A, B
set "Var="
call :Expand Var %Var% B
if "%Var%"=="B" echo   - PASS B
if not "%Var%"=="B" echo   - FAIL B
:: Null A and B
call :Expand Var "" ""
if not defined Var echo   - PASS NULL
if defined Var echo   - FAIL NULL
endlocal

:: IsFull
echo IsFull
setlocal
:: Full
set "Var=123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
@echo on
set "Var=1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
call :IsFull Var && echo   - PASS Full || echo   - FAIL Full
@echo off
:: Not Full
set "Var=%%Username%% Hello"
call :IsFull Var && echo   - FAIL Not Full || echo   - PASS Not Full
endlocal

pause>nul

:: Append
echo Append
setlocal
:: Empty Var
set "Var="
call :Append Var "Value"
if "%Var%"=="Value" echo   - PASS Value
if not "%Var%"=="Value" echo   - FAIL Value
:: Null Value
call :Append Var ""
if "%Var%"=="Value" echo   - PASS Null Value
if not "%Var%"=="Value" echo   - FAIL Null Value
:: Append
call :Append Var " Append"
if "%Var%"=="Value Append" echo   - PASS Append
if not "%Var%"=="Value Append" echo   - FAIL Append
endlocal

:: PathAdd
echo PathAdd
@echo on
call :PathAdd "%%%%Username%%%%"
@echo off


pause>nul

endlocal & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Parse a Date\Time variable.
:TimePiece <Var>
call :Bounded %1 || exit /b 1
set "%~1.Year=%%~1:~0,4%"
set "%~1.Month=%%~1:~4,2%"
set "%~1.Day=%%~1:~6,2%"
set "%~1.Hour=%%~1:~8,2%"
set "%~1.Minute=%%~1:~10,2%"
set "%~1.Second="%%~1:~12,2%
set "%~1.Milliseconds=%%~1:~15,6%"
set "%~1.TimeZone=%%~1:~21,5%"
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Start a Timer using the designated variable.
:: If the variable is already started, then display the difference and restart.
:Timer [Var=STAMP]
call :Bounded %1 && set "%~1.Last=%%~1%"
call :TimeStamp %1 STAMP
call :TimeTravel %1 STAMP
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Store the Current Local Date and Time in the specified variable.
:: Format  = YYYYMMDDhhmmss.MillisZone(In Minutes From Zero/UTC adjusted for DST)
:: Example = 20130729094132.283000-300
:: Year = 2013, Month = 07, Day = 29, Time = 09:41:32.283, Zone = -300/60 = -5:00 CDT
:TimeStamp <Var>
for /f "skip=1 tokens=2 delims==" %%A in ('"WMIC OS Get LocalDateTime /Value 2>nul"') do call :Expand %1 %%A
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Calculate the Time Traveled for the Timer.
:TimeTravel <Var>
:: TODO CONVERT TO JULIAN AND COMPARE
call :TimePiece %~1.Last
call :TimePiece %~1
:: TODO COMPARE RESULTS
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Display a Date\Time variable in a friendly format.
:TimeVerbose <Var>
:: TODO
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:Typing <Message>
setlocal
call :Expand Message %1 " "
:TypingLoop
call :Wait 150
call :Write %Message:~0,1%
call :Expand Message %Message:~1% && goto TypingLoop
endlocal
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Ignore the routine's exit code and use the previous exit code.
:Void <Routine> [Params...]
call :%* & exit /b %ErrorLevel%


:: TODO
:Voidc <Command> [Params...]
( call %* ) & exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Pause the thread for Span(ms) * Tick
:: Use 10.1.1.1 because it is a private IP address that should always timeout.
:: Private Ranges: 10.0/255.0/255.0/255, 172.16/31.0/255.0/255, 192.168.0/255.0/255
:: 127.0.0.1 will never timeout and will always return each tick in 1 second.
:Wait [Span(ms) = 1000] [Tick = 1]
setlocal
call :Expand Span %1 1000
call :Expand Tick %2 1
>nul 2>&1 ping 10.1.1.1 -n %Tick% -w %Span%
endlocal
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:Write <Message>
<nul set /p "=%~1"
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UI
:WriteLine <Message>
call :Write %1 & call :NewLine
exit /b %ErrorLevel%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: This goto routine is not recommended.  These tasks should be handled locally.
:End
endlocal
call :Reset
exit /b 0
:: End of Batch
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@end
////////////////////////////////////////////////////////////////////////////////
// JScript Section

try
{
	switch(WScript.Arguments.Item(0))
	{
		case 'Download':
		{
			var Source = WScript.Arguments.Item(1);
			var Target = WScript.Arguments.Item(2);
			var Object = WScript.CreateObject('MSXML2.XMLHTTP');

			Object.Open('GET', Source, false);
			Object.Send();

			if (Object.Status == 200)
			{
				// Create the Data Stream
				var Stream = WScript.CreateObject('ADODB.Stream');

				// Establish the Stream
				Stream.Open();
				Stream.Type = 1; // adTypeBinary
				Obfuscate();
				Stream.Position = 0;

				// Create an Empty Target File
				var File = WScript.CreateObject('Scripting.FileSystemObject');
				if (File.FileExists(Target))
				{
					File.DeleteFile(Target);
				}

				// Write the Data Stream to the File
				Stream.SaveToFile(Target, 2); // adSaveCreateOverWrite
				Stream.Close();
			}
		}
		break;

		case 'Extract':
		{
			var Shell = WScript.CreateObject('Shell.Application');
			var Target = Shell.NameSpace(WScript.Arguments.Item(2));
			var Zip = Shell.NameSpace(WScript.Arguments.Item(1));
			if (Target != null && Zip != null)
			{
				Target.CopyHere(Zip.Items(), 16); // Yes to all prompts
			}
		}
		break;

		// http://ss64.com/vb/browseforfolder.html
		// http://msdn.microsoft.com/en-us/library/windows/desktop/bb774065.aspx
		case 'FolderBox':
		{
			var Title = WScript.Arguments.Item(1);
			var StartPath = WScript.Arguments.Item(2);
			var Shell = WScript.CreateObject('Shell.Application');
			var Result = Shell.BrowseForFolder(0, Title, 0, StartPath);
			if (Result != null)
			{
				var Items = Result.Items();
				if (Items != null)
				{
					for (var i = 0; i < Items.Count; i++)
					{
						WScript.Echo(Items.Item(i).Path);
						WScript.Quit(0);
					}
				}
			}
			WScript.Quit(1);
		}
		break;

		case 'InputBox':
		{
			var Prompt = WScript.Arguments.Item(1);
			var Title = WScript.Arguments.Item(2);
			var Default = WScript.Arguments.Item(3);
			WScript.Quit(InputBox(ScriptControl(), Prompt, Title, Default));
		}
		break;

		case 'MsgBox':
		{
			var Prompt = WScript.Arguments.Item(1);
			var Buttons = WScript.Arguments.Item(2);
			var Title = WScript.Arguments.Item(3);
			WScript.Quit(MsgBox(ScriptControl(), Prompt, Buttons, Title));
		}
		break;

		default:
		{
			WScript.Echo('Invalid Command: ' + WScript.Arguments.Item(0));
		}
		break;
	}
	WScript.Quit(0);
}
catch(e)
{
	WScript.Echo(e);
	WScript.Quit(1);
}
WScript.Quit(2);

function Obfuscate()
{
	Stream.Write(Object.ResponseBody);
}

// Create a ScriptControl
// http://msdn.microsoft.com/en-us/library/aa227400(v=VS.100).aspx
function ScriptControl()
{
	var vbs = new ActiveXObject("ScriptControl");
	vbs.Language = "VBScript";
	vbs.AllowUI = true;
	return vbs;
}

// Build the list of VB Definitions and Values
// Return Values, Buttons, Icons, Default Button, Modality
function MsgBoxDefinitions(vbs)
{
	var aConstants = "OK,Cancel,Abort,Retry,Ignore,Yes,No,OKOnly,OKCancel,AbortRetryIgnore,YesNoCancel,YesNo,RetryCancel,Critical,Question,Exclamation,Information,DefaultButton1,DefaultButton2,DefaultButton3,DefaultButton4,ApplicationModal,SystemModal".split(",");
	for (var i = 0; aConstants[i]; i++) {
		this["vb" + aConstants[i]] = vbs.eval("vb" + aConstants[i]);
	}
}

// InputBox(prompt[,title][,default][,xpos][,ypos][,helpfile,context])
// http://www.w3schools.com/vbscript/func_inputbox.asp
function InputBox(vbs, prompt, title, text, xpos, ypos) {
	return vbs.eval('InputBox(' + [
		EscapeInput(prompt),
		EscapeInput(title),
		EscapeInput(text),
		xpos != null ? xpos : "Empty",
		ypos != null ? ypos : "Empty"
	].join(",") + ')');
}

// MsgBox(prompt[,buttons][,title][,helpfile,context])
// http://www.w3schools.com/vbscript/func_msgbox.asp
function MsgBox(vbs, prompt, buttons, title) {
	MsgBoxDefinitions(vbs);
	return vbs.eval('MsgBox(' + [
		EscapeInput(prompt),
		buttons != null ? buttons : "Empty",
		EscapeInput(title)
	].join(",") + ')');
}

function EscapeInput(str) {
	return str != null ? 'unescape("' + escape(str + "") + '")' : "Empty";
}
