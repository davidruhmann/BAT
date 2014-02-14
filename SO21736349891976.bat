:: By David Ruhmann
:: For http://stackoverflow.com/a/21736349/891976

:: Example
@echo off
:: Declare Outside Scope
setlocal enabledelayedexpansion
echo Outside
set "e=5"
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
echo(e=!e!
:: Declare Inside Scope
setlocal enabledelayedexpansion
:: Build Inside Variables
echo.
echo Inside
set "a=hi@%%$<>()[]|*~';,./?:{}+_-=\/ & bye"
set "b=2"
set "c=^^no ^& """g"o"
set "d=hello^!"
set "e="
:: View Variables Inside Scope
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
echo(e=!e!
:: Return A C D E
echo return a c d e
call :return a c d e
::set return
endlocal %return%
:: View Variables Outside Scope
echo.
echo Outside
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
echo(e=!e!
endlocal
pause
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Build a multi-variable return statement in the variable "return"
:: Supports all batch special characters. " ^ < > & !
:: Usage:
::     call :return var1 var2
::     endlocal %return%
:return [Variables...]
setlocal enabledelayedexpansion
set "return="
:_return
if "%~1"=="" endlocal & exit /b 1
if not defined %~1 goto __return
set "%~1=!%~1:"=""!"
set "%~1=!%~1:^=^^!"
set "%~1=!%~1:<=^<!"
set "%~1=!%~1:>=^>!"
set "%~1=!%~1:&=^&!"
set "%~1=!%~1:|=^|!"
:__return
set "return=!return!^&set ""%~1=!%~1!"""
if not "%~2"=="" shift & goto _return
setlocal disabledelayedexpansion
set "return=%return:!=^^^^^^^!%"
endlocal & endlocal & set "return=%return:""="%"
exit /b 0
