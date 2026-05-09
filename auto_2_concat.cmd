@echo off
:: Скрипт запускается из другого скрипта, из которого берутся переменные
:: %YEAR%, %MONTH, %%DAY% - год, месяц, день
:: %filename_concat% - файл вывода, объединенные в один файл видеозаписи с SD
:: %dashcam_drive% - диск с файлами
:: %cmd_ffmpeg% - команда запуска ffmpeg
:: %dt% - обрабатываемая дата(13 символов), с которой начинается слияние, пример: 20220730-1750
:: %last_date% - последняя обработанная дата
:: %last_date_file% - файл с последней датой

set file_mask=%YEAR%%MONTH%%DAY%-*
set file_mask_normal=FILE%file_mask%
set file_mask_event=EMER%file_mask%
:: Штатные видеозаписи
set dir_normal=%dashcam_drive%\Normal
:: Особые видеозаписи (сработал датчик удара)
set dir_event=%dashcam_drive%\Event
:: файл на вход ffmpeg
set tmp=%~dpn0%.tmp
set tmp_notsorted=%~dpn0%_notsorted.tmp
set tmp_sorted=%~dpn0%_sorted.tmp

:: type NUL > %tmp%
del "%tmp%"
type NUL > "%tmp_notsorted%"
type NUL > "%tmp_sorted%"

SETLOCAL EnableDelayedExpansion

:: Штатные видеозаписи. Сохраняю два значения разделенных ";": только имя файла;полный путь файла.
:: Позже использую sort /+5 для сортировки начиная с даты (5-ый символ). В данном случае префиксы в именах файлов одинаковой длины.
:: Для префиксов разной длины можно пойти другим путем. Сразу вырезать из имени файла символы до даты, к примеру, удаляю первые 4 символа: 
::  SETLOCAL EnableDelayedExpansion
::  for /F "tokens=*" %%i in ('dir /b %dir_normal%\%file_mask_normal%') do (
::     set tmpvar=%%i
::     echo !tmpvar:~4!;%dir_normal%\%%i>> %tmp_normal%
::   )
:: Далее sort использовать без  параметров.

for /F "tokens=*" %%i in ('dir /b "%dir_normal%\%file_mask_normal%"') do (
    call :proc_file %%i %dir_normal%
)

:: Особые видеозаписи (сработал датчик удара)
for /F "tokens=*" %%i in ('dir /b "%dir_event%\%file_mask_event%"') do (
	call :proc_file %%i %dir_event%
)


:: Объединяю файлы и сортирую результат начиная с 5-го символа
:: т.е. фактически сортирую по датам в именах файлов.
type %tmp_notsorted% 2>nul | sort /+5 > %tmp_sorted%

:: финальный файл для ffmpeg
for /F "tokens=1,2 delims=;" %%i in (%tmp_sorted%) do (
    echo file '%%j'>> %tmp%
    echo %%i
)

if not exist "%tmp%" (
    echo No matching files like: 
    echo    %dir_normal%\%file_mask_normal%
    echo    %dir_event%\%file_mask_event%
    EXIT 1
)

:: Запускаю слияние файлов
"%cmd_ffmpeg%" %cmd_ffmpeg_opt% -f concat -safe 0 -i "%tmp%" -c copy -scodec copy "%filename_concat%"
if %ERRORLEVEL% EQU 0 echo !cur_last_dt! > "%last_date_file%"
echo  

goto end

:proc_file
    set file_name=%1
    set cur_dt=!file_name:~4,13!
    :: Если дата раньше или равна последней дате, пропускаю
    if !cur_dt! LEQ %last_date%  EXIT /B
    echo %1;%2\%1>> %tmp_notsorted%
    if !cur_dt! LEQ !cur_last_dt! EXIT /B
    set cur_last_dt=!cur_dt!
    

:END