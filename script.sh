#!/bin/bash

directory=$1
sizeForTest_MB=$2  # Минимальный размер в MB для тестов
numFiles=$3
per=$4
numOfFiles=$5
backup=$6

sizeOfDir=$(df -h "$directory" | awk 'NR==2 {print $2}' | sed 's/M//')

if [ "$per" -gt 100 ]; then
    echo -e "\nInvalid value for the maximum percentage\n"
    exit 0
fi

if [ "$numOfFiles" -gt "$numFiles" ]; then
    echo -e "The number of files must be archived is more than the number of files in the directory\n"
    exit 0
fi

if [ ! -d "directory" ]; then
    mkdir -p "$directory"
    sudo mount -o loop limited_size.img $directory
    df -h $directory
    echo -e "\n"
fi

if [ "$sizeForTest_MB" -gt "$sizeOfDir" ]; then
    echo -e "\nYou cannot create $sizeForTest_MB MB of files because it is more than available space that equal to $sizeOfDir MB\n"
    exit 0
else
    echo -e "\nAVAILABLE SIZE\n"
fi

if [ ! -d "$backup" ]; then
    mkdir "$backup"
 echo -e "\nThe directory for archivation is created\n"
fi

create_file() {
    filename="$1"
    filesize_mb="$2"
    sudo dd if=/dev/zero of="$filename" bs=1M count="$filesize_mb" > /dev/null 2>&1
    sudo mv "$filename" "$directory"
}

create_testfiles() {
    echo -e "Creating of $numFiels files in the directory $directory\n"
    for i in $(seq 1 "$numFiles"); do
        name="testfile_$i.log"
        size_mb=$((sizeForTest_MB / numFiles))
        create_file "$name" "$size_mb"
    done
}

create_testfiles

b=$(pwd)

df -h "$directory"
echo -e "\n"
percent=$( df -h "$directory" | awk 'NR==2 {print $5}' | sed 's/%//')

ls $directory
echo -e "Fullness of $directory is $percent%\n"
if [ ! -d "$backup" ]; then
    echo -e "Directory $backup is created\n"
    mkdir "$backup"
fi

if [ "$percent" -ge "$per" ]; then
    echo -e "Fullness of $directory is more than $per%. Archivation is started...\n"
    files_to_archive=$(sudo find "$directory" -type f -printf "%T+ %p\n" | sort | head -n "$numOfFiles" | cut -d ' ' -f2-)
    echo -e "Total files in the directory BEFORE archivation: $numFiles\n"
    if [ -z "files_to_archive" ]; then
        echo -e "No files to archive\n"
        exit 0
    fi
    totalAfter=$(($numFiles - $numOfFiles))
    timename=$(date +%Y%m%d_%H%M%S)
    name_of_archive="$timename.tar.gz"
    echo -e "Acrchivation of the files in $name_of_archive\n"
    sudo tar -czf $backup/$name_of_archive  $files_to_archive
    echo -e "Deletion of the archived files from $directory\n"
    sudo rm -f $files_to_archive
    ls $directory
    echo -e "\n$Backup: \n"
    ls "$(pwd)/$backup"
    echo -e "\nArchivation is over\n"
    echo -e "Total files in the directory AFTER archivation: $totalAfter\n"
    sudo find $directory -type f -not -name 'lost+found' -delete
else
    echo -e "The fullness of $directory is less than $per%. Archivation is not started\n"
    sudo find $directory -type f -not -name 'lost+found' -delete
fi
