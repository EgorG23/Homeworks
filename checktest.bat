@echo off
setlocal enabledelayedexpansion

set "name_of_dir=%~1"
set "directory=%cd%\%name_of_dir%"
set "backup=backup"
set "sizeForTest_MB=600"
set "numFiles=100"
set "quota_size=1GB"
set "volume_letter=%cd:~0,2%"    

if not exist "%directory%" (
    echo "Creating directory: %directory%"
    mkdir "%directory%"
)


call :testcase 70 5
del /q "%directory%\*" 
call :testcase 80 10
del /q "%directory%\*" 
call :testcase 90 20
del /q "%directory%\*" 
call :testcase 50 15

echo The End
exit /b

:create_file
set "filename=%~1"
set "filesize=%~2"
if !filesize! lss 1 (
    echo Ошибка: размер файла должен быть больше 0 байт
    exit /b
)
fsutil file createnew "%filename%" !filesize! >nul 2>&1
echo Create file "%filename%"
move "%filename%" "%directory%" >nul 2>&1
exit /b

:create_testfiles
echo Создание %numFiles% файлов в папке %directory%
set /a "size_mb=sizeForTest_MB / numFiles"
set /a "size_bytes=size_mb*1024*1024"
for /l %%i in (1,1,%numFiles%) do (
    call :create_file "testfile_%%i.txt" !size_bytes!
)
exit /b

:testcase
setlocal
set "per=%~1"
set "numOfFiles=%~2"
echo Тест: Порог %per%, %numOfFiles% файлов в архив
call :create_testfiles
call script.bat "%directory%" "%per%" "%numOfFiles%" "%backup%"
endlocal
exit /b
