@echo off

set history_dates=history_dates.txt
set dashcam_drive=D:
set videos_dir=videos
set cmd_ffmpeg=ffmpeg

if not exist "%videos_dir%" (
    mkdir "%videos_dir%"
)


SETLOCAL EnableDelayedExpansion

if not exist "%history_dates%" (
    type NUL > "%history_dates%"
)

for /F "tokens=*" %%i in ('dir /b /o:N D:\Normal') do (
    set tmpvar=%%i
    set tmpdate=!tmpvar:~4,8%!
    call :maketmpincludes !tmpdate!
)

for /F "tokens=*" %%i in ('dir /b /o:N D:\Event') do (
    set tmpvar=%%i
    set tmpdate=!tmpvar:~4,8%!
    call :maketmpincludes !tmpdate!
)


goto end

:maketmpincludes
findstr %1 "%history_dates%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo new video date: %1
    set dt=%1
    set DAY=!dt:~6,2!
    set MONTH=!dt:~4,2!
    set YEAR=!dt:~0,4!
    set filemaskdate=!YEAR!-!MONTH!-!DAY!
    set filename_concat=%videos_dir%\!filemaskdate!.mkv
    set filename_speed=%videos_dir%\!filemaskdate!_x8.mkv
    echo filename_concat: !filename_concat!
    echo filename_speed: !filename_speed!
    call 2_concat.cmd
    call 3_convert.cmd
    echo !tmpdate! >> "%history_dates%"
)
:: возвращаюсь к циклу
EXIT /B

:end