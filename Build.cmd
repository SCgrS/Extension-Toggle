@echo off
rem Builds Extension Toggle with the C# compiler that ships with Windows (.NET Framework 4). Output: bin\ExtensionToggle.exe
rem Paths are absolute and the current folder is not changed, so it also builds from a network share (UNC path).
setlocal
set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" (
  echo The .NET Framework 4 C# compiler was not found.
  call :done
  exit /b 1
)
if not exist "%~dp0bin" mkdir "%~dp0bin"
"%CSC%" /nologo /codepage:65001 /target:winexe /optimize+ /debug- /win32icon:"%~dp0icon.ico" /out:"%~dp0bin\ExtensionToggle.exe" "%~dp0src\*.cs"
if errorlevel 1 (
  call :done
  exit /b 1
)
echo Built: bin\ExtensionToggle.exe
call :done
exit /b 0

rem If the script was started by double-clicking, wait for a key so the window stays open long enough to read.
:done
setlocal EnableDelayedExpansion
if /i not "!cmdcmdline:/c =!"=="!cmdcmdline!" pause
endlocal
exit /b
