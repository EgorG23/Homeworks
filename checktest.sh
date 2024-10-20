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
    echo -e "\nBackup: \n"
    ls "$(pwd)/$backup"
    echo -e "\nArchivation is over\n"
    echo -e "Total files in the directory AFTER archivation: $totalAfter\n"
    sudo find $directory -type f -not -name 'lost+found' -delete
else
    echo -e "The fullness of $directory is less than $per%. Archivation is not started\n"
    sudo find $directory -type f -not -name 'lost+found' -delete
fi
