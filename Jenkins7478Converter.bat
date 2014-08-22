@echo off
if not exist "%~f1" exit /b 1
@echo off > "%~f1.fix"
setlocal EnableExtensions DisableDelayedExpansion
for /f "skip=2 tokens=1,* delims=]" %%K in ('find /n /v "" "%~f1"') do set "_=%%L" & >>"%~f1.fix" call :Expand_
endlocal

:Expand_
:: NULL is a blank line or line with only a close bracket ].
if not defined _ echo.^&#xd;& exit /b 0
:: Ensure even number of double quotation marks.
set "_=%_:"=""%"
:: Replace all U+'s to escape unicode notations.
set "_=%_:U+=U+0055%"
:: Replace all special search term signs.
call :Escape_ "=" "U+003D"
call :Escape_ "*" "U+002A"
call :Escape_ "~" "U+007E"
call :Escape_ "&" "U+0026"
:: Replace the search term.
set "_=%_:U+0026=U+0026amp;%"
set "_=%_:'=U+0026apos;%"
set "_=%_:""=U+0026quot;%"
set "_=%_:<=U+0026lt;%"
set "_=%_:>=U+0026gt;%"
:: Intermediate for Ampersand replacement.
set "_=%_:U+0026=<%"
call :Escape_ "<" "&"
:: Revert special search term signs then the U's.
set "_=%_:U+003D==%"
set "_=%_:U+002A=*%"
set "_=%_:U+007E=~%"
set "_=%_:U+0055=U+%"
:: Escape batch special characters.
set "_=%_:^=^^%"
set "_=%_:<=^<%"
set "_=%_:>=^>%"
set "_=%_:&=^&%"
set "_=%_:|=^|%"
:: Revert quotations.
set "_=%_:""="%"
:: Display
echo(%_%^&#xd;
exit /b 0

:: Escape a special character. Equals must be escaped first due to the delims.
:: Note that duplicate delims are allowed in the case of equals.
:: Escape must be used only while the euqal sign has been escaped.
:Escape_ <Character> <Unicode>
for /f "tokens=2,* delims==%~1" %%A in ('set _') do (
	set "[=%%A"
	set "]=%%B"
)
if defined ] (
	set "_=%[%%~2%]%"
	goto Escape_ %1 %2
)
exit /b 0
