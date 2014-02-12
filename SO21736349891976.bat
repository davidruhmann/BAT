:: http://stackoverflow.com/a/21736349/891976

@echo on
:: Declare Outside Scope
setlocal enabledelayedexpansion
:: Declare Inside Scope
setlocal enabledelayedexpansion
:: Build Inside Variables
echo Inside
set "a=hi@%%$<>()[]|*~';,./?:{}+_-=\/ & bye"
set "b=2"
set "c=^^no ^& """g"o"
set "d=hello^!"
:: View Variables Inside Scope
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
:: Return A C and D
call :return a c d e
::set return
endlocal %return%
:: View Variables Outside Scope
echo Outside
echo(a=!a!
echo(b=!b!
echo(c=!c!
echo(d=!d!
echo(z=!z!
endlocal
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Build a multi-variable return statement in the variable "return"
:: Usage:
::     call :return var1 var2
::     endlocal %return%
:: Supports all batch special characters. " ^ < > & !
:return [Variables...]
setlocal enabledelayedexpansion
:: set "z=9" &rem scope test
set "return="
:: Loop through parameters
:_return
:: Validate parameters
if "%~1"=="" endlocal & exit /b 1
if not defined %~1 goto __return
:: Escape special characters
set "%~1=!%~1:"=""!"
set "%~1=!%~1:^=^^!"
set "%~1=!%~1:<=^<!"
set "%~1=!%~1:>=^>!"
set "%~1=!%~1:&=^&!"
set "%~1=!%~1:|=^|!"
:: Add to return statement
set "return=!return!^&set ""%~1=!%~1!"""
:__return
if not "%~2"=="" shift & goto _return
::set return
:: Escape the exclamation mark. Seven circumflex equal 3 times escaped.
setlocal disabledelayedexpansion
set "return=%return:!=^^^^^^^!%"
endlocal & endlocal & set "return=%return:""="%"
exit /b 0
