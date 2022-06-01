@echo off
rem Этот скрипт запускается из другого скритпа, из которого берутся переменные
rem %cmd_ffmpeg% - команда запуска ffmpeg
rem %file_mask_dashcam% - файлы видеозаписей с SD
rem %filename_out% - файл вывода, слитые в один файл файлы видеозаписей с SD

rem == Set high-performance power scheme to speed job ==
rem call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

set tmp=%~dpn0.tmp
rem type NUL > "%tmp%"
del "%tmp%"
rem for /F %%i in (%mylist%) do (
for /F "tokens=*" %%i in ('dir /b /s %file_mask_dashcam%') do (
	echo file '%%i' >> "%tmp%"
    echo '%%i'
)

if not exist "%tmp%" (
    echo No matching files like: %file_mask_dashcam%
    goto END
)

"%cmd_ffmpeg%" -f concat -safe 0 -i "%tmp%" -c copy "%filename_concat%"
echo  

start "" timer.cmd t_speed8_cuda.cmd

:END