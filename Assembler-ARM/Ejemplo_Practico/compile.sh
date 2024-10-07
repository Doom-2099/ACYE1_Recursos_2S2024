#!/usr/bin/bash
set -e 

echo -e Enter the name of the file:
read file

echo --------------- ASSEMBLING ----------------
echo Assembling file: $file.s - $(date +%H:%M:%S)
aarch64-linux-gnu-as -o $file.o $file.s

if [ $? -eq 0 ]; then
    echo Assembling successful
else
    echo Assembling failed
    exit 1
fi

echo ==========================================

echo ---------------- LINKING -----------------
echo Linking file: $file.o - $(date +%H:%M:%S)
aarch64-linux-gnu-ld -o $file $file.o

if [ $? -eq 0 ]; then
    echo Object file created
else
    echo Object file not created
    exit 1
fi

echo ==========================================

echo Done compiling and linking file: $file - $(date +%H:%M:%S)

if [ -z "$1" ]; then
    echo Running the file: $file - $(date +%H:%M:%S)
    qemu-aarch64 ./$file
    rm $file.o $file

elif [ "debug" == "$1" ]; then
    echo Debugging the file: $file - $(date +%H:%M:%S)
    qemu-aarch64 -g 1234 ./$file &
    gnome-terminal --window --maximize -- bash -c "gdb-multiarch -q --nh -ex 'set architecture aarch64' -ex 'file $file' -ex 'target remote localhost:1234' -ex 'layout split' -ex 'layout regs'; rm $file.o $file"

else 
    echo Invalid argument
    exit 1
fi