:: Limitations
:: - Does not support exclamation marks due to delayed expansion
:: - Does not support the circumflex accent character due it being the escape

@echo on
setlocal enabledelayedexpansion
setlocal
echo Inside
set "a=hi@%%$<>()[]|*~';,./?:{}+_-=\/ & bye"
set "b=2"
set "c=^^no ^& """g"o"
set "d=hello^!"
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
call :return a c d e
set return
pause
endlocal %return%
echo Outside
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
echo(z=!z!
endlocal
exit /b 0

:return [Variables...]
setlocal enabledelayedexpansion
set "z=9"
set "return="
:_return
if "%~1"=="" endlocal & exit /b 1
if not defined %~1 goto __return
set "_=!%~1!"
setlocal disabledelayedexpansion
set "_=%_:"=""%"
set "_=%_:^=^^%"
set "_=%_:<=^<%"
set "_=%_:>=^>%"
set "_=%_:&=^&%"
set "_=%_:|=^|%"
set "_=%_:!=^!%"
endlocal & set "return=!return!^&set ""%~1=%_%"""
:__return
if not "%~2"=="" shift & goto _return
set return
endlocal & set "return=%return:""="%"
exit /b 0

Thanks for bringing that to my attention. The ampersand issue should be fixed now.
