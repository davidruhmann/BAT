:: http://stackoverflow.com/a/21736349/891976

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
set "%~1=!%~1:"=""!"
set "%~1=!%~1:^=^^!"
set "%~1=!%~1:<=^<!"
set "%~1=!%~1:>=^>!"
set "%~1=!%~1:&=^&!"
set "%~1=!%~1:|=^|!"
set "return=!return!^&set ""%~1=!%~1!"""
:__return
if not "%~2"=="" shift & goto _return
set return
setlocal disabledelayedexpansion
set "return=%return:!=^^^^^^^!%"
endlocal & endlocal & set "return=%return:""="%"
exit /b 0
