@echo off
rem только поменяй дату здесь
set filemaskdate=2022-05-17

set dashcam_drive=D:
set videos_dir=videos
rem получишь файлы
rem 2022-05-21.mkv - слитые в один файл все видеозаписи с SD за дату 2022-05-21 из папки D:\Normal\
rem 2022-05-21_x8.mkv - ускоренное видео в 8 раз
rem не учитываются видеозаписи событий из D:\Event

set cmd_ffmpeg=ffmpeg
set DAY=%filemaskdate:~8,2%
set MONTH=%filemaskdate:~5,2%
set YEAR=%filemaskdate:~0,4%
echo %YEAR%-%MONTH%-%DAY%

set filename_concat=%videos_dir%\%filemaskdate%.mkv
set filename_speed=%videos_dir%\%filemaskdate%_x8.mkv
set file_mask_dashcam=%dashcam_drive%\Normal\FILE%YEAR%%MONTH%%DAY%-*

echo Video:    %filename_concat%
echo Video x8: %filename_speed%

if not exist "%videos_dir%" (
    mkdir "%videos_dir%"
)

start "" timer.cmd t_concat_mkv.cmd
