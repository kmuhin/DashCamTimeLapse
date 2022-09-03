@echo off

set dashcam_drive=D:
set videos_dir=videos
set history_dates=history_dates.txt
set file_prefix=auto
set last_date_file=last_date.txt
set cmd_ffmpeg=ffmpeg
set cmd_ffmpeg_opt=-hide_banner
set cmd_concat=%file_prefix%_2_concat.cmd
set cmd_convert=%file_prefix%_3_convert.cmd
set tmp=%file_prefix%_2_concat.tmp



if not exist "%videos_dir%" (
    mkdir "%videos_dir%"
)
:: Получить дату из имени файла.
:: set tmpdate=!tmpvar:~4,8%!
:: маски файлов регистратора в файле auto_2_concat.cmd
:: set file_mask_normal=FILE%file_mask%
:: set file_mask_event=EMER%file_mask%
SETLOCAL EnableDelayedExpansion

call :read_last_date
for /F "tokens=*" %%i in ('dir /b /o:N "%dashcam_drive%\Normal"') do (
    set tmpvar=%%i
    set tmpdate=!tmpvar:~4,13%!
    call :continue_date !tmpdate!
)

call :read_last_date
for /F "tokens=*" %%i in ('dir /b /o:N "%dashcam_drive%\Event"') do (
    set tmpvar=%%i
    set tmpdate=!tmpvar:~4,13%!
    call :continue_date !tmpdate!
)

goto end

:continue_date
    :: Если дата раньше или равна последней дате, пропускаю
    if %1 LEQ %last_date%  EXIT /B
    :: Дата есть во временном списке обработанных. Пропускаю
    findstr %1 "%tmp%" >nul 2>&1
    if %ERRORLEVEL% EQU 0 EXIT /B
    echo new video start date: %1
    set dt=%1
    set DAY=!dt:~6,2!
    set MONTH=!dt:~4,2!
    set YEAR=!dt:~0,4!
    set filemaskdate=!dt!
    set filename_concat=%videos_dir%\!dt!.mkv
    set filename_speed=%videos_dir%\!dt!_x8.mkv
    echo filename_concat: !filename_concat!
    echo filename_speed: !filename_speed!
    call "%cmd_concat%"
    if %ERRORLEVEL% NEQ 0 EXIT /B 1
    call "%cmd_convert%"
    if %ERRORLEVEL% NEQ 0 EXIT /B 1
    :: возвращаюсь к циклу
    EXIT /B

:read_last_date
    if not exist "%last_date_file%" (
        set last_date=0
    ) else (
        set /p last_date=<"%last_date_file%"
    )
    echo Last date: %last_date%
    EXIT /B

:end
del "%tmp%"