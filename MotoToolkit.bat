@echo off
setlocal
call :Main
endlocal
exit /b 0

:: MotoToolkit
:: An automatic Windows setup script of tools for Motorola devices
::
:: Tools
:: - Motorola Device Manager for the latest official device drivers.
:: - Android SDK for the the latest official platform and build tools.
:: - APKTool for decompiling and building APKs.
:: - SignAPK from the Android master branch for signing APKs.
:: - Motorola's platform and build tools.
:: - Win-builds i686 for building Motorola's tools.
:: - JavaDK as a dependency for other tools.
::
:: Notes
:: - The Android SDK package numbers have to updated every time the installer is
::   updated to a new version. 'android.bat list --all'
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
:Main ~UI/IO
:: Request Permission
call :Elevate "%~f0" %* || call :Abort "Administrator privilges are required"
:: Load Translation
call :LoadStrings

::Test
call :DownloadJava %opt_java_version% "%Temp%\jre.tar.gz"
exit /b 0

:: Help?
::call :IsOneOf "%~1" "" "/?" "-help" "--help" && call :Help && exit /b 0
:: 7za
::call :Download "%url_7za%" "%file_7za_zip%" && call :Extract "%file_7za_zip%" "%path_moto_toolkit%" && set "file_7za=%path_moto_toolkit%\7za.exe"
:: SysInternals Suite
::call :Download "%url_sysinternals_suite%" "%file_sysinternals_suite%" && call :Extract "%file_sysinternals_suite%" "%path_moto_toolkit%"
:: NirSoft Utilities
:: GNUWin32
::call :Download "%url_getgnuwin32%" "%file_getgnuwin32%" && call :InstallRARSFX "%file_getgnuwin32%" "%path_getgnuwin32_out%" && cmd /c "%file_getgnuwin32_download%" && cmd /c "%file_getgnuwin32_install%" || call :Error ""
:: Motorola Device Drivers
call :Download "%url_motorola_device_manager%" "%file_motorola_device_manager%" && call :InstallShield "%file_motorola_device_manager%" || call :Assert %code_motorola_device_manager_found% "%i18n_motorola_device_manager_failed%"
:: Android SDK and ADB
call :Download "%url_android_sdk%" "%file_android_sdk%" && call :InstallNullSoft "%file_android_sdk%" || call :Abort "%i18n_android_sdk_failed%"
echo %i18n_updating% Android SDK...
echo y|"%file_android_sdk_script%" update sdk -u -a -t %opt_android_sdk_packages% >"%file_android_sdk_log%" 2>&1
echo %i18n_updating% Android ADB...
call "%file_android_sdk_script%" update adb >"%file_android_adb_log%" 2>&1
:: APKTool
call :Download "%url_apktool%" "%file_apktool%" || call :Abort "%i18n_apktool_failed%"
call :Download "%url_apktool_script%" "%file_apktool_script%" || call :Error "%i18n_apktool_script_failed%"
:: Java SDK
call :DownloadJDK %opt_jdk_version% "%file_jdk_installer%"
::call "%file_find_java_script%"
::if not defined java_exe ( call :Error "%i18n_jdk_is_missing%" & start %url_jdk_downloads% )
::for /f "delims=" %%A in ("%java_exe%") do set "java_bin=%%~dpA"
:: SignAPK Master
call :Download "%url_signapk_source%" "%file_sign_apk_source%" && %java_bin%\jar.exe cf "%file_sign_apk%" "%file_sign_apk_source%"
:: Win-builds
:: TODO if win_builds exists, skip install and perform update using installed exe
::call :Download "%url_win_builds%" "%file_win_builds%" && ( echo.%path_win_builds%& echo. ) | "%file_win_builds%" --deploy --host "Windows" --i686 yes --x86_64 no
:: ZipAlign
rem for /f "delims=" %%A in ('dir /a-d /b /od /s "%path_android_sdk%\build-tools\*\zipalign.exe"') do echo f|xcopy "%%~A" "%path_android_sdk%"
:: mfastboot v2
:: TODO Download code and compile (gcc mingw) or download my own compiled version
::  Add platform-tools, build-tools, and win-builds to the Machine and User PATH
exit /b %ErrorLevel%
:LoadStrings ~UI/IO
:: Language Setup
set "locale=en-US"
set "language=%locale%"
:: Default Messaging
set "i18n_7za_not_found=Unable to locate 7za"
set "i18n_android_sdk_failed=Unable to download and install the Android SDK"
set "i18n_apktool_failed=Unable to download APKTool"
set "i18n_apktool_script_failed=Unable to download the APKTool Batch Script"
set "i18n_code=Code"
set "i18n_downloading=Downloading"
set "i18n_error=ERROR"
set "i18n_extracting=Extracting"
set "i18n_installing=Installing"
set "i18n_jdk_is_missing=JDK 7 or greater is required"
set "i18n_motorola_device_manager_failed=Unable to download and install the Motorola Device Manager"
set "i18n_shortcut=Shortcut"
set "i18n_unsupported_locale=Unsupported language detected, using default %language%"
set "i18n_updating=Updating"
set "i18n_version=14.325.12"
:: Known Codes
set "code_motorola_device_manager_found=-2147213312"
:: Command Options
set "opt_android_sdk_packages=1,2,3,109,120"
set "opt_java_version=jre 7 72 14 i586 windows .tar.gz"
set "opt_jdk_version=7 72 14 i586"
set "opt_jre_version=7 72 14 i586"
set "opt_jre_server_version=7 72 14 x64"
set "opt_oracle_license_cookie=gpw_e24=http://www.oracle.com; oraclelicense=accept-securebackup-cookie"
:: System Paths
set "path_android_sdk=%LocalAppData%\Android\android-sdk"
set "path_getgnuwin32_out=%Temp%\GetGnuWin32"
set "path_moto_toolkit=%ProgramData%\MotoToolkit"
set "path_win_builds=%ProgramData%\Win-builds"
:: System Files
set "file_7za_zip=%Temp%\7za.zip"
set "file_android_adb_log=%Temp%\android-adb.log"
set "file_android_sdk=%Temp%\AndroidSDK.exe"
set "file_android_sdk_log=%Temp%\android-sdk.log"
set "file_android_sdk_script=%path_android_sdk%\tools\android.bat"
set "file_apktool=%path_android_sdk%\platform-tools\apktool.jar"
set "file_apktool_script=%path_android_sdk%\platform-tools\apktool.bat"
set "file_find_java_script=%path_android_sdk%\tools\lib\find_java.bat"
set "file_jdk_installer=%Temp%\JavaDK.exe"
set "file_getgnuwin32=%Temp%\GetGNUWin32.exe"
set "file_getgnuwin32_download=%path_getgnuwin32_out%\download.bat"
set "file_getgnuwin32_install=%path_getgnuwin32_out%\install.bat"
set "file_motorola_device_manager=%Temp%\MotorolaDeviceManager.exe"
set "file_sign_apk=%path_android_sdk%\platform-tools\SignApk.jar"
set "file_sign_apk_source=%Temp%\SignApk.java"
set "file_sysinternals_suite=%Temp%\SysinternalsSuite.zip"
set "file_win_builds=%Temp%\yypkg.exe"
:: Web Addresses
set "url_7za=http://downloads.sourceforge.net/sevenzip/7za920.zip"
set "url_android_sdk=http://dl.google.com/android/installer_r23.0.2-windows.exe"
set "url_apktool=https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.0.0rc2.jar"
set "url_apktool_script=https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat"
set "url_getgnuwin32=http://downloads.sourceforge.net/getgnuwin32/GetGnuWin32-0.6.3.exe"
set "url_jdk_base=http://download.oracle.com/otn-pub/java/jdk"
set "url_jdk_downloads=http://www.oracle.com/technetwork/java/javase/downloads/index.html"
set "url_jre_base=http://download.oracle.com/otn-pub/java/jdk"
set "url_motorola_device_manager=http://www.mymotocast.com/download/MDM?platform=windows"
set "url_signapk_source=https://android.googlesource.com/platform/build/+/master/tools/signapk/SignApk.java"
set "url_sysinternals_suite=http://download.sysinternals.com/files/SysinternalsSuite.zip"
set "url_win_bash=http://downloads.sourceforge.net/win-bash/shell.w32-ix86.zip"
set "url_win_builds=http://win-builds.org/1.4.0/yypkg-1.4.0.exe"
call :LoadTranslation
call :ProgramFiles32
exit /b 0
:Help
echo.
echo MotoToolkit v%i18n_version%
echo.
echo Usage: %~nx0
echo.
echo.
exit /b 0
:::::::::::::::::::::::::::::::::::FRAMEWORK:::::::::::::::::::::::::DO:NOT:EDIT
:Abort [Message] [_FUNCTION_] ~UI
call :Error %1 %2
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
:Define <Var> [Value] [Default]
2>nul set "%~1=%~2"
if defined %~1 = exit /b 0 {=}
exit /b 1
:Download <URL> <Destination> ~UI/IO
echo %i18n_downloading% %~nx2...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "(New-Object System.Net.WebClient).DownloadFile('%~1', '%~2');"
exit /b %ErrorLevel%
:DownloadCookie <URL> <Destination> <Cookie> ~UI/IO
echo %i18n_downloading% %~nx2...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$w = New-Object System.Net.WebClient; $w.Headers.Add('Cookie', '%~3'); $w.DownloadFile('%~1', '%~2')"
exit /b %ErrorLevel%
:: type = jdk, jre, or server-jre
:: os = linux, macosx, solaris, or windows
:: container = rpm (linux), tar.gz (all), dmg (macosx), or exe (windows)
:: arc = i586 (all), x64 (all), sparc (solaris), sparcv9 (solaris)
:DownloadJava <Type> <Version> <Update> <Build> <Arch> <OS> <Container> <Destination> {url_jdk_base} {opt_oracle_license_cookie}
call :DownloadCookie "%url_jdk_base%/%~2u%~3-b%~4/%~1-%~2u%~3-%~6-%~5%~7" "%~8" "%opt_oracle_license_cookie%"
exit /b %ErrorLevel%
::http://download.oracle.com/otn-pub/java/jdk/7u72-b14/jdk-7u72-windows-x64.exe
::http://download.oracle.com/otn-pub/java/jdk/7u72-b14/jdk-7u72-windows-i586.exe
:DownloadJDK <Version> <Update> <Build> <Arch> <Destination> {url_jdk_base} {opt_oracle_license_cookie}
call :DownloadCookie "%url_jdk_base%/%~1u%~2-b%~3/jdk-%~1u%~2-windows-%~4.exe" "%~5" "%opt_oracle_license_cookie%"
::call :DownloadJava jdk %1 %2 %3 %4 windows exe %5
exit /b %ErrorLevel%
:DownloadJRE <Version> <Update> <Build> <Arch> <Destination> {url_jre_base} {opt_oracle_license_cookie}
call :DownloadCookie "%url_jre_base%/%~1u%~2-b%~3/jre-%~1u%~2-windows-%~4.tar.gz" "%~5" "%opt_oracle_license_cookie%"
exit /b %ErrorLevel%
:DownloadJREServer <Version> <Update> <Build> <Arch> <Destination> {url_jre_base} {opt_oracle_license_cookie}
call :DownloadCookie "%url_jre_base%/%~1u%~2-b%~3/server-jre-%~1u%~2-windows-%~4.tar.gz" "%~5" "%opt_oracle_license_cookie%"
exit /b %ErrorLevel%
:Elevate <Target> [...] ~UI
call :IsAdmin && exit /b
setlocal DisableDelayedExpansion
set "args="%*""
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "(New-Object -com 'Shell.Application').ShellExecute('cmd.exe', '/k ' + $env:args, '', 'runas');"
endlocal & exit /b %ErrorLevel%
:Error [Message] [_FUNCTION_]
echo [%i18n_error%] ^(%i18n_code% = %ErrorLevel%^) %~2: %~1
exit /b %ErrorLevel%
:Extract <Archive> <Destination> ~UI/IO
echo %i18n_extracting% %~nx1...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "if ( -Not (Test-Path '%~2' -pathType container)) { $null = md '%~2' }; (New-Object -COM Shell.Application).NameSpace('%~2').CopyHere((New-Object -COM Shell.Application).NameSpace('%~1').Items(), 16);"
exit /b %ErrorLevel%
:ExtractGZip <Archive> <Output>
echo %i18n_extracting% %~nx1...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$f = New-Object System.IO.FileStream '%~1', ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read); $o = New-Object System.IO.FileStream '%~2', ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None); $s = New-object -TypeName System.IO.Compression.GZipStream -ArgumentList $f, ([System.IO.Compression.CompressionMode]::Decompress); $b = New-Object byte[](1024); $c = 0; do { $c = $s.Read($b, 0, 1024); if ($c -gt 0) { $o.Write($b, 0, $c); } } while ($c -gt 0); $s.Close(); $o.Close(); $f.Close();"
exit /b %ErrorLevel%
:Extract7Zip <Archive> <Destination> {file_7za} ~UI/IO
if not defined file_7za call :Error "%i18n_7za_not_found%" "%0"
if not exist "%file_7za% call :Error "%i18n_7za_not_found%" "%0"
echo %i18n_extracting% %~nx1...
"%file_7za%" e -o"%~2" -y "%~1"
exit /b %ErrorLevel%
:FindJDK
if defined JAVA_HOME if exist "%JAVA_HOME%" exit /b 0
call :ProgramFiles32
for 
exit /b 0 {JAVA_HOME} {PROGRAMFILES32}
:InstallShield <EXE> ~UI/IO
echo %i18n_installing% %~nx1...
"%~1" /s
exit /b %ErrorLevel%
:InstallNullSoft <EXE> ~UI/IO
echo %i18n_installing% %~nx1...
"%~1" /S
exit /b %ErrorLevel%
:InstallRARSFX <EXE> [Destination] ~UI/IO
"%~1" -s -d%2
exit /b %ErrorLevel%
:IsAdmin
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "exit(!(new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator));"
exit /b %ErrorLevel%
:IsOneOf <String> <String...>
setlocal
call :Define _1 %1 ""
call :Define _2 %2
:__IsOneOf
if /i "%_1%"=="%_2%" endlocal & exit /b 0
shift
call :Define _2 %2 && goto __IsOneOf
endlocal
exit /b 1
:LoadTranslation
setlocal
for /f "tokens=3 delims=;	 " %%A in ('systeminfo ^| find /i "System Locale"') do set "_locale=%%~A"
if /i "%_locale%"=="%locale%" endlocal & exit /b 0
endlocal & set "locale=%_locale%"
call :LoadVars "%~dp0\lang\%locale%" || call :Error "%i18n_unsupported_locale%"
exit /b 0 {locale}
:LoadVars <File>
if not exist "%~1" exit /b 1
for /f "delims=" %%A in ('2^>nul type "%~1"') do 2>nul set "%%~A"
exit /b 0 {*}
:ProgramFiles32
set "ProgramFiles32=%ProgramFiles%"
if defined ProgramFiles(x86) set "ProgramFiles32=%ProgramFiles(x86)%"
exit /b 0
:Shortcut <Target> <Shortcut> ~IO
echo %i18n_shortcut% %~nx1...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$s = (New-Object -comObject WScript.Shell).CreateShortcut('%~f2.lnk'); $s.TargetPath = '%~f1'; $s.Save();"
exit /b %ErrorLevel%
:Void <Routine> [Params...]
call :%* & exit /b %ErrorLevel%
