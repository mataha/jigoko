::: Copyright (c) mataha
:::
::: Permission is hereby granted, free of charge, to any person obtaining a
::: copy of this software and associated documentation files (the "Software"),
::: to deal in the Software without restriction, including without limitation
::: the rights to use, copy, modify, merge, publish, distribute, sublicense,
::: and/or sell copies of the Software, and to permit persons to whom
::: the Software is furnished to do so, subject to the following conditions:
:::
::: The above copyright notice and this permission notice shall be included in
::: all copies or substantial portions of the Software.
:::
::: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
::: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
::: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
::: THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
::: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
::: FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
::: DEALINGS IN THE SOFTWARE.
:::
::: Except as contained in this notice, the names of the above copyright
::: holders shall not be used in advertising or otherwise to promote the sale,
::: use or other dealings in this Software without prior written authorization.

::: this has been written in like 10 minutes, I'll fix it later ~pinky promise~

:init ()
    @if not "Windows_NT" == "%OS%" goto :fini

    @(verify "" || setlocal DisableDelayedExpansion EnableExtensions) 2>nul || (
        (echo(error: could not enable Command Extensions)
    ) >&2 && goto :EOF

    @if not defined DEBUG (echo off)

:main ()
    set "system=windows"

    if not defined root (call :get_workspace_root root)

    for /f "usebackq tokens=1,2 delims==, " %%a in ("%root%\build.zig.zon") do (
        if not defined version if ".minimum_zig_version" equ "%%~a" (set "version=%%~b")
    )

    if not defined version (
        echo couldn't read version from build.zig.zon
        goto :EOF
    )

    if not defined PROCESSOR_ARCHITEW6432 (
        set "architecture=%PROCESSOR_ARCHITECTURE%"
    ) else if /i "%PROCESSOR_ARCHITECTURE%" equ "x86" (
        set "architecture=%PROCESSOR_ARCHITEW6432%"
    )

    ::: https://learn.microsoft.com/en-us/windows/win32/winprog64/wow64-implementation-details
    if /i "%architecture%" equ "x86" (
        set "architecture=x86"
    ) else if "%architecture%" equ "AMD64" (
        set "architecture=x86_64"
    ) else if "%architecture%" equ "ARM64" (
        set "architecture=arm64"
    ) else (
        echo unsupported architecture: %architecture%
        goto :EOF
    )

    set "release=zig-%system%-%architecture%-%version%"
    set "exe=%root%\.zig\%release%\zig.exe"

    for /f "delims=" %%e in (""%exe%"") do (
        for /f "tokens=1,* delims=d" %%a in ("-%%~ae") do if not "%%b" equ "" (
            echo(wth, %exe% it's a directory>&2
            goto :EOF
        ) else if "%%a" equ "-" (
            call :download
        )
    )

    @(goto) 2>nul || (title^ %ComSpec%) && "%exe%" %*

:download
    set "file=%release%.zip"
    set "zip=%TMP%\%file%"

    for /f "delims=" %%e in (""%zip%"") do (
        for /f "tokens=1,* delims=d" %%a in ("-%%~ae") do if not "%%b" equ "" (
            echo(wth, %zip% it's a directory
            goto :EOF
        ) else if not "%%a" equ "-" (
            goto :extract
        )
    )

    set "url=https://ziglang.org/download/%version%/%file%"
    echo Downloading %url%...
    ::: todo use curl with fallback to bitsadmin
    "%SystemRoot%\System32\bitsadmin.exe" /transfer download /download /priority HIGH "%url%" "%zip%" >nul || (
        echo(error: something happened during downloading
        goto :EOF
    )

:extract
    mkdir "%root%\.zig" 2>nul
    echo Extracting %zip%...
    ::: todo extracting without tar available
    ::: todo fallback to unzip: unzip "%zip%" -d "%root%\.zig"
    "%SystemRoot%\System32\tar.exe" -xf "%zip%" -C "%root%\.zig" || (
        ecHO snafu: couldn't extract %zip% to %root%\.zig
        goto :EOF
    )

    goto :EOF

:get_workspace_root (out root: string)
    for /f "delims=" %%p in (""%~dp0."") do (set "%~1=%%~fp")

    goto :EOF

:fini ()
    @set windir=
    @set winbootdir=
    @if "" == "%windir%"                     set OS=DOS
    @if "" == "%OS%" if "" == "%winbootdir%" set OS=Windows 3.x
    @if "" == "%OS%"                         set OS=Windows 95
    @echo error: unsupported operating system (%OS%)

:EOF
