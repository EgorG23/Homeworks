#!/bin/bash

name_of_dir=$1
directory="$(pwd)/$name_of_dir"
backup="backup"

testcase_1() {
    echo -e "\n------------------------------------------------------\nTest 1: 1000MB, 20 files, Limit 70%, 5 files must be archived\n"
    ./script "$directory" 1000 20 70 5 backup
}

testcase_2() {
    echo -e "\n------------------------------------------------------\nTest 2: 150MB, 35 files, Limit is 50%, 10 files must be archived\n"
    ./script "$directory" 150 35 50 45 backup
}

testcase_3() {
    echo -e "\n------------------------------------------------------\nTest 3: 550MB, 40 files, Limit is 101%, 20 files must be archived\n"
    ./script "$directory" 550 40 101 20 backup
}

timename=$(date +%Y%m%d_%H%M%S)
name_of_backup="$timename"

testcase_4() {
    echo -e "\n------------------------------------------------------\nTest 4: 700MB, 150 files, Limit is 50%, 21 files must be archived\n"
    ./script "$directory" 700 150 50 145 "$name_of_backup"
}

testcase_5() {
    echo -e "\n------------------------------------------------------\nTest 5: incorrect input data"
    ./script "$directory" aaaa "$name_of_backup"
}

testcase_6() {
    echo -e "\n------------------------------------------------------\nTest 6: no input data"
    ./script
testcase_1
testcase_2
testcase_3
testcase_4
testcase_5
testcase_6

echo -e "\nThe End"
