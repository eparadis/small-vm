#!/bin/sh

# build the assembler
gcc -o bar asmblr.c

# run the test file
./bar asm.txt > temp.txt

# build the vm
gcc -o foo main.c

# run the vm
./foo temp.txt
