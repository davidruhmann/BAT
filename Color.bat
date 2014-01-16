:: Version 21 Plus by David Ruhmann
:: Based off script by Carlos at DosTips
@echo off
call :Color A "######" \n E "" C " 21 " E "!" \n B "######" \n A "\/\:/:" \n
call :Color C	"~!@#$&*()_+`-=[]\{}|;':,./<>?"	\n
rem pause >nul
exit /b 0

:: ChangeLog
:: - EnableExtensions is not needed since they are needed for CALL to work.
:: - Added a SUBST /d to prevent SUBST failure.
:: - Replaced CD with PUSHD so that the working directory change is reverted.
:: - Removed existing file check to prevent any bad data scenarios.
::   - The added overhead is worth the data assurance.
::   - Also the overhead is mitigated by proper usage of the parameter overload.
:: - Renamed variables and files to be clearer in meaning and readability.
:: - Added Performance Boost by using Backspace variables rather than files.
::   - Disk IO is much slower even with SSDs than Memory.
:: - Aligned parentheses so that Notepad++ detects matching pairs.
:: - Adjusted spacing and formatting for readability.  Max line length = 80
:: - Cleaned up by closing what I opened. SUBST /d ENDLOCAL and POPD
:: - Added exit code to the routine.

:: Notes and Limitations
:: - The \n check still presents a failure point with odd quotations or the non escaped.
:: - ^ will not output as doubled when in a double quoted string.
:: - % will be parsed out and may break the routine.
:: - Odd number of " will break the routine.
:: - Only supports ASCII command line sessions at this time.
:: - I am not totally happy with the SUBST using a non alpha since it is an undocumented hack.
:: - If that letter is already SUBST to a directory then the SUBST command will fail.
::   - Currently, we will steal this letter from any other usage by deleting existing.

:: ToDo
:: - Add Unicode support. Which is not possible using findstr.
::   - All file outputs that will be read by findstr need to be ANSI
::   - The findstr command does not support Unicode files.
:: - Fix the % ^ and " poison characters.

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::IO:UI
:: Version 21 Plus
:: Works in Windows 7, 8. Need to re-validate XP
:: In XP, extended ASCII characters are displayed as dots.
:: To print a double quote, pass in an empty string.
:Color <HexColor> [String=" [\n]] ...
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
