@echo off
setlocal

:: MotoToolkit v2014-11-20-1400
:: An automatic Windows setup script of tools for Motorola devices
::
:: Tools
:: - Motorola Device Manager for the latest official device drivers.
:: - Android SDK for the the latest official platform and build tools.
:: - APKTool for decompiling and building APKs.
:: - SignAPK from the Android master branch for signing APKs.
:: - Motorola's platform and build tools.
:: - Win-builds i686 for building Motorola's tools.
:: - JavaDK 7 as a dependency for other tools.
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

:: Load Translation
call :LoadStrings

:: Requirements
::
:: Java Developer Kit 7 or greater
:: TODO Download and Install only if needed or forced

:: Motorola Device Drivers
call :Download "http://www.mymotocast.com/download/MDM?platform=windows" "%Temp%\MotorolaDeviceManager.exe" && call :InstallShield "%Temp%\MotorolaDeviceManager.exe" || call :Assert -2147213312 "Unable to download and install the Motorola Device Manager"
:: Android SDK and ADB r23.0.2
:: The package numbers have to updated every time the installer is updated. android.bat list --all
call :Download "http://dl.google.com/android/installer_r23.0.2-windows.exe" "%Temp%\AndroidSDK.exe" && call :InstallNullSoft "%Temp%\AndroidSDK.exe" || call :Abort "Unable to download and install the Android SDK"
set "AndroidSDK=%LocalAppData%\Android\android-sdk"
echo Updating Android SDK...
echo y|"%AndroidSDK%\tools\android.bat" update sdk -u -a -t 1,2,3,109,120 >"%Temp%\android-sdk.log" 2>&1
echo Updating Android ADB...
call "%AndroidSDK%\tools\android.bat" update adb >"%Temp%\android-adb.log" 2>&1
:: APKTool 2.0 RC2
call :Download "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.0.0rc2.jar" "%AndroidSDK%\platform-tools\apktool.jar" || call :Abort "Unable to download APKTool"
call :Download "https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat" "%AndroidSDK%\platform-tools\apktool.bat" || call :Error "Unable to download the APKTool Batch Script"
:: Java SDK 7+
call "%AndroidSDK%\tools\lib\find_java.bat"
if not defined java_exe call :Error "JDK 7 or greater is required"
for /f "delims=" %%A in ("%java_exe%") do set "java_bin=%%~dpA"
:: SignAPK Master
call :Download "https://android.googlesource.com/platform/build/+/master/tools/signapk/SignApk.java" "%Temp%\SignApk.java" && %java_bin%\jar.exe cf "%AndroidSDK%\platform-tools\SignApk.jar" "%Temp%\SignApk.java"
:: Win-builds 1.4
:: TODO if win_builds exists, skip install and perform update
call :Download "http://win-builds.org/1.4.0/yypkg-1.4.0.exe" "%Temp%\yypkg.exe" && ( echo %LocalAppData%\win_builds& echo. ) | "%Temp%\yypkg.exe" --deploy --host "Windows" --i686 yes --x86_64 no
:: ZipAlign
rem for /f "delims=" %%A in ('dir /a-d /b /od /s "%AndroidSDK%\build-tools\*\zipalign.exe"') do echo f|xcopy "%%~A" "%AndroidSDK%"
:: mfastboot v2
:: TODO Download code and compile (gcc mingw) or download my own compiled version
endlocal & exit /b 0

:Abort [Message] ~UI
call :Error %1
call :__Abort 2>nul
exit /b 1
:__Abort
()
exit /b 1
:Assert <Values ...> [Message] ~UI
if "%ErrorLevel%" equ "%1" exit /b 0
if not "%~2"=="" shift & goto Assert
call :Abort %1
exit /b %ErrorLevel%
:Download <URL> <Destination> ~UI/IO
echo Downloading %~nx2...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "(New-Object System.Net.WebClient).DownloadFile('%~1', '%~2');"
exit /b %ErrorLevel%
:Error [Message]
echo [ERROR] (Code = %ErrorLevel%) %1
exit /b %ErrorLevel%
:Extract <Archive> <Destination> ~UI/IO
echo Extracting %~nx1...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "if ( -Not (Test-Path '%~2' -pathType container)) { $null = md '%~2' }; (New-Object -COM Shell.Application).NameSpace('%~2').CopyHere((New-Object -COM Shell.Application).NameSpace('%~1').Items(), 16);"
exit /b %ErrorLevel%
:ExtractGZip <Archive> <Output>
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$f = New-Object System.IO.FileStream '%~1', ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read); $o = New-Object System.IO.FileStream '%~2', ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None); $s = New-object -TypeName System.IO.Compression.GZipStream -ArgumentList $f, ([System.IO.Compression.CompressionMode]::Decompress); $b = New-Object byte[](1024); $c = 0; do { $c = $s.Read($b, 0, 1024); if ($c -gt 0) { $o.Write($b, 0, $c); } } while ($c -gt 0); $s.Close(); $o.Close(); $f.Close();"
exit /b %ErrorLevel%
:InstallShield <EXE> ~UI/IO
echo Installing %~nx1...
"%~1" /s
exit /b %ErrorLevel%
:InstallNullSoft <EXE> ~UI/IO
echo Installing %~nx1...
"%~1" /S
exit /b %ErrorLevel%
:LoadStrings ~UI/IO
set "language=en-us"
set "locale=%language%"
set "i18n_unsupported_locale=Unsupported language detected, using default %language%"
set "url_motorola_device_manager="
for /f "tokens=3 delims=;	 " %%A in ('systeminfo ^| find /i "System Locale"') do set "locale=%%~A"
call :LoadVars %~dp0\lang\%locale% || call :Error "%i18n_unsupported_locale%"
exit /b 0
:LoadVars <File>
if not exist "%~1" exit /b 1
for /f "delims=" %%A in ('2^>nul type "%~1"') do 2>nul set "%%~A"
exit /b 0
:Shortcut <Target> <Shortcut> ~IO
echo Shortcut %~nx1...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$s = (New-Object -comObject WScript.Shell).CreateShortcut('%~f2.lnk'); $s.TargetPath = '%~f1'; $s.Save();"
exit /b %ErrorLevel%
:Void <Routine> [Params...]
call :%* & exit /b %ErrorLevel%
