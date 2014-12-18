@echo off
setlocal
call :Main
endlocal
exit /b 0

:: AndroidSDK
:: An automatic Windows setup script for the AndroidSDK
::
:: Notes
:: - The Android SDK package numbers have to updated every time the installer is
::   updated to a new version. 'android.bat list --all' or 'list sdk' for v24+
::
:: Copyright (c) 2014 David Ruhmann
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

:::::::::::::::::::::::::::::::::IMPLEMENTATION::::::::::::EDIT:AT:YOUR:OWN:RISK
:Main
:: Variables
call :ProgramFiles32
set "path_android_sdk_anyone=%ProgramFiles32%\Android\android-sdk"
set "path_android_sdk_me=%LocalAppData%\Android\android-sdk"
set "path_android_sdk=%path_android_sdk_me%"
set "file_android_adb_log=%Temp%\android-adb.log"
set "file_android_sdk=%Temp%\AndroidSDK.exe"
set "file_android_sdk_log=%Temp%\android-sdk.log"
set "file_android_sdk_script=%path_android_sdk%\tools\android.bat"
set "url_android_sdk=http://dl.google.com/android/installer_r23.0.2-windows.exe"
set "opt_android_nullsoft=/D=%path_android_sdk%"
set "opt_android_sdk_packages=1,2,3,109,120"
:: Android SDK and ADB
call :Download "%url_android_sdk%" "%file_android_sdk%" && call :InstallNullSoft "%file_android_sdk%" "%opt_android_nullsoft%" || call :Abort "Unable to download and install Android SDK"
echo Updating Android SDK...
echo y|"%file_android_sdk_script%" update sdk -u -a -t %opt_android_sdk_packages% >"%file_android_sdk_log%" 2>&1
echo Updating Android ADB...
call "%file_android_sdk_script%" update adb >"%file_android_adb_log%" 2>&1
exit /b 0
:::::::::::::::::::::::::::::::::::FRAMEWORK:::::::::::::::::::::::::DO:NOT:EDIT
:Abort [Message] [_FUNCTION_] ~UI
call :Error %1 %2
call :__Abort 2>nul
exit /b 1
:__Abort
()
exit /b 1
:Download <URL> <Destination> ~UI/IO
echo Downloading %~nx2...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "(New-Object System.Net.WebClient).DownloadFile('%~1', '%~2');"
exit /b
:Error [Message] [_FUNCTION_]
echo [ERROR] ^(Code = %ErrorLevel%^) %~2: %~1
exit /b %ErrorLevel%
:InstallNullSoft <EXE> [Options] ~UI/IO
echo Installing %~nx1...
"%~1" /S %~2
exit /b
:ProgramFiles32
set "ProgramFiles32=%ProgramFiles%"
if defined ProgramFiles(x86) set "ProgramFiles32=%ProgramFiles(x86)%"
exit /b 0 {ProgramFiles32}
