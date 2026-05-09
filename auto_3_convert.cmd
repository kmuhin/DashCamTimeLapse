@echo off
rem Этот скрипт запускается из другого скрипта, из которого берутся переменные
rem %cmd_ffmpeg% - команда запуска ffmpeg
rem %cmd_ffmpeg_opt% - опции ffmpeg
rem %filename_concat% - видеофайл для обработки
rem %filename_speed% - файл вывода ускоренного видео в 8 раз

rem == Set high-performance power scheme to speed job ==
rem call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

if not [%1%]==[] (
    set filename_concat=%1%
    set filename_speed=%~dpn1%_x8.mkv
    set cmd_ffmpeg=ffmpeg
    set cmd_ffmpeg_opt=-hide_banner
)

"%cmd_ffmpeg%" %cmd_ffmpeg_opt% -hwaccel cuda -i "%filename_concat%" -filter_complex "[0:v]setpts=0.125*PTS[v];[0:a]atempo=8.0[a]" -map "[v]" -map "[a]" "%filename_speed%"
echo  
