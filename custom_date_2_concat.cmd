@echo off
chcp 65001
rem Скрипт запускается из другого скрипта, из которого берутся переменные
rem %YEAR%, %MONTH, %%DAY% - год, месяц, день
rem %filename_concat% - файл вывода, объединенные в один файл видеозаписи с SD
rem %dashcam_drive% - диск с файлами
rem %cmd_ffmpeg% - команда запуска ffmpeg

rem == Set high-performance power scheme to speed job ==
rem call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

set file_mask=%YEAR%%MONTH%%DAY%-*
set file_mask_normal=FILE%file_mask%
set file_mask_event=EMER%file_mask%
rem Штатные видеозаписи
set dir_normal=%dashcam_drive%\Normal
rem Особые видеозаписи (сработал датчик удара)
set dir_event=%dashcam_drive%\Event
set tmp=%~dpn0%.tmp
set tmp_normal=%~dpn0%_normal.tmp
set tmp_event=%~dpn0%_event.tmp
set tmp_all=%~dpn0%_all.tmp

rem type NUL > %tmp%
del "%tmp%"
type NUL > "%tmp_normal%"
type NUL > "%tmp_event%"
type NUL > "%tmp_all%"

rem Штатные видеозаписи. Сохраняю два значения разделенных ";": только имя файла;полный путь файла.
rem Позже использую sort /+5 для сортировки начиная с даты (5-ый символ). В данном случае префиксы в именах файлов одинаковой длины.
rem Для префиксов разной длины можно пойти другим путем. Сразу вырезать из имени файла символы до даты, к примеру, удаляю первые 4 символа: 
rem  SETLOCAL EnableDelayedExpansion
rem  for /F "tokens=*" %%i in ('dir /b %dir_normal%\%file_mask_normal%') do (
rem     set tmpvar=%%i
rem     echo !tmpvar:~4!;%dir_normal%\%%i>> %tmp_normal%
rem   )
rem Далее sort использовать без  параметров.

for /F "tokens=*" %%i in ('dir /b %dir_normal%\%file_mask_normal%') do (
	echo %%i;%dir_normal%\%%i>> %tmp_normal%
)

rem Особые видеозаписи (сработал датчик удара)
for /F "tokens=*" %%i in ('dir /b %dir_event%\%file_mask_event%') do (
	echo %%i;%dir_event%\%%i>> %tmp_event%
)

rem Объединяю файлы и сортирую результат начиная с 5-го символа
rem т.е. фактически сортирую по датам в именах файлов.
type %tmp_normal% %tmp_event% 2>nul | sort /+5 > %tmp_all%

rem финальный файл для ffmpeg
for /F "tokens=1,2 delims=;" %%i in (%tmp_all%) do (
    echo file '%%j'>> %tmp%
    echo %%i
)

if not exist "%tmp%" (
    echo No matching files like: 
    echo    %dir_normal%\%file_mask_normal%
    echo    %dir_event%\%file_mask_event%
    goto END
)

pause
rem Запускаю слияние файлов
"%cmd_ffmpeg%" -f concat -safe 0 -i %tmp% -c copy "%filename_concat%"
echo  

rem Запускаю следующий скрипт
start "" timer.cmd custom_date_3_convert.cmd

:END