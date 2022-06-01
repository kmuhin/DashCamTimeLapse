@echo off

set ps1=%~dpn0.ps1
set cmd_file=%~f1
echo %DATE% %TIME% START

powershell -File "%ps1%" "%cmd_file%"

echo %DATE% %TIME% END
