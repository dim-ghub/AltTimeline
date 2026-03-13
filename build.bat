@echo off
setlocal enabledelayedexpansion

set "CONFIG=Release"
set "METHOD=msbuild"
set "CLEAN=0"

:parse_args
if "%~1"=="" goto :done_args
if /i "%~1"=="-Configuration" (
    set "CONFIG=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-Config" (
    set "CONFIG=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-Method" (
    set "METHOD=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-Clean" (
    set "CLEAN=1"
    shift
    goto :parse_args
)
if /i "%~1"=="clean" (
    set "CLEAN=1"
    shift
    goto :parse_args
)
shift
goto :parse_args

:done_args

if "!CONFIG!" neq "Debug" if "!CONFIG!" neq "Release" (
    echo Invalid Configuration: !CONFIG!. Use Debug or Release.
    exit /b 1
)

if "!METHOD!" neq "msbuild" if "!METHOD!" neq "cmake" (
    echo Invalid Method: !METHOD!. Use msbuild or cmake.
    exit /b 1
)

if "!CLEAN!"=="1" (
    echo Cleaning...
    if exist "x64" rmdir /s /q "x64"
    if exist "build" rmdir /s /q "build"
    if exist "bin" rmdir /s /q "bin"
    if exist "obj" rmdir /s /q "obj"
    echo Clean completed.
)

echo Building with !METHOD!...
powershell -ExecutionPolicy Bypass -File build.ps1 -Configuration !CONFIG! -Method !METHOD!
exit /b %ERRORLEVEL%
