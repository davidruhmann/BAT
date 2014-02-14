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
:: Return A C and D
::call :return2 a c d e
::pause
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
:: Escape the special characters within a variable value.
:: Parameter variable may not be equal to the internal variable name "_" underscore.
:escape <variable> <outvar>
setlocal enabledelayedexpansion
set "_=%~2"
if not defined _ endlocal & exit /b 1
if not defined %~2 endlocal & exit /b 2
set "%~2="
set "_=%~1"
if not defined _ endlocal & exit /b 3
if not defined %~1 endlocal & exit /b 4
set "_=!%~1!"
set "_=%_:"=""%"
set "_=%_:^=^^%"
set "_=%_:<=^<%"
set "_=%_:>=^>%"
set "_=%_:&=^&%"
set "_=%_:|=^|%"
setlocal disabledelayedexpansion
set "_=%_:!=^^^^^^^!%"
endlocal & endlocal & set "%~2=%_:""="%"
exit /b 0


:return2 [Variables...]
set "return="
setlocal enabledelayedexpansion
::for %%A in (%*) do for /f "tokens=1,* delims==" %%B in ('set %%~A') do if /i "%%~A"=="%%~B" for /f "tokens=1,* delims==" %%D ('set return') do if /i "return"=="%%~D" set "return=%%E&set "%%~A=%%C""
::for %%A in (%*) do call :escape %%~A value && set return=!return!^&set "%%~A=!value!"
set return
endlocal & %return%
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
