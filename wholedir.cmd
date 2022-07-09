@echo off
:: Конкатенация файлов в заданной директории. Или текущей, если директорая не указана первым параметром

set targetdir=%1
set filemask=????-??-??_x8.mkv
set filename_concat=filename_concat.mkv
set filename_speed=filename_concat_x8.mkv

set workdir=%~dp0%
set tmp=%~dpn0%.tmp
set cmd_ffmpeg=ffmpeg

:: Не указана директория через параметр, устанавливаю текущую
if [%targetdir%] == [] (
    set targetdir=%workdir%
)

echo Target dir: %targetdir%
del "%tmp%" >nul 2>&1

for /F "tokens=*" %%i in ('dir /b /o:N "%targetdir%\%filemask%"') do (
    echo %%i
    echo file '%targetdir%\%%i'>> "%tmp%"
)

if exist "%tmp%" (
    :: Запускаю слияние файлов
    call :concat
    :: Конвертирование
    call :convert

)

goto end

:concat
    "%cmd_ffmpeg%" -f concat -safe 0 -i "%tmp%" -c copy "%filename_concat%"
    echo  
    exit /b
:convert
    if [%filename_speed%] == [] (
        exit /b
     )
    "%cmd_ffmpeg%" -hwaccel cuda -i "%filename_concat%" -filter_complex "[0:v]setpts=0.125*PTS[v];[0:a]atempo=8.0[a]" -map "[v]" -map "[a]" "%filename_speed%"
    echo  
    exit /b

:end