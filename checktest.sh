#!/bin/bashc

name_of_dir=$1
directory="$(pwd)/$name_of_dir"
backup="backup"
sizeForTest_MB=600  # Минимальный размер в MB для тестов
numFiles=100     # Количество файлов для генерации

if [ ! -d "directory" ]; then
    mkdir -p "$directory"
    sudo mount -o loop limited_size.img $name_of_dir
    df -h $name_of_dir
fi

if [ ! -d "$backup" ]; then
    mkdir "$backup"
fi

create_file() {
    filename="$1"
    filesize_mb="$2"
    sudo dd if=/dev/zero of="$filename" bs=1M count="$filesize_mb" > /dev/null 2>&1
    sudo mv "$filename" "$directory"
}

create_testfiles() {
    echo "Создание $numFiels файлов в папке $directory"
    for i in $(seq 1 "$numFiles"); do
        name="testfile_$i.log"
        size_mb=$((sizeForTest_MB / numFiles))
        create_file "$name" "$size_mb"
    done
}

testcase_1() {
    create_testfiles
    echo "Тест 1: Порог 70%, 5 файлов в архив"
    ./script "$directory" 70 5 backup
}

testcase_2() {
    create_testfiles
    echo "Тест 2: Порог 80%, 10 файлов в архив"
    ./script "$directory" 80 10 backup
}

testcase_3() {
    create_testfiles
    echo "Тест 3: Порог 90%, 20 файлов в архив"
    ./script "$directory" 90 20 backup
}

testcase_4() {
    create_testfiles
    echo "Тест 4: Порог 50%, 15 файлов в архив"
    ./script "$directory" 50 15 backup
}

testcase_1
testcase_2
testcase_3
testcase_4

echo "The End"
