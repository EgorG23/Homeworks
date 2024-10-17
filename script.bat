@echo off
setlocal

set "directory=%~1"
set "per=%~2"
set "numOfFiles=%~3"
set "backup=%~4"

echo Проверка заполненности папки %directory%
set "used_space=0"
for /r "%directory%" %%A in (*) do (
    set /a used_space+=%%~zA
)

set total_space=1073741824
for /f "delims=" %%a in ('powershell -command "[math]::round((%used_space% / %total_space%) * 100)"') do set percent=%%a
echo Заполненность папки %percent%%

if %percent% GEQ %per% (
    echo Заполненность папки %directory% больше %per%. Архивация...
    for /f "delims=" %%F in ('powershell -command "Get-ChildItem -Path '%directory%' -Recurse | Sort-Object LastWriteTime | Select-Object -First %numOfFiles% -ExpandProperty FullName"') do (
        echo %%F >> old_files.txt
    )
    :: Проверяем, есть ли файлы для архивирования
    if not exist old_files.txt (
        echo Нет файлов для архивирования.
        exit /b 0
    )
    :: Архивируем файлы в backup
    set "TIMESTAMP=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
    set "ARCHIVE_NAME=%BACKUP_DIR1%\%TIMESTAMP%.zip"
    echo Архивируем файлы в %backup%
    powershell -command "Compress-Archive -Path (Get-Content 'old_files.txt') -DestinationPath '%backup%'"

    :: Удаляем заархивированные файлы
    echo Удаляем заархивированные файлы из %directory%
    for /f "delims=" %%F in (old_files.txt) do (
        del "%%F"
    )

    del old_files.txt
    echo Архивирование завершено.
) else (
    echo Заполненность %directory% не превышает %per%. Архивирование не происходит
)

exit /b

