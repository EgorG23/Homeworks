#!/bin/bash

directory=$1
per=$2
numOfFiles=$3
backup=$4

b=$(pwd)

df -h "$directory"

percent=$( df -h "$directory" | awk 'NR==2 {print $5}' | sed 's/%//')

ls $directory
echo "Заполненность папки $directory - $percent%"

if [ ! -d "$backup" ]; then
    echo "Папка $backup создана"
    mkdir "$backup"
fi

if [ "$percent" -ge "$per" ]; then
    echo "Заполненность папки $directory больше $per%. Архивация..."

   files_to_archive=$(sudo find "$directory" -type f -printf "%T+ %p\n" | sort | head -n "$numOfFiles" | cut -d ' ' -f2-)

   if [ -z "files_to_archive" ]; then
        echo "Нет файлов для архива"
        exit 0
    fi

    timename=$(date +%Y%m%d_%H%M%S)
    name_of_archive="$timename.tar.gz"
    echo "Архивация файлов в $name_of_archive"
    sudo tar -czf $backup/$name_of_archive  $files_to_archive
    echo "Удаляем заархивированные файлы из папки $directory"
 sudo rm -f $files_to_archive
    ls $directory
    echo "Backup: "
    ls "$(pwd)/$backup"
    echo "Архивирование завершилось"
    sudo find $directory -type f -not -name 'lost+found' -delete
else
    echo "Заполненность $directory не превышает $per%. Архивирование не происходит"
    sudo find $directory -type f -not -name 'lost+found' -delete
fi
