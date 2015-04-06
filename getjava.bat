@echo off
call :DownloadJava %* || call :Help %*
exit /b

:Help
echo.
echo.%~n0
echo.download script for oracle's java
echo.
echo.usage: "%~n0 <type> <ver> <update> <build> <arch> <os> <container> <dest>"
echo.type = jdk, jre, or server-jre
echo.ver = version number
echo.update = update number
echo.build = build number
echo.arch = i586 (all), x64 (all), sparc (solaris), sparcv9 (solaris)
echo.os = linux, macosx, solaris, or windows
echo.container = rpm (linux), tar.gz (all), dmg (macosx), or exe (windows)
echo.dest = file to save the download
echo.
echo.example: %~n0 jdk 7 72 14 i586 windows exe C:\Temp\jdk.exe
exit /b

:DownloadJava <Type> <Version> <Update> <Build> <Arch> <OS> <Container> <Destination>
call :DownloadWithCookie "http://download.oracle.com/otn-pub/java/jdk/%~2u%~3-b%~4/%~1-%~2u%~3-%~6-%~5.%~7" "%~8" "gpw_e24=http://www.oracle.com; oraclelicense=accept-securebackup-cookie" 2>nul && echo.Download Succeeded || echo.Download Failed
exit /b

:DownloadWithCookie <URL> <Destination> <Cookie>
echo Downloading %~nx2...
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$w = New-Object System.Net.WebClient; $w.Headers.Add('Cookie', '%~3'); $w.DownloadFile('%~1', '%~2')"
exit /b

:: David Ruhmann
