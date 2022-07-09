@echo off
rem только поменяй дату здесь
set filemaskdate=2022-07-03

set dashcam_drive=D:
set videos_dir=videos
rem получишь файлы вида
rem 2022-05-21.mkv - слитые в один файл все видеозаписи с камеры за дату 2022-05-21
rem 2022-05-21_x8.mkv - ускоренное видео в 8 раз
rem Видеозаписи берутся из 2-х папок и сортируются по дате:
rem D:\Event - события
rem D:\Normal - штатные

set cmd_ffmpeg=ffmpeg
set DAY=%filemaskdate:~8,2%
set MONTH=%filemaskdate:~5,2%
set YEAR=%filemaskdate:~0,4%
echo Date: %YEAR%-%MONTH%-%DAY%

set filename_concat=%videos_dir%\%filemaskdate%.mkv
set filename_speed=%videos_dir%\%filemaskdate%_x8.mkv

echo Video:    %filename_concat%
echo Video x8: %filename_speed%

if not exist "%videos_dir%" (
    mkdir "%videos_dir%"
)

start "" timer.cmd custom_date_2_concat.cmd
